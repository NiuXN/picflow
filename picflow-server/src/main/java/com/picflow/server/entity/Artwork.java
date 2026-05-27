package com.picflow.server.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonRawValue;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 作品实体，对应 artworks 表
 */
@Data
@TableName("artworks")
public class Artwork {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;                    // 作品ID（雪花算法）

    private Long userId;                // 作者用户ID
    private String title;               // 作品标题
    private String description;         // 作品描述
    private String imageUrl;            // 原图URL
    private String thumbnailUrl;        // 缩略图URL (300px)
    @JsonRawValue
    private String tags;                // 标签 JSON 字符串
    private String frameType;           // 相框类型：minimal/exif/polaroid/proFilm/circle
    private String aspectRatio;         // 画面比例：3x4/1x1/9x16
    private String bgColor;             // 背景色Hex
    private String watermarkText;       // 水印文字
    private String filter;              // 滤镜：none/cream/film/mono/warm/cool/retro
    private Integer likesCount;         // 点赞数
    private Integer favoritesCount;     // 收藏数
    private Integer viewsCount;         // 浏览数
    private Integer commentsCount;      // 评论数
    private String status;              // 状态：published/review/removed
    private Boolean isFeatured;         // 是否精选
    private Integer deleted;            // 逻辑删除：0正常 1删除

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;    // 创建时间

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;    // 更新时间

    @TableField(exist = false)
    private Boolean isLiked;            // 当前用户是否已点赞（非数据库字段）

    @TableField(exist = false)
    private Boolean isFavorited;        // 当前用户是否已收藏（非数据库字段）
}
