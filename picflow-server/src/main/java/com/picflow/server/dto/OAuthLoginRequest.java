package com.picflow.server.dto;

import lombok.Data;

/**
 * 第三方登录请求
 */
@Data
public class OAuthLoginRequest {

    /**
     * 登录平台：wechat/apple/google
     */
    private String provider;

    /**
     * 第三方平台唯一标识
     */
    private String openId;

    /**
     * 访问令牌
     */
    private String accessToken;

    /**
     * 用户昵称（可选）
     */
    private String nickname;

    /**
     * 用户头像（可选）
     */
    private String avatarUrl;
}
