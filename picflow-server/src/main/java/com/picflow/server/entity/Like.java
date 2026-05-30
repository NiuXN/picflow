package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 点赞记录实体，对应 likes 表，一对 (user_id, artwork_id) 唯一
 */
@Data
@TableName("likes")
public class Like {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 记录ID（雪花算法）

    private Long userId;                // 点赞用户ID
    private Long artworkId;             // 被点赞作品ID

    // 审计字段 - SQL 只有 created_at
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;   // 点赞时间
}
