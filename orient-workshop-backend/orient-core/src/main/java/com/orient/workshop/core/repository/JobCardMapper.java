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

    @Select("SELECT * FROM job_cards WHERE job_card_ref LIKE CONCAT('%',#{search},'%') ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<JobCard> searchCards(@Param("search") String search, @Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT * FROM job_cards WHERE branch_id = #{branchId} ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<JobCard> findRecentByBranch(@Param("branchId") Long branchId, @Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT * FROM job_cards WHERE branch_id = #{branchId} AND status = #{status} ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<JobCard> findByStatusAndBranch(@Param("status") String status, @Param("branchId") Long branchId, @Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT * FROM job_cards WHERE branch_id = #{branchId} AND job_card_ref LIKE CONCAT('%',#{search},'%') ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<JobCard> searchCardsByBranch(@Param("search") String search, @Param("branchId") Long branchId, @Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT COUNT(*) FROM job_cards")
    long countAll();

    @Select("SELECT COUNT(*) FROM job_cards WHERE branch_id = #{branchId}")
    long countAllByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COUNT(*) FROM job_cards WHERE status = #{status}")
    long countByStatus(@Param("status") String status);

    @Select("SELECT COUNT(*) FROM job_cards WHERE status = #{status} AND branch_id = #{branchId}")
    long countByStatusAndBranch(@Param("status") String status, @Param("branchId") Long branchId);

    @Select("SELECT COUNT(*) FROM job_cards WHERE job_card_ref LIKE CONCAT('%',#{search},'%')")
    long countSearch(@Param("search") String search);

    @Select("SELECT COUNT(*) FROM job_cards WHERE job_card_ref LIKE CONCAT('%',#{search},'%') AND branch_id = #{branchId}")
    long countSearchByBranch(@Param("search") String search, @Param("branchId") Long branchId);

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
