package com.fyn_monolithic.repository.date;

import com.fyn_monolithic.model.date.ConnectionTypeEnum;
import com.fyn_monolithic.model.date.DatePlan;
import com.fyn_monolithic.model.date.DateStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DatePlanRepository extends JpaRepository<DatePlan, UUID> {

    // Find public dates for browsing
    @Query("SELECT d FROM DatePlan d WHERE d.isPublic = true AND d.status = :status ORDER BY d.scheduledAt ASC")
    Page<DatePlan> findPublicDates(@Param("status") DateStatus status, Pageable pageable);

    // Find public dates with filters
    @Query("SELECT d FROM DatePlan d WHERE d.isPublic = true AND d.status = 'OPEN' " +
            "AND (:connectionType IS NULL OR d.connectionType = :connectionType) " +
            "ORDER BY d.scheduledAt ASC")
    Page<DatePlan> findPublicDatesByType(
            @Param("connectionType") ConnectionTypeEnum connectionType,
            Pageable pageable);

    // Find user's own dates
    Page<DatePlan> findByOwnerIdOrderByScheduledAtDesc(UUID ownerId, Pageable pageable);

    // Find user's dates by status
    Page<DatePlan> findByOwnerIdAndStatusOrderByScheduledAtDesc(
            UUID ownerId,
            DateStatus status,
            Pageable pageable);

    // Find dates where user is the partner
    Page<DatePlan> findByPartnerIdOrderByScheduledAtDesc(UUID partnerId, Pageable pageable);

    // Find accepted dates for a user (as owner or partner)
    @Query("SELECT d FROM DatePlan d WHERE d.status = 'ACCEPTED' AND (d.owner.id = :userId OR d.partner.id = :userId) ORDER BY d.scheduledAt ASC")
    List<DatePlan> findUpcomingDatesForUser(@Param("userId") UUID userId);

    // Count open dates by owner
    long countByOwnerIdAndStatus(UUID ownerId, DateStatus status);
}
