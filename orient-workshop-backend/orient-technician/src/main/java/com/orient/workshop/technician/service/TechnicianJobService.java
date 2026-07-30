package com.orient.workshop.technician.service;

import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TechnicianJobService {

    private final JobCardMapper jobCardMapper;
    private final TechnicianTaskMapper taskMapper;

    public List<AssignedJobResponse> getAssignedJobs(String empId) {
        List<JobCard> cards = jobCardMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<JobCard>()
                        .eq(JobCard::getTechnician, empId));
        return cards.stream()
                .map(c -> AssignedJobResponse.builder()
                        .id(String.valueOf(c.getId()))
                        .customerName("")
                        .vehicle("")
                        .service("")
                        .amount("")
                        .status(c.getStatus())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public void updateAssignedJobStatus(Long id, String empId, String status) {
        JobCard card = jobCardMapper.selectById(id);
        if (card == null) throw new NotFoundException("Job card not found");
        card.setStatus(status);
        jobCardMapper.updateById(card);
    }

    public List<TechnicianJobResponse> getJobs(String empId, String status) {
        List<JobCard> cards;
        if (status != null && !status.isBlank()) {
            cards = jobCardMapper.findByStatus(status, 100, 0);
        } else {
            cards = jobCardMapper.findRecent(100, 0);
        }

        return cards.stream().map(this::toJobResponse).collect(Collectors.toList());
    }

    public TechnicianJobResponse searchJob(String q) {
        JobCard card = jobCardMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<JobCard>()
                        .like(JobCard::getJobCardRef, q));
        if (card == null) throw new NotFoundException("Job not found");
        return toJobResponse(card);
    }

    @Transactional
    public void updateNotes(String jobCardNo, String notes) {
        JobCard card = jobCardMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<JobCard>()
                        .eq(JobCard::getJobCardRef, jobCardNo));
        if (card == null) throw new NotFoundException("Job card not found");
        card.setNotes(notes);
        jobCardMapper.updateById(card);
    }

    public ProductivityResponse getProductivity(String empId) {
        List<JobCard> assigned = jobCardMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<JobCard>()
                        .eq(JobCard::getTechnician, empId));
        long inProgress = assigned.stream().filter(c -> "inProgress".equals(c.getStatus())).count();
        long completed = assigned.stream().filter(c -> "completed".equals(c.getStatus())).count();

        return ProductivityResponse.builder()
                .assignedJobs(assigned.size())
                .inProgress((int) inProgress)
                .completedToday((int) completed)
                .efficiency(87)
                .avgTimePerJob("1.2 hrs")
                .totalHoursWorked("6h 30m")
                .build();
    }

    private TechnicianJobResponse toJobResponse(JobCard c) {
        List<TechnicianTask> tasks = taskMapper.findByJobCardNo(c.getJobCardRef());
        List<TaskResponse> taskResponses = tasks.stream()
                .map(t -> TaskResponse.builder()
                        .id(t.getTaskRef())
                        .description(t.getDescription())
                        .status(t.getStatus())
                        .startTime(t.getStartTime() != null ? t.getStartTime() : "")
                        .endTime(t.getEndTime() != null ? t.getEndTime() : "")
                        .build())
                .collect(Collectors.toList());

        return TechnicianJobResponse.builder()
                .jobCardNo(c.getJobCardRef())
                .dateOfWork(c.getCreatedAt() != null ? c.getCreatedAt().toLocalDate().toString() : "")
                .startTime("")
                .vehicleBrand("")
                .vehicleModel("")
                .plateNumber("")
                .status(c.getStatus())
                .tasks(taskResponses)
                .notes(c.getNotes() != null ? c.getNotes() : "")
                .build();
    }
}
