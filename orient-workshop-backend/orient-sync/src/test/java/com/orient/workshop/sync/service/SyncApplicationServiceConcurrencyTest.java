package com.orient.workshop.sync.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.advisor.repository.RepairOrderPartMapper;
import com.orient.workshop.advisor.repository.RepairOrderServiceMapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.BookingMapper;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.supervisor.repository.WorkAssignmentMapper;
import com.orient.workshop.sync.model.entity.SyncLog;
import com.orient.workshop.sync.repository.SyncLogMapper;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class SyncApplicationServiceConcurrencyTest {
    @Test
    void concurrentRetryWithSameScopedKeyMutatesOnlyOnce() throws Exception {
        JobCardMapper jobCardMapper = mock(JobCardMapper.class);
        SyncLogMapper syncLogMapper = mock(SyncLogMapper.class);
        AtomicReference<SyncLog> storedLog = new AtomicReference<>();

        when(syncLogMapper.findByKey(any())).thenAnswer(invocation -> Optional.ofNullable(storedLog.get()));
        when(syncLogMapper.insert(any(SyncLog.class))).thenAnswer(invocation -> {
            SyncLog log = invocation.getArgument(0);
            log.setId(99L);
            storedLog.set(log);
            return 1;
        });
        when(jobCardMapper.selectById(77L)).thenAnswer(invocation ->
                JobCard.builder().id(77L).jobCardRef("JC-77").branchId(5L).status("inProgress").build());
        when(jobCardMapper.updateById(any(JobCard.class))).thenReturn(1);

        SyncApplicationService service = new SyncApplicationService(
                jobCardMapper,
                syncLogMapper,
                mock(InspectionMapper.class),
                mock(BookingMapper.class),
                mock(RepairOrderMapper.class),
                mock(RepairOrderServiceMapper.class),
                mock(RepairOrderPartMapper.class),
                mock(ApprovalMapper.class),
                mock(CustomerMapper.class),
                mock(WorkAssignmentMapper.class),
                new ObjectMapper());

        JwtUserPrincipal principal = JwtUserPrincipal.builder()
                .userId(10L).branchId(5L).role("TECHNICIAN").build();
        CountDownLatch start = new CountDownLatch(1);
        Callable<Map<String, String>> call = () -> {
            start.await(5, TimeUnit.SECONDS);
            return service.syncJobComplete(principal, "77", Map.of(), "same-key");
        };

        ExecutorService executor = Executors.newFixedThreadPool(2);
        try {
            var futures = List.of(executor.submit(call), executor.submit(call));
            start.countDown();
            Map<String, String> first = futures.get(0).get(5, TimeUnit.SECONDS);
            Map<String, String> second = futures.get(1).get(5, TimeUnit.SECONDS);

            assertThat(List.of(first, second))
                    .extracting(result -> result.getOrDefault("id", ""))
                    .containsOnly("99");
            assertThat(List.of(first, second))
                    .anySatisfy(result -> assertThat(result).containsEntry("replayed", "true"));
        } finally {
            executor.shutdownNow();
        }

        verify(syncLogMapper, times(1)).insert(any(SyncLog.class));
        verify(jobCardMapper, times(1)).updateById(any(JobCard.class));
    }
}
