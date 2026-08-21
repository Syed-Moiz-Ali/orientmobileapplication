package com.orient.workshop.core.service;

import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

class JobWorkflowServiceTest {

    @Test
    void approveQcRequiresAllWorkItemsComplete() {
        TechnicianTaskMapper taskMapper = mock(TechnicianTaskMapper.class);
        JobWorkflowService service = service(taskMapper, List.of(mock(JobInvoiceGateway.class)));
        JobCard card = JobCard.builder().id(10L).jobCardRef("JC-10").branchId(1L)
                .status(JobWorkflowService.AWAITING_QC).build();
        when(jobCardMapper(service).selectById(10L)).thenReturn(card);
        when(taskMapper.countTotal("JC-10")).thenReturn(2L);
        when(taskMapper.countIncomplete("JC-10")).thenReturn(1L);

        assertThatThrownBy(() -> service.approveQc(10L, 1L, 99L))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("all technician work items");
    }

    @Test
    void approveQcMovesToReadyForCollectionAndCreatesInvoice() {
        TechnicianTaskMapper taskMapper = mock(TechnicianTaskMapper.class);
        JobInvoiceGateway invoiceGateway = mock(JobInvoiceGateway.class);
        JobWorkflowService service = service(taskMapper, List.of(invoiceGateway));
        JobCard card = JobCard.builder().id(10L).jobCardRef("JC-10").branchId(1L)
                .status(JobWorkflowService.AWAITING_QC).build();
        when(jobCardMapper(service).selectById(10L)).thenReturn(card);
        when(taskMapper.countTotal("JC-10")).thenReturn(2L);
        when(taskMapper.countIncomplete("JC-10")).thenReturn(0L);

        service.approveQc(10L, 1L, 99L);

        verify(jobCardMapper(service)).updateById(argThat((JobCard updated) ->
                JobWorkflowService.READY_FOR_COLLECTION.equals(updated.getStatus())));
        verify(invoiceGateway).createFromJobCard(10L);
    }

    @Test
    void deliveryCannotBypassQcApproval() {
        JobWorkflowService service = service(mock(TechnicianTaskMapper.class), List.of());
        JobCard card = JobCard.builder().id(10L).jobCardRef("JC-10").branchId(1L)
                .status(JobWorkflowService.AWAITING_QC).build();
        when(jobCardMapper(service).selectById(10L)).thenReturn(card);

        assertThatThrownBy(() -> service.deliverById(10L, 1L, 99L))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("successful QC");
    }

    private JobWorkflowService service(TechnicianTaskMapper taskMapper, List<JobInvoiceGateway> invoiceGateways) {
        JobCardMapper jobCardMapper = mock(JobCardMapper.class);
        return new TestableJobWorkflowService(
                jobCardMapper,
                taskMapper,
                mock(StaffMapper.class),
                mock(CustomerMapper.class),
                mock(NotificationService.class),
                mock(ActivityService.class),
                mock(WebhookService.class),
                invoiceGateways);
    }

    private JobCardMapper jobCardMapper(JobWorkflowService service) {
        return ((TestableJobWorkflowService) service).jobCardMapper;
    }

    private static class TestableJobWorkflowService extends JobWorkflowService {
        private final JobCardMapper jobCardMapper;

        TestableJobWorkflowService(JobCardMapper jobCardMapper,
                                   TechnicianTaskMapper taskMapper,
                                   StaffMapper staffMapper,
                                   CustomerMapper customerMapper,
                                   NotificationService notificationService,
                                   ActivityService activityService,
                                   WebhookService webhookService,
                                   List<JobInvoiceGateway> invoiceGateways) {
            super(jobCardMapper, taskMapper, staffMapper, customerMapper,
                    notificationService, activityService, webhookService, invoiceGateways);
            this.jobCardMapper = jobCardMapper;
        }
    }
}
