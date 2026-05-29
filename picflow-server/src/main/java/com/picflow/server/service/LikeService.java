package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.Like;

import java.util.List;
import java.util.Set;

public interface LikeService extends IService<Like> {

    boolean hasLiked(Long userId, Long artworkId);

    void like(Long userId, Long artworkId);

    void unlike(Long userId, Long artworkId);

    Set<Long> getLikedArtworkIds(Long userId, List<Long> artworkIds);

    long getTotalLikesByUser(Long userId);
}