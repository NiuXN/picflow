package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 通知/公告实体，对应 notifications 表
 */
@Data
@TableName("notifications")
public class Notification {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 通知ID（雪花算法）

    private String title;               // 通知标题
    private String content;             // 通知内容
    private String target;              // 推送目标：all/用户ID
    private String status;              // 状态：published

    // 审计字段
    @TableLogic
    private Integer deleted;            // 逻辑删除：0-正常 1-删除
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;   // 发布时间
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;   // 更新时间
}
