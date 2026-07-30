package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.JobCard;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Optional;

@Mapper
public interface JobCardMapper extends BaseMapper<JobCard> {

    @Select("SELECT * FROM job_cards WHERE customer_id = #{customerId} AND status IN ('inProgress', 'pendingApproval', 'qualityCheck', 'waitingParts') ORDER BY created_at DESC LIMIT 1")
    Optional<JobCard> findActiveByCustomerId(@Param("customerId") Long customerId);

    @Select("SELECT * FROM job_cards ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<JobCard> findRecent(@Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT * FROM job_cards WHERE status = #{status} ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<JobCard> findByStatus(@Param("status") String status, @Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT COUNT(*) FROM job_cards")
    long countAll();

    @Select("SELECT COUNT(*) FROM job_cards WHERE DATE(created_at) = CURDATE()")
    int countToday();

    @Select("SELECT COUNT(*) FROM job_cards WHERE status IN ('inProgress','pendingApproval','qualityCheck','waitingParts','pending')")
    int countOpen();

    @Select("SELECT COUNT(*) FROM job_cards WHERE status = 'completed' AND DATE(created_at) = CURDATE()")
    int countCompletedToday();

    @Select("SELECT COUNT(*) FROM job_cards WHERE status = 'inProgress'")
    int countInProgress();

    @Select("SELECT COUNT(*) FROM job_cards WHERE status = 'cancelled'")
    int countCancelled();
}
