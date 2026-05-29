package com.picflow.server.controller;

import com.picflow.server.common.Result;
import com.picflow.server.entity.User;
import com.picflow.server.service.FollowService;
import com.picflow.server.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/social")
@RequiredArgsConstructor
@Tag(name = "社交接口", description = "关注/取关")
public class SocialController {

    private final FollowService followService;
    private final UserService userService;

    @PostMapping("/follow/{userId}")
    @Operation(summary = "关注用户")
    public Result<Map<String, String>> follow(@PathVariable Long userId,
                                               @AuthenticationPrincipal Long currentUserId) {
        followService.follow(currentUserId, userId);
        return Result.ok(Map.of("message", "关注成功"));
    }

    @DeleteMapping("/follow/{userId}")
    @Operation(summary = "取消关注")
    public Result<Map<String, String>> unfollow(@PathVariable Long userId,
                                                  @AuthenticationPrincipal Long currentUserId) {
        followService.unfollow(currentUserId, userId);
        return Result.ok(Map.of("message", "已取消关注"));
    }

    @GetMapping("/following/{userId}")
    @Operation(summary = "获取关注列表")
    public Result<Map<String, Object>> following(@PathVariable Long userId) {
        List<Long> ids = followService.getFollowingIds(userId);
        List<User> users = userService.listByIds(ids);
        return Result.ok(Map.of("items", users));
    }

    @GetMapping("/followers/{userId}")
    @Operation(summary = "获取粉丝列表")
    public Result<Map<String, Object>> followers(@PathVariable Long userId) {
        List<Long> ids = followService.getFollowerIds(userId);
        List<User> users = userService.listByIds(ids);
        return Result.ok(Map.of("items", users));
    }

    @GetMapping("/check/{userId}")
    @Operation(summary = "检查是否已关注")
    public Result<Map<String, Boolean>> checkFollow(@PathVariable Long userId,
                                                      @AuthenticationPrincipal Long currentUserId) {
        boolean isFollowing = followService.isFollowing(currentUserId, userId);
        return Result.ok(Map.of("isFollowing", isFollowing));
    }
}
