package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("tags")
public class Tag {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;
    private String description;
    private Integer sortOrder;
    private Boolean enabled;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
