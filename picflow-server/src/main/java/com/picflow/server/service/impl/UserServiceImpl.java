package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.BusinessException;
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
            throw new BusinessException("用户名已存在");
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
            throw new BusinessException("用户名或密码错误");
        }
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new BusinessException("用户名或密码错误");
        }
        if (!"active".equals(user.getStatus())) {
            throw new BusinessException("账号已被禁用");
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
}