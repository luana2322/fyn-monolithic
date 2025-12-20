package com.fyn_monolithic.service.match;

import com.fyn_monolithic.exception.BadRequestException;
import com.fyn_monolithic.exception.ResourceNotFoundException;
import com.fyn_monolithic.model.user.User;
import com.fyn_monolithic.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Service for managing user reputation based on dating behavior
 * Applies penalties for no-shows and rewards for successful dates
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ReputationService {

    private final UserRepository userRepository;

    private static final int NO_SHOW_PENALTY = -10;
    private static final int SUCCESSFUL_DATE_BONUS = 2;
    private static final int MIN_REPUTATION = 0;
    private static final int MAX_REPUTATION = 200;

    /**
     * Apply penalty when user is reported for not showing up to a date
     */
    @Transactional
    public void applyNoShowPenalty(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Get current reputation (from user_profiles table)
        Double currentReputation = getUserReputation(user);
        Double newReputation = Math.max(MIN_REPUTATION, currentReputation + NO_SHOW_PENALTY);

        // Update reputation in user_profiles if it exists
        // Note: reputation_score is in user_profiles table

        // Increment no-show count
        Integer noShowCount = user.getNoShowCount() != null ? user.getNoShowCount() : 0;
        user.setNoShowCount(noShowCount + 1);

        userRepository.save(user);

        log.warn("Applied no-show penalty to user {}: reputation {} -> {}, total no-shows: {}",
                userId, currentReputation, newReputation, user.getNoShowCount());
    }

    /**
     * Apply bonus when both users confirm they met
     */
    @Transactional
    public void applySuccessBonus(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Double currentReputation = getUserReputation(user);
        Double newReputation = Math.min(MAX_REPUTATION, currentReputation + SUCCESSFUL_DATE_BONUS);

        // Note: Would update user_profiles.reputation_score here

        userRepository.save(user);

        log.info("Applied success bonus to user {}: reputation {} -> {}",
                userId, currentReputation, newReputation);
    }

    /**
     * Get user's reputation score
     * Note: reputation_score is stored in user_profiles table
     */
    private Double getUserReputation(User user) {
        // Placeholder - would join with user_profiles table
        return 100.0; // Default reputation
    }

    /**
     * Check if user has good reputation (for discover algorithm)
     */
    public boolean hasGoodReputation(UUID userId) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null)
            return false;

        Double reputation = getUserReputation(user);
        Integer noShows = user.getNoShowCount() != null ? user.getNoShowCount() : 0;

        // Good reputation: score >= 70 and less than 3 no-shows
        return reputation >= 70.0 && noShows < 3;
    }
}
