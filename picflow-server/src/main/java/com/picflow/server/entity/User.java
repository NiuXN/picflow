package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户实体，对应 users 表
 */
@Data
@TableName("users")
public class User {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 用户ID

    private String username;            // 用户名（唯一）

    @JsonIgnore
    private String passwordHash;        // BCrypt 加密密码（不序列化返回）
    private String phone;               // 手机号
    private Boolean phoneVerified;       // 手机号是否已验证

    // ========================================
    // 第三方登录字段
    // ========================================
    private String wechatOpenId;         // 微信 OpenId
    private String wechatUnionId;        // 微信 UnionId
    private String appleOpenId;          // Apple OpenId
    private String googleOpenId;         // Google OpenId

    private String nickname;            // 昵称
    private String avatarUrl;           // 头像URL
    private String bio;                 // 个人简介
    private String role;                // 角色：user/admin
    private String status;              // 状态：active/banned
    @TableLogic
    private Integer deleted;            // 逻辑删除：0正常 1删除

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;    // 注册时间

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;    // 更新时间
}
