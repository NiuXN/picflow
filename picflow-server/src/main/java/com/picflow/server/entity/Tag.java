package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 标签实体，对应 tags 表
 */
@Data
@TableName("tags")
public class Tag {

    @TableId(type = IdType.AUTO)
    private Long id;                    // 标签ID，自增

    private String name;               // 标签名称
    private String description;         // 标签描述
    private Integer sortOrder;         // 排序顺序
    private Boolean enabled;           // 是否启用

    // 审计字段
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;  // 创建时间
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;  // 更新时间
}
