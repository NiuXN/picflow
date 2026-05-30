package com.picflow.server.common;

import lombok.Getter;

/**
 * 统一错误码枚举
 *
 * 错误码规则：
 * - 200：成功
 * - 4xx：客户端错误（400-499）
 * - 5xx：服务端错误（500-599）
 * - 1xxx：业务错误（1000-1999）
 * - 2xxx：认证错误（2000-2999）
 * - 3xxx：权限错误（3000-3999）
 */
@Getter
public enum ErrorCode {

    // ============================================
    // 通用错误 (1000-1099)
    // ============================================
    SUCCESS(0, "success"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未授权，请先登录"),
    FORBIDDEN(403, "无权访问该资源"),
    NOT_FOUND(404, "资源不存在"),
    TOO_MANY_REQUESTS(429, "请求过于频繁，请稍后再试"),
    INTERNAL_SERVER_ERROR(500, "服务器内部错误"),

    // ============================================
    // 认证错误 (2000-2099)
    // ============================================
    USER_NOT_FOUND(2000, "用户不存在"),
    USER_ALREADY_EXISTS(2001, "用户已存在"),
    INVALID_PASSWORD(2002, "密码错误"),
    INVALID_TOKEN(2003, "无效的 Token"),
    TOKEN_EXPIRED(2004, "Token 已过期"),
    INVALID_VERIFICATION_CODE(2005, "验证码错误"),
    VERIFICATION_CODE_EXPIRED(2006, "验证码已过期"),
    PHONE_ALREADY_REGISTERED(2007, "手机号已注册"),

    // ============================================
    // 业务错误 (1000-1999)
    // ============================================
    ARTWORK_NOT_FOUND(1000, "作品不存在"),
    ARTWORK_ALREADY_LIKED(1001, "已点赞该作品"),
    ARTWORK_NOT_LIKED(1002, "未点赞该作品"),
    ARTWORK_ALREADY_FAVORITED(1003, "已收藏该作品"),
    ARTWORK_NOT_FAVORITED(1004, "未收藏该作品"),
    COMMENT_NOT_FOUND(1005, "评论不存在"),
    USER_ALREADY_FOLLOWED(1006, "已关注该用户"),
    USER_NOT_FOLLOWED(1007, "未关注该用户"),
    CANNOT_FOLLOW_SELF(1008, "无法关注自己"),
    CANNOT_LIKE_SELF(1009, "无法点赞自己的作品"),

    // ============================================
    // 文件错误 (1100-1199)
    // ============================================
    FILE_EMPTY(1100, "文件不能为空"),
    FILE_TOO_LARGE(1101, "文件大小超出限制"),
    INVALID_FILE_TYPE(1102, "不支持的文件类型"),
    FILE_UPLOAD_FAILED(1103, "文件上传失败"),

    // ============================================
    // 用户错误 (1200-1299)
    // ============================================
    USER_BANNED(1200, "该用户已被封禁"),
    INVALID_USER_STATUS(1201, "用户状态异常"),
    PROFILE_UPDATE_FAILED(1202, "资料更新失败"),

    // ============================================
    // 权限错误 (3000-3099)
    // ============================================
    NO_PERMISSION(3000, "无权执行此操作"),
    ADMIN_REQUIRED(3001, "需要管理员权限"),
    ARTWORK_OWNER_REQUIRED(3002, "只有作品作者可执行此操作"),
    COMMENT_OWNER_REQUIRED(3003, "只有评论作者可执行此操作");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
