package com.fyn_monolithic.controller.date;

import com.fyn_monolithic.dto.request.date.CreateDateRequest;
import com.fyn_monolithic.dto.request.date.ProposalRequest;
import com.fyn_monolithic.dto.response.date.DatePlanResponse;
import com.fyn_monolithic.dto.response.date.ProposalResponse;
import com.fyn_monolithic.model.date.ConnectionTypeEnum;
import com.fyn_monolithic.model.date.DateStatus;
import com.fyn_monolithic.security.CustomUserDetails;
import com.fyn_monolithic.service.date.DateService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/dates")
@RequiredArgsConstructor
public class DateController {

    private final DateService dateService;

    /**
     * Create a new date plan
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createDate(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CreateDateRequest request) {

        DatePlanResponse date = dateService.createDate(userDetails.getUser().getId(), request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", date));
    }

    /**
     * Get public dates for browsing
     */
    @GetMapping("/public")
    public ResponseEntity<Map<String, Object>> getPublicDates(
            @RequestParam(required = false) ConnectionTypeEnum type,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size);
        Page<DatePlanResponse> dates = dateService.getPublicDates(type, pageable);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", Map.of(
                        "content", dates.getContent(),
                        "page", dates.getNumber(),
                        "totalPages", dates.getTotalPages(),
                        "totalElements", dates.getTotalElements())));
    }

    /**
     * Get user's own dates
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getMyDates(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(required = false) DateStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size);
        Page<DatePlanResponse> dates = dateService.getMyDates(userDetails.getUser().getId(), status, pageable);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", Map.of(
                        "content", dates.getContent(),
                        "page", dates.getNumber(),
                        "totalPages", dates.getTotalPages())));
    }

    /**
     * Get date details
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getDateDetails(@PathVariable UUID id) {
        DatePlanResponse date = dateService.getDateDetails(id);
        return ResponseEntity.ok(Map.of("success", true, "data", date));
    }

    /**
     * Cancel a date
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> cancelDate(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        dateService.cancelDate(id, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true, "message", "Date cancelled"));
    }

    /**
     * Mark date as completed
     */
    @PatchMapping("/{id}/complete")
    public ResponseEntity<Map<String, Object>> completeDate(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        dateService.completeDate(id, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true, "message", "Date marked as completed"));
    }

    /**
     * Send a proposal to join a date
     */
    @PostMapping("/{id}/proposals")
    public ResponseEntity<Map<String, Object>> sendProposal(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody ProposalRequest request) {

        ProposalResponse proposal = dateService.sendProposal(id, userDetails.getUser().getId(), request);
        return ResponseEntity.ok(Map.of("success", true, "data", proposal));
    }

    /**
     * Get proposals for a date (owner only)
     */
    @GetMapping("/{id}/proposals")
    public ResponseEntity<Map<String, Object>> getProposals(
            @PathVariable UUID id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size);
        Page<ProposalResponse> proposals = dateService.getProposals(id, userDetails.getUser().getId(), pageable);

        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", Map.of(
                        "content", proposals.getContent(),
                        "page", proposals.getNumber())));
    }

    /**
     * Accept a proposal
     */
    @PatchMapping("/proposals/{proposalId}/accept")
    public ResponseEntity<Map<String, Object>> acceptProposal(
            @PathVariable UUID proposalId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        dateService.acceptProposal(proposalId, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true, "message", "Proposal accepted"));
    }

    /**
     * Reject a proposal
     */
    @PatchMapping("/proposals/{proposalId}/reject")
    public ResponseEntity<Map<String, Object>> rejectProposal(
            @PathVariable UUID proposalId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        dateService.rejectProposal(proposalId, userDetails.getUser().getId());
        return ResponseEntity.ok(Map.of("success", true, "message", "Proposal rejected"));
    }
}
