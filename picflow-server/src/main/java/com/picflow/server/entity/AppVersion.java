package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * App 版本管理实体，对应 app_versions 表
 * 支持：渠道管理、灰度发布、版本区间、热更新
 */
@Data
@TableName("app_versions")
public class AppVersion {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 版本ID（雪花算法）

    private String versionName;         // 版本号，如 1.0.0
    private Integer versionCode;        // 版本码，递增比较
    private String channel;             // 渠道：stable/beta/alpha
    private Integer grayPercent;       // 灰度比例 0-100，100=全量
    private Integer minVersionCode;     // 适用版本下限，低于此强制更新
    private Integer maxVersionCode;    // 适用版本上限，高于此忽略
    private Boolean forceUpdate;       // 是否强制更新
    private String description;        // 简短更新说明
    private String releaseNotes;      // 详细发布日志（Markdown）
    private String downloadUrl;       // 安装包下载链接
    private String hotfixUrl;         // 热更新补丁链接（Shorebird）
    private String platform;           // 目标平台：all/android/ios
    private Boolean enabled;           // 是否启用

    // 审计字段
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;   // 发布时间
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;   // 更新时间
}
