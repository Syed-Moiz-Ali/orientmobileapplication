package com.orient.workshop.crm.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.crm.model.entity.LeadActivity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface LeadActivityMapper extends BaseMapper<LeadActivity> {

    @Select("SELECT * FROM lead_activities WHERE lead_id = #{leadId} ORDER BY id DESC LIMIT 50")
    List<LeadActivity> findByLeadId(@Param("leadId") Long leadId);
}
