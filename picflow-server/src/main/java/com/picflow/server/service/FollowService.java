package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.Follow;

import java.util.List;

public interface FollowService extends IService<Follow> {

    void follow(Long followerId, Long followingId);

    void unfollow(Long followerId, Long followingId);

    boolean isFollowing(Long followerId, Long followingId);

    List<Long> getFollowingIds(Long userId);

    List<Long> getFollowerIds(Long userId);

    long countFollowing(Long userId);

    long countFollowers(Long userId);
}
