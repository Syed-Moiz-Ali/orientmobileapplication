package com.orient.workshop.advisor.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.advisor.model.dto.AdvisorStatsResponse;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.BookingMapper;
import com.orient.workshop.core.repository.BreakdownMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.StaffMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdvisorStatsService {

    private final JobCardMapper jobCardMapper;
    private final ApprovalMapper approvalMapper;
    private final InspectionMapper inspectionMapper;
    private final BookingMapper bookingMapper;
    private final BreakdownMapper breakdownMapper;
    private final StaffMapper staffMapper;

    public AdvisorStatsResponse getStats(JwtUserPrincipal principal) {
        long inspectionsToday = inspectionMapper.selectCount(
                new QueryWrapper<Inspection>().apply("DATE(created_at) = CURDATE()"));
        long vehiclesWaiting = jobCardMapper.selectCount(
                new QueryWrapper<JobCard>().eq("status", "pending"));
        long readyForDelivery = jobCardMapper.selectCount(
                new QueryWrapper<JobCard>().eq("status", "completed"));

        int newAssignedBookings = 0;
        int newBreakdowns = 0;
        if (principal != null && principal.getUserId() != null) {
            Staff me = staffMapper.findByUserId(principal.getUserId()).orElse(null);
            if (me != null) {
                newAssignedBookings = bookingMapper.findOpenByAdvisorId(me.getId()).size();
                newBreakdowns = breakdownMapper.findByAdvisorId(me.getId()).stream()
                        .filter(b -> "dispatched".equals(b.getStatus())).toList().size();
            }
        }

        return AdvisorStatsResponse.builder()
                .newJobCardsToday(jobCardMapper.countToday())
                .inspectionsToday((int) inspectionsToday)
                .pendingApprovals((int) approvalMapper.findPending().size())
                .vehiclesWaiting((int) vehiclesWaiting)
                .readyForDelivery((int) readyForDelivery)
                .totalOpenJobCards(jobCardMapper.countOpen())
                .newAssignedBookings(newAssignedBookings)
                .newBreakdowns(newBreakdowns)
                .build();
    }
}
