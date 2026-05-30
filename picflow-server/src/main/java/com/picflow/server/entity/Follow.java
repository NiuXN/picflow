package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 关注关系实体，对应 follows 表
 */
@Data
@TableName("follows")
public class Follow {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 记录ID

    private Long followerId;            // 关注者用户ID
    private Long followingId;           // 被关注者用户ID

    // 审计字段 - SQL 只有 created_at
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;   // 关注时间
}
