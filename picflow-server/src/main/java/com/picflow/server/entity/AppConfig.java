package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("app_configs")
public class AppConfig {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String configType;
    private String configKey;
    private String configValue;
    private String label;
    private String description;
    private Integer sortOrder;
    private Boolean enabled;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
