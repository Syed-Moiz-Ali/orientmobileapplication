package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.RepairOrderRequest;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.repository.ApprovalMapper;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.advisor.repository.RepairOrderPartMapper;
import com.orient.workshop.advisor.repository.RepairOrderServiceMapper;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.InventoryItem;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.InventoryItemMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.service.NotificationService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RepairOrderServiceBillingTest {

    @Mock private RepairOrderMapper repairOrderMapper;
    @Mock private RepairOrderServiceMapper serviceMapper;
    @Mock private RepairOrderPartMapper partMapper;
    @Mock private JobCardMapper jobCardMapper;
    @Mock private CustomerMapper customerMapper;
    @Mock private ApprovalMapper approvalMapper;
    @Mock private NotificationService notificationService;
    @Mock private TaskGeneratorService taskGeneratorService;
    @Mock private InventoryItemMapper inventoryItemMapper;

    private RepairOrderService service() {
        return new RepairOrderService(repairOrderMapper, serviceMapper, partMapper,
                jobCardMapper, customerMapper, approvalMapper, notificationService,
                taskGeneratorService, inventoryItemMapper);
    }

    @Test
    void billing_plainLineItem_qtyTimesRate() {
        RepairOrderRequest req = reqWithService("Brake Pads", 2, 150.0, 0.0, 0.0);
        service().createRepairOrder(req);

        ArgumentCaptor<RepairOrder> captor = ArgumentCaptor.forClass(RepairOrder.class);
        verify(repairOrderMapper).updateById(captor.capture());
        RepairOrder updated = captor.getValue();

        assertThat(updated.getServicesTotal()).isEqualByComparingTo(300.0);
        assertThat(updated.getGrandTotal()).isEqualByComparingTo(300.0);
    }

    @Test
    void billing_percentDiscount_appliedCorrectly() {
        // 3 * 100 = 300, minus 10% = 270
        RepairOrderRequest req = reqWithService("Labour", 3, 100.0, 10.0, 0.0);
        service().createRepairOrder(req);

        ArgumentCaptor<RepairOrder> captor = ArgumentCaptor.forClass(RepairOrder.class);
        verify(repairOrderMapper).updateById(captor.capture());
        RepairOrder updated = captor.getValue();

        assertThat(updated.getServicesTotal()).isEqualByComparingTo(270.0);
    }

    @Test
    void billing_flatDiscount_appliedCorrectly() {
        // 2 * 200 = 400, minus 25 flat = 375
        RepairOrderRequest req = reqWithService("Oil Change", 2, 200.0, 0.0, 25.0);
        service().createRepairOrder(req);

        ArgumentCaptor<RepairOrder> captor = ArgumentCaptor.forClass(RepairOrder.class);
        verify(repairOrderMapper).updateById(captor.capture());
        RepairOrder updated = captor.getValue();

        assertThat(updated.getServicesTotal()).isEqualByComparingTo(375.0);
    }

    @Test
    void billing_discountNeverMakesTotalNegative() {
        // 1 * 30 = 30, minus 999 flat would be negative -> floored at 0
        RepairOrderRequest req = reqWithService("Wash", 1, 30.0, 0.0, 999.0);
        service().createRepairOrder(req);

        ArgumentCaptor<RepairOrder> captor = ArgumentCaptor.forClass(RepairOrder.class);
        verify(repairOrderMapper).updateById(captor.capture());
        RepairOrder updated = captor.getValue();

        assertThat(updated.getServicesTotal()).isEqualByComparingTo(0.0);
    }

    @Test
    void inventory_matchingPartByName_isDecremented() {
        RepairOrderRequest req = reqWithPart("Engine Oil", 2, 50.0);
        JobCard jc = jobCard(5L);
        when(jobCardMapper.selectById(1L)).thenReturn(jc);
        InventoryItem item = InventoryItem.builder().id(42L).qtyOnHand(10).build();
        when(inventoryItemMapper.findByNameAndBranch(5L, "Engine Oil")).thenReturn(Optional.of(item));
        when(inventoryItemMapper.decrementStock(42L, 2)).thenReturn(1);

        service().createRepairOrder(req);

        verify(inventoryItemMapper).decrementStock(42L, 2);
    }

    @Test
    void inventory_unmatchedPart_doesNotDecrement() {
        RepairOrderRequest req = reqWithPart("Custom Fabricated Part", 1, 500.0);
        when(jobCardMapper.selectById(1L)).thenReturn(jobCard(5L));
        when(inventoryItemMapper.findByNameAndBranch(5L, "Custom Fabricated Part")).thenReturn(Optional.empty());

        service().createRepairOrder(req);

        verify(inventoryItemMapper, never()).decrementStock(any(), anyInt());
    }

    private RepairOrderRequest reqWithService(String name, int qty, double rate, double discPct, double discAmt) {
        RepairOrderRequest req = new RepairOrderRequest();
        req.setJobCardId("1");
        req.setServices(List.of(lineItem(name, qty, rate, discPct, discAmt)));
        when(jobCardMapper.selectById(1L)).thenReturn(jobCard(1L));
        when(customerMapper.selectById(any())).thenReturn(Customer.builder().id(1L).userId(99L).build());
        return req;
    }

    private RepairOrderRequest reqWithPart(String name, int qty, double rate) {
        RepairOrderRequest req = new RepairOrderRequest();
        req.setJobCardId("1");
        req.setParts(List.of(lineItem(name, qty, rate, 0.0, 0.0)));
        when(jobCardMapper.selectById(1L)).thenReturn(jobCard(1L));
        when(customerMapper.selectById(any())).thenReturn(Customer.builder().id(1L).userId(99L).build());
        return req;
    }

    private RepairOrderRequest.LineItem lineItem(String name, int qty, double rate, double discPct, double discAmt) {
        return RepairOrderRequest.LineItem.builder()
                .name(name).qty(qty).rate(rate).discountPercent(discPct).discountAmount(discAmt).build();
    }

    private JobCard jobCard(Long branchId) {
        return JobCard.builder().id(1L).jobCardRef("JC-1").customerId(1L).branchId(branchId).build();
    }
}
