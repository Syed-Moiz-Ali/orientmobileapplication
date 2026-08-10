package com.orient.workshop.common.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import com.orient.workshop.common.util.IdGenerator;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;
import java.util.Map;

@Configuration
public class MyBatisPlusConfig implements MetaObjectHandler {

    // P1 (V13): prefixed unique refs. On INSERT the entity's `ref` field is
    // auto-filled with the type prefix + short alphanumeric suffix, e.g.
    // "CUST-3f9a2c1d". Entities without a ref field are untouched.
    // The accounts table (users) is intentionally NOT listed — the product
    // has no User entity; ids belong to customer (CUST-), staff (emp_id),
    // owner and CRM accounts.
    private static final Map<String, String> REF_PREFIX = Map.ofEntries(
            Map.entry("Customer", "CUST"),
            Map.entry("Vehicle", "VEH"),
            Map.entry("ServiceType", "ST"),
            Map.entry("Notification", "NTF"),
            Map.entry("Message", "MSG"),
            Map.entry("WhatsAppMessage", "WM"),
            Map.entry("Approval", "APP"),
            Map.entry("RepairOrder", "RO"),
            Map.entry("RepairOrderServiceItem", "ROS"),
            Map.entry("RepairOrderPartItem", "ROP"),
            Map.entry("Attendance", "AT"),
            Map.entry("ActivityLog", "AL"),
            Map.entry("EmployeeDocument", "DOC"),
            Map.entry("CrmConversation", "CV"),
            Map.entry("CrmTask", "CT"),
            Map.entry("CrmIntegration", "CI"),
            Map.entry("LeadActivity", "LA"),
            Map.entry("Branch", "BR"),
            Map.entry("Department", "DEPT"),
            Map.entry("Supplier", "SUP"),
            Map.entry("InventoryItem", "ITM"),
            Map.entry("PurchaseOrderItem", "POI"),
            Map.entry("Feedback", "FB"),
            Map.entry("DeviceToken", "DT"),
            Map.entry("WebhookSubscription", "WH"),
            Map.entry("ApiKey", "KEY"),
            Map.entry("Subscription", "SUB")
    );

    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createdAt", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
        // P1 (V13): prefixed unique ref — strictInsertFill works with the
        // @TableField(fill = FieldFill.INSERT) annotation on the entity field
        // (same mechanism as createdAt).
        final String prefix = REF_PREFIX.get(metaObject.getOriginalObject().getClass().getSimpleName());
        if (prefix != null) {
            this.strictInsertFill(metaObject, "ref", String.class, IdGenerator.shortRef(prefix));
        }
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
    }
}
