package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 收藏记录实体，对应 favorites 表，一对 (user_id, artwork_id) 唯一
 */
@Data
@TableName("favorites")
public class Favorite {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 记录ID（雪花算法）

    private Long userId;                // 收藏用户ID
    private Long artworkId;             // 被收藏作品ID

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;    // 收藏时间
}
