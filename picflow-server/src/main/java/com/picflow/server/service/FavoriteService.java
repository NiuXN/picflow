package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.Favorite;

import java.util.List;
import java.util.Set;

public interface FavoriteService extends IService<Favorite> {

    boolean hasFavorited(Long userId, Long artworkId);

    void favorite(Long userId, Long artworkId);

    void unfavorite(Long userId, Long artworkId);

    Set<Long> getFavoritedArtworkIds(Long userId, List<Long> artworkIds);
}