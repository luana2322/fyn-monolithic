# AI Integration Design

## Overview

This document covers AI integration for:
1. **Icebreaker Messages** - Generate conversation starters
2. **Profile Scoring** - AI-enhanced compatibility
3. **Event Suggestions** - Smart recommendations
4. **Content Moderation** - Safety and trust

## Provider Selection: Hybrid Approach

| Feature | Provider | Rationale |
|---------|----------|-----------|
| Icebreakers | OpenAI GPT-4o-mini | Quality generation, affordable |
| Embeddings | OpenAI text-embedding-3-small | Best semantic search |
| Moderation | OpenAI Moderation API | Free, fast, reliable |
| Local Fallback | Mistral 7B | Privacy, cost control |

---

## 1. Icebreaker Message Generation

### Architecture

```
User A views User B profile
       │
       ▼
┌─────────────────────┐
│   IcebreakerService │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────┐
    │ Build Prompt │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   OpenAI     │
    │   API Call   │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   Cache      │
    │   & Return   │
    └──────────────┘
```

### Prompt Template

```java
@Service
public class IcebreakerService {

    private static final String SYSTEM_PROMPT = """
        You are a friendly conversation starter assistant for a social connection app.
        Generate 3 brief, natural icebreaker messages in Vietnamese.
        
        Rules:
        - Be warm, friendly, and respectful
        - Reference shared interests naturally
        - Keep messages short (1-2 sentences)
        - Avoid generic greetings like "Xin chào"
        - Make it easy to respond
        - Never be flirty unless context is romantic
        """;

    public List<String> generateIcebreakers(
        UserProfile currentUser,
        UserProfile targetUser,
        String context // 'dating', 'friendship', 'activity'
    ) {
        String userPrompt = buildUserPrompt(currentUser, targetUser, context);
        
        ChatCompletionRequest request = ChatCompletionRequest.builder()
            .model("gpt-4o-mini")
            .messages(List.of(
                new SystemMessage(SYSTEM_PROMPT),
                new UserMessage(userPrompt)
            ))
            .temperature(0.8)
            .maxTokens(200)
            .build();
        
        String response = openAiClient.createChatCompletion(request)
            .getChoices().get(0).getMessage().getContent();
        
        return parseIcebreakers(response);
    }

    private String buildUserPrompt(UserProfile user, UserProfile target, String context) {
        return String.format("""
            Generate icebreakers for this context:
            
            Connection type: %s
            
            About me:
            - Name: %s
            - Interests: %s
            - Looking for: %s
            
            About them:
            - Name: %s
            - Interests: %s
            - Bio: %s
            
            We share interests in: %s
            """,
            context,
            user.getName(),
            String.join(", ", user.getInterests()),
            String.join(", ", user.getLookingFor()),
            target.getName(),
            String.join(", ", target.getInterests()),
            target.getBio(),
            findCommonInterests(user, target)
        );
    }
}
```

### Example Output

```json
{
  "icebreakers": [
    "Mình thấy bạn cũng thích chụp ảnh street, có spot nào ở Sài Gòn mà bạn recommend không?",
    "Weekend này mình định đi hiking ở Núi Bà Đen, bạn có kinh nghiệm leo chưa?",
    "Mình đang tìm quán cafe để work, bạn có biết chỗ nào yên tĩnh không?"
  ]
}
```

---

## 2. Profile & Interest Embeddings

### Embedding Generation

```java
@Service
public class EmbeddingService {
    
    private static final String MODEL = "text-embedding-3-small";
    
    public float[] generateProfileEmbedding(UserProfile user) {
        String text = buildEmbeddingText(user);
        
        EmbeddingRequest request = EmbeddingRequest.builder()
            .model(MODEL)
            .input(List.of(text))
            .build();
        
        return openAiClient.createEmbedding(request)
            .getData().get(0).getEmbedding();
    }
    
    private String buildEmbeddingText(UserProfile user) {
        return String.format("""
            Interests: %s
            Looking for: %s
            Bio: %s
            Occupation: %s
            Personality: %s
            """,
            String.join(", ", user.getInterests()),
            String.join(", ", user.getLookingFor()),
            user.getBio() != null ? user.getBio() : "",
            user.getOccupation() != null ? user.getOccupation() : "",
            user.getPersonalityType() != null ? user.getPersonalityType() : ""
        );
    }
    
    public double cosineSimilarity(float[] a, float[] b) {
        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;
        
        for (int i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }
        
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }
}
```

### Storage (PostgreSQL + pgvector)

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Store embeddings
CREATE TABLE user_embeddings (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    profile_embedding VECTOR(1536),
    calculated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for similarity search
CREATE INDEX idx_embeddings_ivfflat 
ON user_embeddings USING ivfflat (profile_embedding vector_cosine_ops);

-- Find similar users
SELECT u.user_id, 1 - (e.profile_embedding <=> :target_embedding) as similarity
FROM user_embeddings e
JOIN user_profiles_extended u ON e.user_id = u.user_id
WHERE e.profile_embedding IS NOT NULL
ORDER BY e.profile_embedding <=> :target_embedding
LIMIT 50;
```

---

## 3. Smart Event Suggestions

### Prompt Template

```java
@Service
public class EventSuggestionService {

    public List<EventSuggestion> suggestEvents(UUID userId) {
        UserProfile user = userRepository.findById(userId);
        List<Event> nearbyEvents = eventRepository.findNearby(user.getLocation(), 20);
        
        String prompt = buildEventPrompt(user, nearbyEvents);
        
        ChatCompletionRequest request = ChatCompletionRequest.builder()
            .model("gpt-4o-mini")
            .messages(List.of(
                new SystemMessage(EVENT_SYSTEM_PROMPT),
                new UserMessage(prompt)
            ))
            .responseFormat(ResponseFormat.JSON_OBJECT)
            .build();
        
        return parseEventSuggestions(openAiClient.call(request));
    }

    private static final String EVENT_SYSTEM_PROMPT = """
        You are an event recommendation assistant.
        Analyze user preferences and available events.
        Return JSON with top 5 event recommendations.
        
        For each, explain WHY it matches the user.
        Consider: interests, availability, past behavior.
        
        Output format:
        {
          "suggestions": [
            {
              "event_id": "uuid",
              "match_reason": "brief explanation",
              "confidence": 0.0-1.0
            }
          ]
        }
        """;
}
```

---

## 4. Content Moderation

### Pipeline

```java
@Service
public class ModerationService {

    public ModerationResult moderate(String content, String contentType) {
        // 1. OpenAI Moderation API (free, fast)
        ModerationRequest request = ModerationRequest.builder()
            .input(content)
            .build();
        
        ModerationResponse response = openAiClient.createModeration(request);
        ModerationResult result = response.getResults().get(0);
        
        // 2. Check categories
        if (result.isFlagged()) {
            return ModerationResult.builder()
                .approved(false)
                .reason(getHighestCategory(result.getCategories()))
                .scores(result.getCategoryScores())
                .build();
        }
        
        // 3. Optional: Custom checks for Vietnamese content
        if (containsBannedWords(content)) {
            return ModerationResult.builder()
                .approved(false)
                .reason("banned_content")
                .build();
        }
        
        return ModerationResult.builder()
            .approved(true)
            .build();
    }

    public void moderateAsync(String contentId, String content, String contentType) {
        CompletableFuture.runAsync(() -> {
            ModerationResult result = moderate(content, contentType);
            if (!result.isApproved()) {
                // Flag content and notify moderators
                contentFlagService.flag(contentId, result);
            }
        });
    }
}
```

---

## 5. Smart Time/Place Recommendations

### Prompt for Meeting Suggestions

```java
public String suggestMeetingDetails(UserProfile user1, UserProfile user2) {
    String prompt = String.format("""
        Suggest the best meeting time and place for two people.
        
        Person A:
        - Location: %s
        - Available: %s
        - Interests: %s
        
        Person B:
        - Location: %s  
        - Available: %s
        - Interests: %s
        
        Their connection type: %s
        
        Suggest:
        1. Best day/time (considering both schedules)
        2. Type of venue (café, restaurant, park, etc.)
        3. Specific activity idea
        
        Keep suggestions practical for Ho Chi Minh City.
        """,
        user1.getLocationCity(),
        formatAvailability(user1.getAvailability()),
        String.join(", ", user1.getInterests()),
        user2.getLocationCity(),
        formatAvailability(user2.getAvailability()),
        String.join(", ", user2.getInterests()),
        connectionType
    );
    
    return openAiClient.chat(prompt);
}
```

---

## 6. Rate Limiting & Cost Control

```java
@Configuration
public class AIRateLimitConfig {
    
    @Bean
    public RateLimiter icebreakersLimiter() {
        return RateLimiter.of("icebreakers", RateLimiterConfig.custom()
            .limitForPeriod(10)        // 10 requests
            .limitRefreshPeriod(Duration.ofMinutes(1))
            .timeoutDuration(Duration.ofSeconds(5))
            .build());
    }
    
    @Bean
    public RateLimiter embeddingsLimiter() {
        return RateLimiter.of("embeddings", RateLimiterConfig.custom()
            .limitForPeriod(100)
            .limitRefreshPeriod(Duration.ofMinutes(1))
            .build());
    }
}

// Per-user limits
@Service
public class AIQuotaService {
    
    private static final int DAILY_ICEBREAKER_LIMIT = 20;
    
    public boolean canGenerateIcebreaker(UUID userId) {
        String key = "ai:quota:icebreaker:" + userId + ":" + LocalDate.now();
        Long count = redis.opsForValue().increment(key);
        
        if (count == 1) {
            redis.expire(key, Duration.ofDays(1));
        }
        
        return count <= DAILY_ICEBREAKER_LIMIT;
    }
}
```

---

## 7. Privacy Controls

```java
@Service
public class AIPrivacyService {

    // Check user consent before sending to AI
    public boolean hasAIConsent(UUID userId) {
        return userSettingsRepository.findByUserId(userId)
            .map(UserSettings::isAiEnabled)
            .orElse(false);
    }
    
    // Anonymize data before sending
    public String anonymizeForAI(UserProfile profile) {
        return String.format("""
            Interests: %s
            Personality: %s
            Looking for: %s
            """,
            String.join(", ", profile.getInterests()),
            profile.getPersonalityType(),
            String.join(", ", profile.getLookingFor())
        );
        // NOTE: No name, location specifics, or PII
    }
}
```

---

## 8. Cost Estimation

| Feature | Model | Est. Cost/1000 users/day |
|---------|-------|--------------------------|
| Icebreakers | GPT-4o-mini | $0.50 |
| Embeddings | text-embedding-3-small | $0.02 |
| Event suggestions | GPT-4o-mini | $0.30 |
| Moderation | Free tier | $0.00 |
| **Total** | | **~$0.82/1000 users/day** |

For 100K users: ~$82/day = ~$2,500/month

---

## Spring Configuration

```yaml
ai:
  openai:
    api-key: ${OPENAI_API_KEY}
    organization: ${OPENAI_ORG}
    
  models:
    chat: gpt-4o-mini
    embedding: text-embedding-3-small
    
  rate-limits:
    icebreakers-per-user-daily: 20
    embeddings-per-minute: 100
    
  features:
    icebreakers-enabled: true
    smart-suggestions-enabled: true
    moderation-enabled: true
    
  privacy:
    require-consent: true
    anonymize-profiles: true
```
