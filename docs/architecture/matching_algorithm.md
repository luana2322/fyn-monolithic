# Matching Microservice Design

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        MATCHING SERVICE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐  │
│  │   REST API   │    │  WebSocket   │    │   Background Jobs    │  │
│  │  Controller  │    │   Handler    │    │   (Score Refresh)    │  │
│  └──────┬───────┘    └──────┬───────┘    └──────────┬───────────┘  │
│         │                   │                        │              │
│         └───────────────────┼────────────────────────┘              │
│                             │                                        │
│                    ┌────────▼────────┐                              │
│                    │ MatchingService │                              │
│                    └────────┬────────┘                              │
│                             │                                        │
│         ┌───────────────────┼───────────────────┐                   │
│         │                   │                   │                   │
│  ┌──────▼──────┐    ┌──────▼──────┐    ┌──────▼──────┐            │
│  │   Filter    │    │   Scorer    │    │   Ranker    │            │
│  │   Pipeline  │    │   Engine    │    │   Engine    │            │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘            │
│         │                   │                   │                   │
│         └───────────────────┼───────────────────┘                   │
│                             │                                        │
│                    ┌────────▼────────┐                              │
│                    │  Score Cache    │                              │
│                    │    (Redis)      │                              │
│                    └─────────────────┘                              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Pipeline Architecture

### Phase 1: Fast Filtering (SQL/PostGIS)

```sql
-- Fast candidate filtering using PostGIS
SELECT u.user_id, u.location_lat, u.location_lng, u.interests
FROM user_profiles_extended u
WHERE 
    -- Distance filter (using spatial index)
    ST_DWithin(
        ST_SetSRID(ST_MakePoint(u.location_lng, u.location_lat), 4326)::geography,
        ST_SetSRID(ST_MakePoint(:user_lng, :user_lat), 4326)::geography,
        :max_distance_meters
    )
    -- Age filter
    AND EXTRACT(YEAR FROM AGE(u.date_of_birth)) BETWEEN :min_age AND :max_age
    -- Gender filter
    AND (ARRAY[:preferred_genders] IS NULL OR u.gender = ANY(:preferred_genders))
    -- Looking for match
    AND u.looking_for && ARRAY[:looking_for_types]
    -- Exclude blocked users
    AND u.user_id NOT IN (
        SELECT blocked_id FROM user_blocks WHERE blocker_id = :current_user_id
        UNION
        SELECT blocker_id FROM user_blocks WHERE blocked_id = :current_user_id
    )
    -- Exclude existing connections
    AND u.user_id NOT IN (
        SELECT CASE WHEN requester_id = :current_user_id THEN receiver_id ELSE requester_id END
        FROM connections
        WHERE (requester_id = :current_user_id OR receiver_id = :current_user_id)
          AND status IN ('accepted', 'pending')
    )
    -- Exclude already swiped
    AND u.user_id NOT IN (
        SELECT target_user_id FROM swipe_actions 
        WHERE user_id = :current_user_id AND context = :context
    )
    -- Active users only
    AND u.last_active_at > NOW() - INTERVAL '30 days'
LIMIT 500;
```

### Phase 2: Score Calculation

```java
@Service
public class MatchScoreCalculator {

    // Weight configuration (total = 100%)
    private static final double LOCATION_WEIGHT = 0.15;
    private static final double INTEREST_WEIGHT = 0.25;
    private static final double AVAILABILITY_WEIGHT = 0.10;
    private static final double PERSONALITY_WEIGHT = 0.10;
    private static final double ACTIVITY_PREF_WEIGHT = 0.15;
    private static final double SOCIAL_WEIGHT = 0.10;      // Mutual friends
    private static final double REPUTATION_WEIGHT = 0.10;
    private static final double ACTIVITY_WEIGHT = 0.05;    // Response rate, recent activity

    public MatchScore calculateScore(UserProfile currentUser, UserProfile candidate) {
        MatchScore score = new MatchScore();
        
        // 1. Location Score (closer = higher, exponential decay)
        double distanceKm = calculateDistance(currentUser, candidate);
        score.setLocationScore(calculateLocationScore(distanceKm, currentUser.getMaxDistanceKm()));
        
        // 2. Interest Score (Jaccard similarity + semantic embedding)
        score.setInterestScore(calculateInterestScore(
            currentUser.getInterests(), 
            candidate.getInterests()
        ));
        
        // 3. Availability Score (overlapping time slots)
        score.setAvailabilityScore(calculateAvailabilityScore(
            currentUser.getAvailability(),
            candidate.getAvailability()
        ));
        
        // 4. Personality Score (MBTI compatibility matrix)
        score.setPersonalityScore(calculatePersonalityScore(
            currentUser.getPersonalityType(),
            candidate.getPersonalityType()
        ));
        
        // 5. Activity Preference Score
        score.setActivityPrefScore(calculateActivityPrefScore(
            currentUser.getLookingFor(),
            candidate.getLookingFor()
        ));
        
        // 6. Social Score (mutual friends/connections)
        score.setSocialScore(calculateSocialScore(currentUser.getId(), candidate.getId()));
        
        // 7. Reputation Score (reviews)
        score.setReputationScore(candidate.getReputationScore() * 20.0); // 0-5 -> 0-100
        
        // 8. Activity Score (response rate + recency)
        score.setActivityScore(calculateActivityScore(candidate));
        
        // Weighted sum
        double overallScore = 
            score.getLocationScore() * LOCATION_WEIGHT +
            score.getInterestScore() * INTEREST_WEIGHT +
            score.getAvailabilityScore() * AVAILABILITY_WEIGHT +
            score.getPersonalityScore() * PERSONALITY_WEIGHT +
            score.getActivityPrefScore() * ACTIVITY_PREF_WEIGHT +
            score.getSocialScore() * SOCIAL_WEIGHT +
            score.getReputationScore() * REPUTATION_WEIGHT +
            score.getActivityScore() * ACTIVITY_WEIGHT;
        
        // Verification bonus (+5% for verified)
        if (candidate.isVerified()) {
            overallScore *= 1.05;
        }
        
        score.setOverallScore(Math.min(100.0, overallScore));
        return score;
    }

    // Location: Exponential decay based on distance
    private double calculateLocationScore(double distanceKm, double maxDistanceKm) {
        if (distanceKm > maxDistanceKm) return 0.0;
        // Score = 100 * e^(-distance/decay_factor)
        double decayFactor = maxDistanceKm / 3.0;
        return 100.0 * Math.exp(-distanceKm / decayFactor);
    }

    // Interests: Jaccard + Embedding similarity
    private double calculateInterestScore(List<String> interests1, List<String> interests2) {
        if (interests1.isEmpty() || interests2.isEmpty()) return 50.0;
        
        // Jaccard similarity
        Set<String> set1 = new HashSet<>(interests1);
        Set<String> set2 = new HashSet<>(interests2);
        Set<String> intersection = new HashSet<>(set1);
        intersection.retainAll(set2);
        Set<String> union = new HashSet<>(set1);
        union.addAll(set2);
        
        double jaccard = (double) intersection.size() / union.size();
        
        // Optional: Add semantic similarity from embeddings
        // double semantic = embeddingService.cosineSimilarity(interests1, interests2);
        // return (jaccard * 0.6 + semantic * 0.4) * 100.0;
        
        return jaccard * 100.0;
    }

    // Availability: Overlapping time slots
    private double calculateAvailabilityScore(Availability a1, Availability a2) {
        if (a1 == null || a2 == null) return 50.0;
        
        int overlappingDays = 0;
        int overlappingSlots = 0;
        
        for (String day : a1.getAvailableDays()) {
            if (a2.getAvailableDays().contains(day)) {
                overlappingDays++;
            }
        }
        
        Map<String, Boolean> slots1 = a1.getTimeSlots();
        Map<String, Boolean> slots2 = a2.getTimeSlots();
        
        for (String slot : List.of("morning", "afternoon", "evening", "night")) {
            if (Boolean.TRUE.equals(slots1.get(slot)) && Boolean.TRUE.equals(slots2.get(slot))) {
                overlappingSlots++;
            }
        }
        
        double dayScore = (overlappingDays / 7.0) * 50;
        double slotScore = (overlappingSlots / 4.0) * 50;
        
        return dayScore + slotScore;
    }

    // Personality: MBTI compatibility (simplified)
    private double calculatePersonalityScore(String type1, String type2) {
        if (type1 == null || type2 == null) return 50.0;
        
        // High compatibility pairs (simplified - use full matrix in production)
        Map<String, List<String>> compatibleTypes = Map.of(
            "INFJ", List.of("ENFP", "ENTP", "INTJ", "INFJ"),
            "ENFP", List.of("INFJ", "INTJ", "ENFJ", "INFP"),
            "INTJ", List.of("ENFP", "ENTP", "INFJ", "ENTJ"),
            "ENTP", List.of("INFJ", "INTJ", "ENFP", "ENTJ")
            // ... add all 16 types
        );
        
        List<String> compatible = compatibleTypes.getOrDefault(type1, List.of());
        if (compatible.contains(type2)) return 90.0;
        
        // Same type = moderate compatibility
        if (type1.equals(type2)) return 70.0;
        
        // Matching on I/E or N/S or T/F or J/P
        int matches = 0;
        for (int i = 0; i < 4; i++) {
            if (type1.charAt(i) == type2.charAt(i)) matches++;
        }
        
        return 30.0 + (matches * 15.0);
    }

    // Activity preference: Looking for type match
    private double calculateActivityPrefScore(List<String> looking1, List<String> looking2) {
        Set<String> set1 = new HashSet<>(looking1);
        Set<String> set2 = new HashSet<>(looking2);
        Set<String> common = new HashSet<>(set1);
        common.retainAll(set2);
        
        if (common.isEmpty()) return 20.0; // Still might match
        return (common.size() / (double) Math.max(set1.size(), set2.size())) * 100.0;
    }

    // Social: Mutual connections
    private double calculateSocialScore(UUID user1, UUID user2) {
        int mutualFriends = connectionRepository.countMutualConnections(user1, user2);
        
        // Diminishing returns: 1->40, 2->60, 3->75, 5+->90
        if (mutualFriends == 0) return 0.0;
        if (mutualFriends == 1) return 40.0;
        if (mutualFriends == 2) return 60.0;
        if (mutualFriends <= 4) return 75.0;
        return 90.0;
    }

    // Activity: Response rate + recency
    private double calculateActivityScore(UserProfile candidate) {
        double responseRateScore = candidate.getResponseRate() * 0.6;
        
        // Recency: Active in last 24h = 40, last week = 30, last month = 20
        long hoursSinceActive = Duration.between(
            candidate.getLastActiveAt(), 
            Instant.now()
        ).toHours();
        
        double recencyScore;
        if (hoursSinceActive < 24) recencyScore = 40.0;
        else if (hoursSinceActive < 168) recencyScore = 30.0;
        else recencyScore = 20.0;
        
        return responseRateScore + recencyScore;
    }
}
```

### Phase 3: Ranking & Output

```java
@Service
public class MatchRankingService {

    public List<MatchedUser> rankAndPaginate(
        UUID currentUserId,
        List<UserProfile> candidates,
        MatchingContext context,
        int limit,
        String cursor
    ) {
        // Calculate scores for all candidates
        List<ScoredCandidate> scored = candidates.parallelStream()
            .map(c -> new ScoredCandidate(c, matchScoreCalculator.calculateScore(currentUser, c)))
            .collect(Collectors.toList());
        
        // Sort by score descending
        scored.sort((a, b) -> Double.compare(b.getScore().getOverallScore(), a.getScore().getOverallScore()));
        
        // Apply cursor pagination
        if (cursor != null) {
            double cursorScore = decodeCursor(cursor);
            scored = scored.stream()
                .filter(s -> s.getScore().getOverallScore() < cursorScore)
                .collect(Collectors.toList());
        }
        
        // Limit results
        List<ScoredCandidate> page = scored.stream()
            .limit(limit)
            .collect(Collectors.toList());
        
        // Build response with match reasons
        return page.stream()
            .map(s -> buildMatchedUser(s.getCandidate(), s.getScore()))
            .collect(Collectors.toList());
    }

    private MatchedUser buildMatchedUser(UserProfile candidate, MatchScore score) {
        MatchedUser user = new MatchedUser();
        user.setId(candidate.getId());
        user.setName(candidate.getName());
        user.setAge(candidate.getAge());
        user.setAvatarUrl(candidate.getAvatarUrl());
        user.setDistanceKm(score.getDistanceKm());
        user.setMatchScore(score.getOverallScore());
        user.setMatchedInterests(score.getCommonInterests());
        user.setIsVerified(candidate.isVerified());
        user.setReputationScore(candidate.getReputationScore());
        
        // Generate match reasons
        user.setMatchReasons(generateMatchReasons(score));
        
        return user;
    }

    private List<String> generateMatchReasons(MatchScore score) {
        List<String> reasons = new ArrayList<>();
        
        if (score.getLocationScore() > 80) {
            reasons.add("Very close to you");
        }
        if (!score.getCommonInterests().isEmpty()) {
            reasons.add("Shares your interest in " + score.getCommonInterests().get(0));
        }
        if (score.getSocialScore() > 50) {
            reasons.add("You have mutual connections");
        }
        if (score.getAvailabilityScore() > 70) {
            reasons.add("Available at similar times");
        }
        if (score.getPersonalityScore() > 80) {
            reasons.add("Personality compatibility");
        }
        
        return reasons.stream().limit(3).collect(Collectors.toList());
    }
}
```

## Caching Strategy

```java
@Service
public class MatchScoreCacheService {
    
    private final RedisTemplate<String, Object> redis;
    private static final Duration CACHE_TTL = Duration.ofHours(24);
    
    // Cache key: match:score:{userA}:{userB}
    public Optional<MatchScore> getCachedScore(UUID userA, UUID userB) {
        String key = buildKey(userA, userB);
        return Optional.ofNullable((MatchScore) redis.opsForValue().get(key));
    }
    
    public void cacheScore(UUID userA, UUID userB, MatchScore score) {
        String key = buildKey(userA, userB);
        redis.opsForValue().set(key, score, CACHE_TTL);
    }
    
    // Invalidate when user updates profile
    public void invalidateForUser(UUID userId) {
        String pattern = "match:score:*" + userId + "*";
        Set<String> keys = redis.keys(pattern);
        if (keys != null && !keys.isEmpty()) {
            redis.delete(keys);
        }
    }
    
    private String buildKey(UUID userA, UUID userB) {
        // Ensure consistent key regardless of order
        String id1 = userA.compareTo(userB) < 0 ? userA.toString() : userB.toString();
        String id2 = userA.compareTo(userB) < 0 ? userB.toString() : userA.toString();
        return "match:score:" + id1 + ":" + id2;
    }
}
```

## Background Jobs

```java
@Component
public class MatchScoreRefreshJob {
    
    @Scheduled(cron = "0 0 3 * * *") // Daily at 3 AM
    public void refreshTopMatchScores() {
        // Get active users (active in last 7 days)
        List<UUID> activeUsers = userRepository.findActiveUserIds(7);
        
        for (UUID userId : activeUsers) {
            // Recalculate top 100 matches
            List<MatchScore> topMatches = matchingService.calculateTopMatches(userId, 100);
            
            // Store in batch
            matchScoreRepository.batchUpsert(topMatches);
        }
    }
    
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    public void expireStaleScores() {
        matchScoreRepository.deleteExpired();
    }
}
```

## API Flow

```
Client Request: GET /matching/discover?type=friendship&distance=10

1. Auth → Extract userId from JWT
2. Get user profile & preferences
3. Filter Pipeline (PostGIS query) → 500 candidates max
4. Check Redis cache for scores
5. Calculate missing scores in parallel
6. Rank by overall score
7. Apply cursor pagination
8. Build response with match reasons
9. Cache new scores
10. Return MatchedUser[]
```

## Performance Targets

| Metric | Target |
|--------|--------|
| Filter query | < 100ms |
| Score calculation (per user) | < 5ms |
| Full discover request | < 500ms |
| Cache hit rate | > 70% |
| Concurrent users | 10,000+ |

## Database Indexes Required

```sql
-- Location (PostGIS)
CREATE INDEX idx_user_location ON user_profiles_extended 
    USING GIST (ST_SetSRID(ST_MakePoint(location_lng, location_lat), 4326));

-- Age filtering
CREATE INDEX idx_user_age ON user_profiles_extended(date_of_birth);

-- Active users
CREATE INDEX idx_user_active ON user_profiles_extended(last_active_at DESC);

-- Interests (GIN for array containment)
CREATE INDEX idx_user_interests ON user_profiles_extended USING GIN(interests);

-- Looking for (GIN for array overlap)
CREATE INDEX idx_user_looking_for ON user_profiles_extended USING GIN(looking_for);

-- Swipe actions (for exclusion)
CREATE INDEX idx_swipe_exclusion ON swipe_actions(user_id, target_user_id, context);

-- Blocks
CREATE INDEX idx_blocks_both ON user_blocks(blocker_id, blocked_id);
```

## Spring Boot Configuration

```yaml
matching:
  cache:
    enabled: true
    ttl-hours: 24
  scoring:
    weights:
      location: 0.15
      interest: 0.25
      availability: 0.10
      personality: 0.10
      activity-pref: 0.15
      social: 0.10
      reputation: 0.10
      activity: 0.05
  limits:
    max-candidates: 500
    default-page-size: 20
    max-page-size: 50
  jobs:
    score-refresh-cron: "0 0 3 * * *"
```
