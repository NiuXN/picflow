package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.BusinessException;
import com.picflow.server.entity.Artwork;
import com.picflow.server.entity.Like;
import com.picflow.server.mapper.ArtworkMapper;
import com.picflow.server.mapper.LikeMapper;
import com.picflow.server.service.LikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LikeServiceImpl extends ServiceImpl<LikeMapper, Like> implements LikeService {

    private final ArtworkMapper artworkMapper;

    @Override
    public boolean hasLiked(Long userId, Long artworkId) {
        return this.count(new LambdaQueryWrapper<Like>()
                .eq(Like::getUserId, userId)
                .eq(Like::getArtworkId, artworkId)) > 0;
    }

    @Override
    @Transactional
    public void like(Long userId, Long artworkId) {
        if (hasLiked(userId, artworkId)) {
            throw new BusinessException("已经点过赞了");
        }

        Like like = new Like();
        like.setUserId(userId);
        like.setArtworkId(artworkId);
        this.save(like);

        Artwork artwork = artworkMapper.selectById(artworkId);
        if (artwork != null) {
            artwork.setLikesCount(artwork.getLikesCount() + 1);
            artworkMapper.updateById(artwork);
        }
    }

    @Override
    @Transactional
    public void unlike(Long userId, Long artworkId) {
        if (!hasLiked(userId, artworkId)) {
            return;
        }

        this.remove(new LambdaQueryWrapper<Like>()
                .eq(Like::getUserId, userId)
                .eq(Like::getArtworkId, artworkId));

        Artwork artwork = artworkMapper.selectById(artworkId);
        if (artwork != null && artwork.getLikesCount() > 0) {
            artwork.setLikesCount(artwork.getLikesCount() - 1);
            artworkMapper.updateById(artwork);
        }
    }

    @Override
    public Set<Long> getLikedArtworkIds(Long userId, List<Long> artworkIds) {
        if (artworkIds == null || artworkIds.isEmpty()) {
            return Collections.emptySet();
        }
        return this.list(new LambdaQueryWrapper<Like>()
                .eq(Like::getUserId, userId)
                .in(Like::getArtworkId, artworkIds))
                .stream()
                .map(Like::getArtworkId)
                .collect(Collectors.toSet());
    }

    @Override
    public long getTotalLikesByUser(Long userId) {
        return this.count(new LambdaQueryWrapper<Like>().eq(Like::getUserId, userId));
    }
}