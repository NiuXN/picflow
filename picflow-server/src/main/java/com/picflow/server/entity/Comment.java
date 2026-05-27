package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 评论实体，对应 comments 表，支持嵌套回复
 */
@Data
@TableName("comments")
public class Comment {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 评论ID（雪花算法）

    private Long userId;                // 评论用户ID
    private Long artworkId;             // 所属作品ID
    private String content;             // 评论内容
    private Long parentId;              // 父评论ID（支持回复）
    private String status;              // 状态：published

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;    // 评论时间

    @TableField(exist = false)
    private List<Comment> replies;      // 子回复列表（非数据库字段）
}
