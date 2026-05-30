-- ===============================================================
-- PicFlow 数据库初始化脚本 v2.0
-- 数据库名: picflow
-- 字符集: utf8mb4
-- 排序规则: utf8mb4_unicode_ci
-- 创建时间: 2024
-- 版本说明: v2.0 统一所有表的公共字段
-- ===============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS picflow
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE picflow;

-- ===============================================================
-- 公共字段规范说明:
-- -------------------------------------------------------------------------
-- 1. 所有表统一审计字段:
--    - created_at: 创建时间，自动填充 CURRENT_TIMESTAMP
--    - updated_at: 更新时间，自动更新 CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
--    - deleted: 逻辑删除标记 (0-正常 1-删除)
--
-- 2. 状态字段规范:
--    - 业务表使用: status (VARCHAR) - 如 published/review/removed
--    - 配置表使用: enabled (TINYINT) - 如 0-禁用 1-启用
--
-- 3. ID生成策略:
--    - 雪花算法: ASSIGN_ID (BIGINT UNSIGNED)
--    - 自增ID: AUTO_INCREMENT (BIGINT UNSIGNED)
-- ===============================================================


-- ===============================================================
-- 1. 用户表 (users) - 业务表
-- 公共字段: created_at, updated_at, deleted, status
-- ===============================================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    -- 业务字段
    id              BIGINT UNSIGNED NOT NULL COMMENT '用户ID，雪花算法生成',
    username        VARCHAR(50) NOT NULL COMMENT '用户名，唯一标识',
    password_hash   VARCHAR(255) NOT NULL COMMENT 'BCrypt加密后的密码',
    phone           VARCHAR(20) DEFAULT NULL COMMENT '手机号',
    phone_verified  TINYINT(1) DEFAULT 0 COMMENT '手机号是否已验证：0-未验证 1-已验证',
    nickname        VARCHAR(100) DEFAULT NULL COMMENT '用户昵称',
    avatar_url      VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
    bio             VARCHAR(500) DEFAULT NULL COMMENT '个人简介',

    -- 第三方登录字段
    wechat_open_id  VARCHAR(100) DEFAULT NULL COMMENT '微信OpenId',
    wechat_union_id VARCHAR(100) DEFAULT NULL COMMENT '微信UnionId',
    apple_open_id   VARCHAR(100) DEFAULT NULL COMMENT 'Apple OpenId',
    google_open_id VARCHAR(100) DEFAULT NULL COMMENT 'Google OpenId',

    -- 状态字段
    role            VARCHAR(20) DEFAULT 'user' COMMENT '角色：user-普通用户 admin-管理员',
    status          VARCHAR(20) DEFAULT 'active' COMMENT '状态：active-正常 banned-封禁',

    -- 审计字段 (统一)
    deleted         TINYINT(1) DEFAULT 0 COMMENT '逻辑删除：0-正常 1-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_wechat_open_id (wechat_open_id),
    UNIQUE KEY uk_apple_open_id (apple_open_id),
    UNIQUE KEY uk_google_open_id (google_open_id),
    KEY idx_phone (phone),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';


-- ===============================================================
-- 2. 作品表 (artworks) - 业务表
-- 公共字段: created_at, updated_at, deleted, status
-- ===============================================================
DROP TABLE IF EXISTS artworks;
CREATE TABLE artworks (
    -- 业务字段
    id              BIGINT UNSIGNED NOT NULL COMMENT '作品ID，雪花算法生成',
    user_id         BIGINT UNSIGNED NOT NULL COMMENT '作者用户ID',
    title           VARCHAR(200) NOT NULL COMMENT '作品标题',
    description     TEXT DEFAULT NULL COMMENT '作品描述',
    image_url       VARCHAR(500) NOT NULL COMMENT '原图URL',
    thumbnail_url   VARCHAR(500) DEFAULT NULL COMMENT '缩略图URL(300px)',
    tags            JSON DEFAULT NULL COMMENT '标签JSON数组',
    frame_type      VARCHAR(50) DEFAULT 'minimal' COMMENT '相框类型：minimal/exif/polaroid/proFilm/circle',
    aspect_ratio   VARCHAR(20) DEFAULT '3x4' COMMENT '画面比例：3x4/1x1/9x16',
    bg_color        VARCHAR(20) DEFAULT NULL COMMENT '背景色Hex值',
    watermark_text  VARCHAR(200) DEFAULT NULL COMMENT '水印文字',
    filter          VARCHAR(50) DEFAULT 'none' COMMENT '滤镜：none/cream/film/mono/warm/cool/retro',

    -- 计数字段
    likes_count     INT UNSIGNED DEFAULT 0 COMMENT '点赞数',
    favorites_count INT UNSIGNED DEFAULT 0 COMMENT '收藏数',
    views_count     INT UNSIGNED DEFAULT 0 COMMENT '浏览数',
    comments_count  INT UNSIGNED DEFAULT 0 COMMENT '评论数',

    -- 状态字段
    status          VARCHAR(20) DEFAULT 'review' COMMENT '状态：published-已发布 review-审核中 removed-已下架',
    is_featured     TINYINT(1) DEFAULT 0 COMMENT '是否精选：0-否 1-是',

    -- 审计字段 (统一)
    deleted         TINYINT(1) DEFAULT 0 COMMENT '逻辑删除：0-正常 1-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (id),
    KEY idx_user_id (user_id),
    KEY idx_status (status),
    KEY idx_is_featured (is_featured),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作品表';


-- ===============================================================
-- 3. 评论表 (comments) - 业务表
-- 公共字段: created_at, updated_at, deleted, status
-- ===============================================================
DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
    -- 业务字段
    id              BIGINT UNSIGNED NOT NULL COMMENT '评论ID，雪花算法生成',
    user_id         BIGINT UNSIGNED NOT NULL COMMENT '评论用户ID',
    artwork_id      BIGINT UNSIGNED NOT NULL COMMENT '所属作品ID',
    content         TEXT NOT NULL COMMENT '评论内容',
    parent_id       BIGINT UNSIGNED DEFAULT NULL COMMENT '父评论ID，NULL为顶级评论',

    -- 状态字段
    status          VARCHAR(20) DEFAULT 'published' COMMENT '状态：published-已发布',

    -- 审计字段 (统一)
    deleted         TINYINT(1) DEFAULT 0 COMMENT '逻辑删除：0-正常 1-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (id),
    KEY idx_artwork_id (artwork_id),
    KEY idx_user_id (user_id),
    KEY idx_parent_id (parent_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';


-- ===============================================================
-- 4. 标签表 (tags) - 配置表
-- 公共字段: created_at, updated_at (配置表不需要 deleted)
-- 状态字段: enabled
-- ===============================================================
DROP TABLE IF EXISTS tags;
CREATE TABLE tags (
    -- 业务字段
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '标签ID，自增',
    name            VARCHAR(50) NOT NULL COMMENT '标签名称',
    description     VARCHAR(200) DEFAULT NULL COMMENT '标签描述',
    sort_order      INT DEFAULT 0 COMMENT '排序顺序',

    -- 状态字段 (配置表使用 enabled)
    enabled         TINYINT(1) DEFAULT 1 COMMENT '是否启用：0-禁用 1-启用',

    -- 审计字段 (统一)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (id),
    UNIQUE KEY uk_name (name),
    KEY idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='标签表';


-- ===============================================================
-- 5. 作品-标签关联表 (artwork_tags) - 关联表
-- 简化设计：只保留基本字段
-- ===============================================================
DROP TABLE IF EXISTS artwork_tags;
CREATE TABLE artwork_tags (
    id              BIGINT UNSIGNED NOT NULL COMMENT '记录ID，雪花算法生成',
    artwork_id      BIGINT UNSIGNED NOT NULL COMMENT '作品ID',
    tag             VARCHAR(50) NOT NULL COMMENT '标签名',

    -- 审计字段 (简化)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    PRIMARY KEY (id),
    KEY idx_artwork_id (artwork_id),
    KEY idx_tag (tag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='作品标签关联表';


-- ===============================================================
-- 6. 关注表 (follows) - 关联表
-- 简化设计：只保留基本字段
-- ===============================================================
DROP TABLE IF EXISTS follows;
CREATE TABLE follows (
    id              BIGINT UNSIGNED NOT NULL COMMENT '记录ID，雪花算法生成',
    follower_id     BIGINT UNSIGNED NOT NULL COMMENT '关注者用户ID',
    following_id    BIGINT UNSIGNED NOT NULL COMMENT '被关注者用户ID',

    -- 审计字段 (简化)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',

    PRIMARY KEY (id),
    UNIQUE KEY uk_follow (follower_id, following_id),
    KEY idx_follower_id (follower_id),
    KEY idx_following_id (following_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='关注表';


-- ===============================================================
-- 7. 点赞表 (likes) - 关联表
-- 简化设计：只保留基本字段
-- ===============================================================
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
    id              BIGINT UNSIGNED NOT NULL COMMENT '记录ID，雪花算法生成',
    user_id         BIGINT UNSIGNED NOT NULL COMMENT '点赞用户ID',
    artwork_id      BIGINT UNSIGNED NOT NULL COMMENT '被点赞作品ID',

    -- 审计字段 (简化)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',

    PRIMARY KEY (id),
    UNIQUE KEY uk_like (user_id, artwork_id),
    KEY idx_user_id (user_id),
    KEY idx_artwork_id (artwork_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='点赞表';


-- ===============================================================
-- 8. 收藏表 (favorites) - 关联表
-- 简化设计：只保留基本字段
-- ===============================================================
DROP TABLE IF EXISTS favorites;
CREATE TABLE favorites (
    id              BIGINT UNSIGNED NOT NULL COMMENT '记录ID，雪花算法生成',
    user_id         BIGINT UNSIGNED NOT NULL COMMENT '收藏用户ID',
    artwork_id      BIGINT UNSIGNED NOT NULL COMMENT '被收藏作品ID',

    -- 审计字段 (简化)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',

    PRIMARY KEY (id),
    UNIQUE KEY uk_favorite (user_id, artwork_id),
    KEY idx_user_id (user_id),
    KEY idx_artwork_id (artwork_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';


-- ===============================================================
-- 9. 通知表 (notifications) - 业务表
-- 公共字段: created_at, updated_at, deleted
-- 状态字段: status (all/具体用户ID)
-- ===============================================================
DROP TABLE IF EXISTS notifications;
CREATE TABLE notifications (
    -- 业务字段
    id              BIGINT UNSIGNED NOT NULL COMMENT '通知ID，雪花算法生成',
    title           VARCHAR(200) NOT NULL COMMENT '通知标题',
    content         TEXT NOT NULL COMMENT '通知内容',
    target          VARCHAR(50) DEFAULT 'all' COMMENT '推送目标：all-全部用户',

    -- 状态字段 (业务表使用 status)
    status          VARCHAR(20) DEFAULT 'published' COMMENT '状态：published-已发布',

    -- 审计字段 (统一)
    deleted         TINYINT(1) DEFAULT 0 COMMENT '逻辑删除：0-正常 1-已删除',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (id),
    KEY idx_target (target),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';


-- ===============================================================
-- 10. App版本表 (app_versions) - 配置表
-- 公共字段: created_at, updated_at (配置表不需要 deleted)
-- 状态字段: enabled
-- ===============================================================
DROP TABLE IF EXISTS app_versions;
CREATE TABLE app_versions (
    -- 业务字段
    id              BIGINT UNSIGNED NOT NULL COMMENT '版本ID，雪花算法生成',
    version_name    VARCHAR(50) NOT NULL COMMENT '版本号，如：1.0.0',
    version_code    INT NOT NULL COMMENT '版本码，递增整数',
    channel         VARCHAR(20) DEFAULT 'stable' COMMENT '发布渠道：stable-正式版 beta-测试版 alpha-开发版',
    gray_percent    INT DEFAULT 100 COMMENT '灰度发布比例：0-100',
    min_version_code INT DEFAULT 0 COMMENT '适用版本下限',
    max_version_code INT DEFAULT 999999 COMMENT '适用版本上限',
    force_update    TINYINT(1) DEFAULT 0 COMMENT '是否强制更新：0-可选 1-强制',
    description     VARCHAR(500) DEFAULT NULL COMMENT '简短更新说明',
    release_notes   TEXT DEFAULT NULL COMMENT '详细发布日志，支持Markdown',
    download_url    VARCHAR(500) NOT NULL COMMENT '安装包下载链接',
    hotfix_url      VARCHAR(500) DEFAULT NULL COMMENT '热更新补丁链接',
    platform        VARCHAR(20) DEFAULT 'all' COMMENT '目标平台：all/android/ios',

    -- 状态字段 (配置表使用 enabled)
    enabled         TINYINT(1) DEFAULT 1 COMMENT '是否启用：0-禁用 1-启用',

    -- 审计字段 (统一)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (id),
    UNIQUE KEY uk_version_channel (version_name, channel, platform),
    KEY idx_version_code (version_code),
    KEY idx_channel (channel),
    KEY idx_platform (platform),
    KEY idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='App版本表';


-- ===============================================================
-- 11. 配置表 (app_configs) - 配置表
-- 公共字段: created_at, updated_at (配置表不需要 deleted)
-- 状态字段: enabled
-- ===============================================================
DROP TABLE IF EXISTS app_configs;
CREATE TABLE app_configs (
    -- 业务字段
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '配置ID，自增',
    config_type     VARCHAR(50) NOT NULL COMMENT '配置类型：frame-相框 filter-滤镜 share-分享',
    config_key      VARCHAR(100) NOT NULL COMMENT '配置键，类型内唯一',
    config_value    TEXT DEFAULT NULL COMMENT '配置值，JSON格式存储',
    label           VARCHAR(100) NOT NULL COMMENT '配置显示名称',
    description     VARCHAR(500) DEFAULT NULL COMMENT '配置描述',
    sort_order      INT DEFAULT 0 COMMENT '排序顺序',

    -- 状态字段 (配置表使用 enabled)
    enabled         TINYINT(1) DEFAULT 1 COMMENT '是否启用：0-禁用 1-启用',

    -- 审计字段 (统一)
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (id),
    KEY idx_config_type (config_type),
    KEY idx_config_key (config_key),
    KEY idx_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='App配置表';


-- ===============================================================
-- 公共字段一致性汇总表
-- ===============================================================
-- 表类型          | created_at | updated_at | deleted | status | enabled |
-- ----------------|------------|------------|---------|--------|---------|
-- 业务表(users)   |     ✓      |     ✓      |    ✓    |   ✓    |    -    |
-- 业务表(artworks)|     ✓      |     ✓      |    ✓    |   ✓    |    -    |
-- 业务表(comments)|     ✓      |     ✓      |    ✓    |   ✓    |    -    |
-- 业务表(notify)  |     ✓      |     ✓      |    ✓    |   ✓    |    -    |
-- 配置表(tags)    |     ✓      |     ✓      |    -    |   -    |    ✓    |
-- 配置表(versions)|     ✓      |     ✓      |    -    |   -    |    ✓    |
-- 配置表(configs) |     ✓      |     ✓      |    -    |   -    |    ✓    |
-- 关联表(follows) |     ✓      |     -      |    -    |   -    |    -    |
-- 关联表(likes)   |     ✓      |     -      |    -    |   -    |    -    |
-- 关联表(favorite)|     ✓      |     -      |    -    |   -    |    -    |
-- 关联表(artwork_)|     ✓      |     -      |    -    |   -    |    -    |


-- ===============================================================
-- 初始化数据
-- ===============================================================

-- 插入默认管理员账号 (密码: admin123)
INSERT INTO users (id, username, password_hash, nickname, role, status) VALUES
(1000000000000000001, 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '管理员', 'admin', 'active');

-- 插入默认标签
INSERT INTO tags (name, description, sort_order) VALUES
('风景', '自然风光、城市街景等', 1),
('人像', '人物摄影作品', 2),
('美食', '美食摄影', 3),
('生活', '日常生活记录', 4),
('旅行', '旅行见闻分享', 5),
('宠物', '萌宠摄影', 6),
('建筑', '建筑设计摄影', 7),
('静物', '静物摄影作品', 8),
('黑白', '黑白摄影', 9),
('复古', '复古风格摄影', 10);

-- 插入默认相框配置
INSERT INTO app_configs (config_type, config_key, config_value, label, description, sort_order) VALUES
('frame', 'minimal', '{"isPro": false}', '极简白框', '干净留白，突出照片本身', 1),
('frame', 'exif', '{"isPro": false}', 'EXIF信息框', '展示相机参数，摄影爱好者必备', 2),
('frame', 'polaroid', '{"isPro": false}', '拍立得', '温暖拍立得风格，记录生活美好', 3),
('frame', 'proFilm', '{"isPro": false}', '复古胶片', '徕卡风格底片，浓郁胶片质感', 4),
('frame', 'circle', '{"isPro": false}', '圆形复古', '圆形取景框，复古镜头感', 5);

-- 插入默认滤镜配置
INSERT INTO app_configs (config_type, config_key, config_value, label, description, sort_order) VALUES
('filter', 'none', '{"matrix": [1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0]}', '原图', '不做任何处理', 1),
('filter', 'cream', '{"matrix": [1.1,0,0,0,0, 0,1.05,0,0,0, 0,0,0.95,0,0, 0,0,0,1,0]}', '奶油滤镜', '柔和奶油色调，温柔治愈', 2),
('filter', 'film', '{"matrix": [0.9,0.1,0,0,0, 0.1,0.85,0.05,0,0, 0,0.1,0.9,0,0, 0,0,0,1,0]}', '胶片滤镜', '复古胶片质感', 3),
('filter', 'mono', '{"matrix": [0.33,0.59,0.11,0,0, 0.33,0.59,0.11,0,0, 0.33,0.59,0.11,0,0, 0,0,0,1,0]}', '黑白滤镜', '经典黑白，永恒质感', 4),
('filter', 'warm', '{"matrix": [1.1,0,0,0,0.05, 0,1,0,0,0.02, 0,0,0.9,0,0, 0,0,0,1,0]}', '暖阳滤镜', '温暖阳光色调', 5),
('filter', 'cool', '{"matrix": [0.95,0,0,0,0, 0,1,0,0,0, 0,0,1.05,0,0.02, 0,0,0,1,0]}', '冷调滤镜', '清冷蓝调，高级氛围感', 6),
('filter', 'retro', '{"matrix": [0.9,0.1,0,0,0.05, 0.05,0.85,0.1,0,0.03, 0,0.05,0.85,0,0, 0,0,0,1,0]}', '复古滤镜', '怀旧棕色调', 7);

-- 插入默认分享渠道配置
INSERT INTO app_configs (config_type, config_key, config_value, label, description, sort_order) VALUES
('share', 'xiaohongshu', '{"icon": "collections_bookmark"}', '小红书', '分享到小红书', 1),
('share', 'wechat_moments', '{"icon": "camera_roll"}', '朋友圈', '分享到微信朋友圈', 2),
('share', 'wechat', '{"icon": "chat"}', '微信好友', '分享给微信好友', 3),
('share', 'weibo', '{"icon": "wifi_tethering"}', '微博', '分享到微博', 4),
('share', 'douyin', '{"icon": "video_collection"}', '抖音', '分享到抖音', 5);

-- 插入App版本示例数据
INSERT INTO app_versions (version_name, version_code, channel, force_update, description, download_url, platform) VALUES
('1.0.0', 1, 'stable', 1, '首个正式版本发布', 'https://example.com/picflow-v1.0.0.apk', 'android'),
('1.0.0', 1, 'stable', 1, '首个正式版本发布', 'https://example.com/picflow-v1.0.0.ipa', 'ios');
