package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.BusinessException;
import com.picflow.server.entity.Follow;
import com.picflow.server.mapper.FollowMapper;
import com.picflow.server.service.FollowService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FollowServiceImpl extends ServiceImpl<FollowMapper, Follow> implements FollowService {

    @Override
    @Transactional
    public void follow(Long followerId, Long followingId) {
        if (followerId.equals(followingId)) {
            throw new BusinessException("不能关注自己");
        }
        long count = this.count(new LambdaQueryWrapper<Follow>()
                .eq(Follow::getFollowerId, followerId)
                .eq(Follow::getFollowingId, followingId));
        if (count > 0) {
            throw new BusinessException("已关注该用户");
        }
        Follow follow = new Follow();
        follow.setFollowerId(followerId);
        follow.setFollowingId(followingId);
        this.save(follow);
    }

    @Override
    @Transactional
    public void unfollow(Long followerId, Long followingId) {
        this.remove(new LambdaQueryWrapper<Follow>()
                .eq(Follow::getFollowerId, followerId)
                .eq(Follow::getFollowingId, followingId));
    }

    @Override
    public boolean isFollowing(Long followerId, Long followingId) {
        return this.count(new LambdaQueryWrapper<Follow>()
                .eq(Follow::getFollowerId, followerId)
                .eq(Follow::getFollowingId, followingId)) > 0;
    }

    @Override
    public List<Long> getFollowingIds(Long userId) {
        return this.list(new LambdaQueryWrapper<Follow>()
                .eq(Follow::getFollowerId, userId))
                .stream()
                .map(Follow::getFollowingId)
                .collect(Collectors.toList());
    }

    @Override
    public List<Long> getFollowerIds(Long userId) {
        return this.list(new LambdaQueryWrapper<Follow>()
                .eq(Follow::getFollowingId, userId))
                .stream()
                .map(Follow::getFollowerId)
                .collect(Collectors.toList());
    }

    @Override
    public long countFollowing(Long userId) {
        return this.count(new LambdaQueryWrapper<Follow>().eq(Follow::getFollowerId, userId));
    }

    @Override
    public long countFollowers(Long userId) {
        return this.count(new LambdaQueryWrapper<Follow>().eq(Follow::getFollowingId, userId));
    }
}
