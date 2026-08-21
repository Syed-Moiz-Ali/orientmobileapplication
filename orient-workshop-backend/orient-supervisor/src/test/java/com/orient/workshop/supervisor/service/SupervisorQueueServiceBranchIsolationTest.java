package com.orient.workshop.supervisor.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.core.model.entity.Booking;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.*;
import com.orient.workshop.core.service.ActivityService;
import com.orient.workshop.core.service.JobWorkflowService;
import com.orient.workshop.core.service.NotificationService;
import com.orient.workshop.core.service.WebhookService;
import com.orient.workshop.owner.service.InvoiceService;
import com.orient.workshop.supervisor.model.dto.AssignAdvisorRequest;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

class SupervisorQueueServiceBranchIsolationTest {
    @Test
    void supervisorCannotAssignAdvisorFromAnotherBranch() {
        StaffMapper staffMapper = mock(StaffMapper.class);
        when(staffMapper.selectById(7L)).thenReturn(Staff.builder()
                .id(7L).branchId(2L).role("advisor").name("Other Branch Advisor").build());

        SupervisorQueueService service = service(staffMapper, mock(BookingMapper.class));

        assertThatThrownBy(() -> service.assignBooking(
                principal(1L), 99L, AssignAdvisorRequest.builder().advisorId(7L).build()))
                .isInstanceOf(ForbiddenException.class);
    }

    @Test
    void supervisorCannotAssignBookingFromAnotherBranch() {
        StaffMapper staffMapper = mock(StaffMapper.class);
        BookingMapper bookingMapper = mock(BookingMapper.class);
        when(staffMapper.selectById(7L)).thenReturn(Staff.builder()
                .id(7L).branchId(1L).role("advisor").name("Advisor").build());
        when(bookingMapper.selectById(99L)).thenReturn(Booking.builder()
                .id(99L).bookingRef("BK-99").branchId(2L).build());

        SupervisorQueueService service = service(staffMapper, bookingMapper);

        assertThatThrownBy(() -> service.assignBooking(
                principal(1L), 99L, AssignAdvisorRequest.builder().advisorId(7L).build()))
                .isInstanceOf(ForbiddenException.class);
        verify(bookingMapper, never()).updateById(any(Booking.class));
    }

    private SupervisorQueueService service(StaffMapper staffMapper, BookingMapper bookingMapper) {
        return new SupervisorQueueService(
                bookingMapper,
                mock(BreakdownMapper.class),
                mock(CustomerMapper.class),
                mock(VehicleMapper.class),
                staffMapper,
                mock(JobCardMapper.class),
                mock(TechnicianTaskMapper.class),
                mock(NotificationService.class),
                mock(InvoiceService.class),
                mock(ActivityService.class),
                mock(WebhookService.class),
                mock(JobWorkflowService.class));
    }

    private JwtUserPrincipal principal(Long branchId) {
        return JwtUserPrincipal.builder()
                .userId(10L)
                .role("SUPERVISOR")
                .branchId(branchId)
                .build();
    }
}
