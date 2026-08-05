package com.orient.workshop.owner.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.owner.model.dto.DocumentExpiryResponse;
import com.orient.workshop.owner.model.entity.EmployeeDocument;
import com.orient.workshop.owner.repository.EmployeeDocumentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OwnerDocumentService {

    private final EmployeeDocumentMapper employeeDocumentMapper;

    public List<DocumentExpiryResponse> getExpiringDocuments() {
        LocalDate now = LocalDate.now();
        return employeeDocumentMapper.selectList(
                        new QueryWrapper<EmployeeDocument>().orderByAsc("expiry_date"))
                .stream()
                .map(d -> {
                    int daysLeft = d.getExpiryDate() != null
                            ? (int) ChronoUnit.DAYS.between(now, d.getExpiryDate()) : 0;
                    return DocumentExpiryResponse.builder()
                            .empId(d.getEmpId() != null ? d.getEmpId() : "")
                            .employeeName(d.getEmployeeName() != null ? d.getEmployeeName() : "")
                            .designation(d.getDesignation() != null ? d.getDesignation() : "")
                            .documentType(d.getDocumentType() != null ? d.getDocumentType() : "")
                            .expiryDate(d.getExpiryDate() != null ? d.getExpiryDate().toString() : "")
                            .daysLeft(daysLeft)
                            .urgency(d.getUrgency() != null ? d.getUrgency() : "normal")
                            .build();
                })
                .collect(Collectors.toList());
    }
}
