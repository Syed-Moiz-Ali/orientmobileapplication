package com.orient.workshop.owner.service;

import com.orient.workshop.owner.model.dto.ApprovalCategoryResponse;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OwnerApprovalService {

    public List<ApprovalCategoryResponse> getApprovalCategories() {
        return List.of(
            cat("Purchase Order", "Pending your approval", 3),
            cat("Open Job Card", "Awaiting review", 5),
            cat("WIP", "In progress jobs", 2),
            cat("Job Completed x3", "Ready for QC", 4),
            cat("Job Cancelled", "Cancellation requests", 1),
            cat("Invoice Raised", "Pending payment", 6),
            cat("Sales Return", "Return requests", 2),
            cat("Purchase Return", "Return to supplier", 1),
            cat("Petty Cash", "Cash requests", 3),
            cat("Journal Voucher", "Accounting entries", 2),
            cat("Job Card to Invoice", "Ready to invoice", 7)
        );
    }

    private ApprovalCategoryResponse cat(String title, String subtitle, int count) {
        return ApprovalCategoryResponse.builder().title(title).subtitle(subtitle).count(count).build();
    }
}
