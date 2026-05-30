package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 作品-标签关联实体，对应 artwork_tags 表
 */
@Data
@TableName("artwork_tags")
public class ArtworkTag {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 记录ID（雪花算法）

    private Long artworkId;             // 作品ID
    private String tag;                 // 标签名

    // 审计字段
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;   // 创建时间
}
