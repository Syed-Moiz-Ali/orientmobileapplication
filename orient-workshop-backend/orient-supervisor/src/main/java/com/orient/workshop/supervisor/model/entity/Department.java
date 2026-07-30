package com.orient.workshop.supervisor.model.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @TableName("departments")
public class Department {
    @TableId(type = IdType.AUTO) private Long id;
    private String name;
}
