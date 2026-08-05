package com.orient.workshop.supervisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QcReviewRequest {
    private String action; // 'approve' or 'reject'
    private boolean checklistPassed;
    private String notes;
    private String rejectReason;
}
