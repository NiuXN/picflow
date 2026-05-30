package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.BusinessException;
import com.picflow.server.common.ErrorCode;
import com.picflow.server.entity.User;
import com.picflow.server.mapper.UserMapper;
import com.picflow.server.security.JwtTokenProvider;
import com.picflow.server.entity.Artwork;
import com.picflow.server.service.ArtworkService;
import com.picflow.server.service.FavoriteService;
import com.picflow.server.service.FollowService;
import com.picflow.server.service.LikeService;
import com.picflow.server.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final ArtworkService artworkService;
    private final LikeService likeService;
    private final FavoriteService favoriteService;
    private final FollowService followService;

    @Override
    public User register(String username, String password, String nickname) {
        if (this.getOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username)) != null) {
            throw new BusinessException(ErrorCode.USER_ALREADY_EXISTS);
        }

        User user = new User();
        user.setUsername(username);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setNickname(nickname != null ? nickname : "PicFlow用户");
        user.setRole("user");
        user.setStatus("active");
        this.save(user);
        return user;
    }

    @Override
    public User registerByPhone(String phone, String nickname) {
        User user = new User();
        user.setPhone(phone);
        user.setPhoneVerified(true);
        user.setNickname(nickname != null ? nickname : "手机用户" + phone.substring(phone.length() - 4));
        user.setUsername("phone_" + phone);
        user.setRole("user");
        user.setStatus("active");
        user.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
        this.save(user);
        return user;
    }

    @Override
    public User loginByPhone(String phone) {
        return this.getOne(new LambdaQueryWrapper<User>().eq(User::getPhone, phone));
    }

    @Override
    public String login(String username, String password) {
        User user = this.getOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_FOUND);
        }
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new BusinessException(ErrorCode.INVALID_PASSWORD);
        }
        if (!"active".equals(user.getStatus())) {
            throw new BusinessException(ErrorCode.USER_BANNED);
        }
        return jwtTokenProvider.generateToken(user.getId(), user.getUsername(), user.getRole());
    }

    @Override
    public User getCurrentUser() {
        Long userId = (Long) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return this.getById(userId);
    }

    @Override
    public Map<String, Object> getUserStats(Long userId) {
        long artworksCount = artworkService.count(
                new LambdaQueryWrapper<Artwork>().eq(Artwork::getUserId, userId));
        long likesCount = likeService.getTotalLikesByUser(userId);
        long favoritesCount = favoriteService.getTotalFavoritesByUser(userId);

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("artworksCount", artworksCount);
        stats.put("likesCount", likesCount);
        stats.put("favoritesCount", favoritesCount);
        stats.put("followingCount", followService.countFollowing(userId));
        return stats;
    }

    @Override
    public User loginByOAuth(String provider, String openId, String nickname, String avatarUrl) {
        User user = findOAuthUser(provider, openId);
        if (user != null) {
            // 用户已存在
            if (!"active".equals(user.getStatus())) {
                throw new BusinessException(ErrorCode.USER_BANNED);
            }
            return user;
        }

        // 新用户注册
        user = new User();
        user.setUsername(provider + "_" + openId);
        user.setNickname(nickname != null ? nickname : provider + "用户" + UUID.randomUUID().toString().substring(0, 6));
        user.setAvatarUrl(avatarUrl);
        user.setRole("user");
        user.setStatus("active");
        user.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));

        // 设置对应的 openId
        switch (provider) {
            case "wechat" -> user.setWechatOpenId(openId);
            case "apple" -> user.setAppleOpenId(openId);
            case "google" -> user.setGoogleOpenId(openId);
            default -> throw new BusinessException(ErrorCode.BAD_REQUEST.getCode(), "不支持的登录平台");
        }

        this.save(user);
        return user;
    }

    /**
     * 根据第三方平台查找用户
     */
    private User findOAuthUser(String provider, String openId) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        switch (provider) {
            case "wechat" -> wrapper.eq(User::getWechatOpenId, openId);
            case "apple" -> wrapper.eq(User::getAppleOpenId, openId);
            case "google" -> wrapper.eq(User::getGoogleOpenId, openId);
            default -> throw new BusinessException(ErrorCode.BAD_REQUEST.getCode(), "不支持的登录平台");
        }
        return this.getOne(wrapper);
    }
}
