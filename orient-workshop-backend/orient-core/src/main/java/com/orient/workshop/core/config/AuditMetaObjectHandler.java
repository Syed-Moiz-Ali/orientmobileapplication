package com.orient.workshop.core.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import com.orient.workshop.common.util.IdGenerator;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class AuditMetaObjectHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        LocalDateTime now = LocalDateTime.now();
        this.strictInsertFill(metaObject, "createdAt", LocalDateTime.class, now);
        this.strictInsertFill(metaObject, "updatedAt", LocalDateTime.class, now);

        if (metaObject.hasSetter("ref")) {
            Object currentRef = metaObject.getValue("ref");
            if (currentRef == null) {
                String className = metaObject.getOriginalObject().getClass().getSimpleName().toUpperCase();
                String prefix = className.length() > 3 ? className.substring(0, 3) : className;
                this.setFieldValByName("ref", IdGenerator.shortRef(prefix), metaObject);
            }
        }

        if (metaObject.hasSetter("taskRef")) {
            Object currentTaskRef = metaObject.getValue("taskRef");
            if (currentTaskRef == null) {
                this.setFieldValByName("taskRef", IdGenerator.shortRef("T"), metaObject);
            }
        }
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
    }
}
