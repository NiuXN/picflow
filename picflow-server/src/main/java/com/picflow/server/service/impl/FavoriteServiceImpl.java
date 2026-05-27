package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.BusinessException;
import com.picflow.server.entity.Artwork;
import com.picflow.server.entity.Favorite;
import com.picflow.server.mapper.ArtworkMapper;
import com.picflow.server.mapper.FavoriteMapper;
import com.picflow.server.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite> implements FavoriteService {

    private final ArtworkMapper artworkMapper;

    @Override
    public boolean hasFavorited(Long userId, Long artworkId) {
        return this.count(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId)
                .eq(Favorite::getArtworkId, artworkId)) > 0;
    }

    @Override
    @Transactional
    public void favorite(Long userId, Long artworkId) {
        if (hasFavorited(userId, artworkId)) {
            throw new BusinessException("已经收藏过了");
        }

        Favorite favorite = new Favorite();
        favorite.setUserId(userId);
        favorite.setArtworkId(artworkId);
        this.save(favorite);

        Artwork artwork = artworkMapper.selectById(artworkId);
        if (artwork != null) {
            artwork.setFavoritesCount(artwork.getFavoritesCount() + 1);
            artworkMapper.updateById(artwork);
        }
    }

    @Override
    @Transactional
    public void unfavorite(Long userId, Long artworkId) {
        if (!hasFavorited(userId, artworkId)) {
            return;
        }

        this.remove(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId)
                .eq(Favorite::getArtworkId, artworkId));

        Artwork artwork = artworkMapper.selectById(artworkId);
        if (artwork != null && artwork.getFavoritesCount() > 0) {
            artwork.setFavoritesCount(artwork.getFavoritesCount() - 1);
            artworkMapper.updateById(artwork);
        }
    }

    @Override
    public Set<Long> getFavoritedArtworkIds(Long userId, List<Long> artworkIds) {
        if (artworkIds == null || artworkIds.isEmpty()) {
            return Collections.emptySet();
        }
        return this.list(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId)
                .in(Favorite::getArtworkId, artworkIds))
                .stream()
                .map(Favorite::getArtworkId)
                .collect(Collectors.toSet());
    }
}