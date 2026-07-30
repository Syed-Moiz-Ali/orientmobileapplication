package com.orient.workshop.supervisor.service;

import com.orient.workshop.supervisor.repository.DepartmentMapper;
import com.orient.workshop.core.repository.StaffMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReferenceDataService {

    private final DepartmentMapper departmentMapper;
    private final StaffMapper staffMapper;

    public List<String> getDepartments() {
        return departmentMapper.findAllNames();
    }

    public List<String> getTechnicians() {
        return staffMapper.selectList(null).stream()
                .filter(s -> "technician".equals(s.getRole()) && Boolean.TRUE.equals(s.getIsActive()))
                .map(s -> s.getName())
                .collect(Collectors.toList());
    }
}
