package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.common.PageResult;
import com.picflow.server.entity.Artwork;

public interface ArtworkService extends IService<Artwork> {

    PageResult<Artwork> getArtworks(Long userId, int page, int size, String sort, String tag);

    Artwork publishArtwork(Long userId, String title, String description, String imageUrl,
                           String tags, String frameType, String aspectRatio,
                           String bgColor, String watermarkText, String filter);

    Artwork getArtworkDetail(Long id);

    PageResult<Artwork> getMyArtworks(Long userId, int page, int size);

    void incrementViewCount(Long id);

    Artwork updateArtwork(Long userId, Long id, String title, String description,
                          String tags, String frameType, String aspectRatio,
                          String bgColor, String watermarkText, String filter);
}