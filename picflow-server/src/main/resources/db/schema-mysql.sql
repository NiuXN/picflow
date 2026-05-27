-- PicFlow MySQL Schema
-- MySQL 8.0+ Required

CREATE DATABASE IF NOT EXISTS picflow DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE picflow;

-- ========== 用户表 ==========
CREATE TABLE IF NOT EXISTS users (
    id            BIGINT PRIMARY KEY COMMENT '用户ID（雪花算法）',
    username      VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名，唯一',
    password_hash VARCHAR(255) NOT NULL COMMENT 'BCrypt 加密密码',
    phone         VARCHAR(20) UNIQUE COMMENT '手机号，唯一',
    phone_verified TINYINT(1) DEFAULT 0 COMMENT '手机号是否已验证',
    nickname      VARCHAR(100) DEFAULT 'PicFlow用户' COMMENT '用户昵称',
    avatar_url    VARCHAR(500) COMMENT '头像URL',
    bio           VARCHAR(500) COMMENT '个人简介',
    role          VARCHAR(20) DEFAULT 'user' COMMENT '角色：user普通用户 / admin管理员',
    status        VARCHAR(20) DEFAULT 'active' COMMENT '状态：active正常 / banned封禁',
    deleted       TINYINT(1) DEFAULT 0 COMMENT '逻辑删除：0正常 1删除',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_users_status (status) COMMENT '用户状态索引',
    INDEX idx_users_created (created_at) COMMENT '注册时间索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ========== 作品表 ==========
CREATE TABLE IF NOT EXISTS artworks (
    id              BIGINT PRIMARY KEY COMMENT '作品ID（雪花算法）',
    user_id         BIGINT NOT NULL COMMENT '作者用户ID',
    FOREIGN KEY (user_id) REFERENCES users(id),
    title           VARCHAR(200) NOT NULL COMMENT '作品标题',
    description     TEXT COMMENT '作品描述',
    image_url       VARCHAR(500) NOT NULL COMMENT '原图URL',
    thumbnail_url   VARCHAR(500) COMMENT '缩略图URL(300px宽)',
    tags            JSON DEFAULT ('[]') COMMENT '标签 JSON数组',
    frame_type      VARCHAR(50) COMMENT '相框类型：minimal/exif/polaroid/proFilm/circle',
    aspect_ratio    VARCHAR(20) COMMENT '画面比例：3x4/1x1/9x16',
    bg_color        VARCHAR(10) COMMENT '背景色 Hex值',
    watermark_text  VARCHAR(200) COMMENT '水印文字',
    filter          VARCHAR(50) COMMENT '滤镜：none/cream/film/mono/warm/cool/retro',
    likes_count     INT DEFAULT 0 COMMENT '点赞数',
    favorites_count INT DEFAULT 0 COMMENT '收藏数',
    views_count     INT DEFAULT 0 COMMENT '浏览数',
    comments_count  INT DEFAULT 0 COMMENT '评论数',
    status          VARCHAR(20) DEFAULT 'published' COMMENT '状态：published已发布/review审核中/removed已下架',
    is_featured     TINYINT(1) DEFAULT 0 COMMENT '是否精选：0否 1是',
    deleted         TINYINT(1) DEFAULT 0 COMMENT '逻辑删除：0正常 1删除',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_artworks_user (user_id) COMMENT '作者索引',
    INDEX idx_artworks_status (status) COMMENT '状态索引',
    INDEX idx_artworks_created (created_at) COMMENT '创建时间索引',
    INDEX idx_artworks_featured (is_featured, created_at) COMMENT '精选+时间复合索引',
    FULLTEXT INDEX ft_artworks_title (title) COMMENT '标题全文搜索'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作品表';

-- ========== 作品标签关联表 ==========
CREATE TABLE IF NOT EXISTS artwork_tags (
    id          BIGINT PRIMARY KEY COMMENT '记录ID（雪花算法）',
    artwork_id  BIGINT NOT NULL COMMENT '作品ID',
    tag         VARCHAR(100) NOT NULL COMMENT '标签名称',
    UNIQUE KEY uk_artwork_tag (artwork_id, tag),
    INDEX idx_tag (tag) COMMENT '标签名索引',
    FOREIGN KEY (artwork_id) REFERENCES artworks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作品标签关联表';

-- ========== 点赞表 ==========
CREATE TABLE IF NOT EXISTS likes (
    id          BIGINT PRIMARY KEY COMMENT '点赞记录ID（雪花算法）',
    user_id     BIGINT NOT NULL COMMENT '点赞用户ID',
    artwork_id  BIGINT NOT NULL COMMENT '被点赞作品ID',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    UNIQUE KEY uk_likes (user_id, artwork_id) COMMENT '同一用户对同一作品只能点赞一次',
    INDEX idx_likes_artwork (artwork_id) COMMENT '作品点赞索引',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artworks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞记录表';

-- ========== 收藏表 ==========
CREATE TABLE IF NOT EXISTS favorites (
    id          BIGINT PRIMARY KEY COMMENT '收藏记录ID（雪花算法）',
    user_id     BIGINT NOT NULL COMMENT '收藏用户ID',
    artwork_id  BIGINT NOT NULL COMMENT '被收藏作品ID',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    UNIQUE KEY uk_favorites (user_id, artwork_id) COMMENT '同一用户对同一作品只能收藏一次',
    INDEX idx_favorites_artwork (artwork_id) COMMENT '作品收藏索引',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artworks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏记录表';

-- ========== 评论表 ==========
CREATE TABLE IF NOT EXISTS comments (
    id          BIGINT PRIMARY KEY COMMENT '评论ID（雪花算法）',
    user_id     BIGINT NOT NULL COMMENT '评论用户ID',
    artwork_id  BIGINT NOT NULL COMMENT '所属作品ID',
    content     TEXT NOT NULL COMMENT '评论内容',
    parent_id   BIGINT COMMENT '父评论ID(支持回复)',
    status      VARCHAR(20) DEFAULT 'published' COMMENT '状态：published已发布',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
    INDEX idx_comments_artwork (artwork_id, created_at) COMMENT '作品评论列表索引',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artworks(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- ========== 通知/公告表 ==========
CREATE TABLE IF NOT EXISTS notifications (
    id          BIGINT PRIMARY KEY COMMENT '通知ID（雪花算法）',
    title       VARCHAR(200) NOT NULL COMMENT '通知标题',
    content     TEXT COMMENT '通知内容',
    target      VARCHAR(20) DEFAULT 'all' COMMENT '推送目标：all全部 / user_id指定用户',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    INDEX idx_notifications_target (target, created_at) COMMENT '推送目标+时间索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知/公告表';

-- ========== App 版本管理表 ==========
CREATE TABLE IF NOT EXISTS app_versions (
    id              BIGINT PRIMARY KEY COMMENT '版本ID（雪花算法）',
    version_name    VARCHAR(50) NOT NULL COMMENT '版本号，如 1.0.0',
    version_code    INT NOT NULL COMMENT '版本码，递增比较',
    channel         VARCHAR(20) DEFAULT 'stable' COMMENT '发布渠道：stable稳定版/beta测试版/alpha内部版',
    gray_percent    INT DEFAULT 100 COMMENT '灰度比例 0-100，100=全量发布',
    min_version_code INT DEFAULT 0 COMMENT '适用版本下限，低于此版本强制更新',
    max_version_code INT DEFAULT 999999 COMMENT '适用版本上限，高于此版本不弹提示',
    force_update    TINYINT(1) DEFAULT 0 COMMENT '是否强制更新：0否 1是',
    description     TEXT COMMENT '更新说明（简短）',
    release_notes   TEXT COMMENT '详细发布日志（Markdown）',
    download_url    VARCHAR(500) COMMENT '安装包下载链接',
    hotfix_url      VARCHAR(500) COMMENT '热更新补丁链接（Shorebird）',
    platform        VARCHAR(20) DEFAULT 'all' COMMENT '目标平台：all/android/ios',
    enabled         TINYINT(1) DEFAULT 1 COMMENT '是否启用：0下架 1启用',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='App版本管理表';

-- ========== 种子数据 ==========
-- 密码均为 "password123" 的 BCrypt 哈希
-- 使用 IGNORE 防止重复重启时插入失败
INSERT IGNORE INTO users (id, username, password_hash, nickname, role) VALUES
(1, 'admin', '$2b$10$cUkJeRh7KjzggFoO6Tz0c.DbLLL2jVzpXK9vlhfs808xChROXA5SK', '管理员', 'admin'),
(2, 'demo', '$2b$10$cUkJeRh7KjzggFoO6Tz0c.DbLLL2jVzpXK9vlhfs808xChROXA5SK', '演示用户', 'user');
