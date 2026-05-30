package com.picflow.server.service.impl;

import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.BusinessException;
import com.picflow.server.common.PageResult;
import com.picflow.server.entity.Artwork;
import com.picflow.server.entity.ArtworkTag;
import com.picflow.server.entity.User;
import com.picflow.server.mapper.ArtworkMapper;
import com.picflow.server.mapper.ArtworkTagMapper;
import com.picflow.server.service.ArtworkService;
import com.picflow.server.service.FavoriteService;
import com.picflow.server.service.LikeService;
import com.picflow.server.service.UserService;
import lombok.extern.slf4j.Slf4j;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.CacheManager;
import org.springframework.context.annotation.Lazy;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ArtworkServiceImpl extends ServiceImpl<ArtworkMapper, Artwork> implements ArtworkService {

    private final ArtworkTagMapper artworkTagMapper;
    private final LikeService likeService;
    private final FavoriteService favoriteService;
    private final CacheManager cacheManager;

    @Autowired
    @Lazy
    private UserService userService;

    @Override
    public PageResult<Artwork> getArtworks(Long userId, int page, int size, String sort, String tag) {
        log.debug("[缓存查询] 作品列表 - userId={}, page={}, size={}, sort={}, tag={}", 
                  userId, page, size, sort != null ? sort : "latest", tag != null ? tag : "all");
        return getArtworksInternal(userId, page, size, sort, tag);
    }

    @Cacheable(value = "artworks:list", key = "{#page, #size, #sort != null ? #sort : 'latest', #tag != null ? #tag : 'all'}")
    PageResult<Artwork> getArtworksInternal(Long userId, int page, int size, String sort, String tag) {
        log.info("[缓存未命中] 查询作品列表 - page={}, size={}, sort={}, tag={}", 
                 page, size, sort != null ? sort : "latest", tag != null ? tag : "all");
        LambdaQueryWrapper<Artwork> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Artwork::getStatus, "published");

        if (tag != null && !tag.isEmpty()) {
            List<Long> artworkIds = artworkTagMapper.selectList(
                    new LambdaQueryWrapper<ArtworkTag>().eq(ArtworkTag::getTag, tag)
            ).stream().map(ArtworkTag::getArtworkId).toList();
            if (artworkIds.isEmpty()) {
                log.debug("[标签搜索] 标签 '{}' 无匹配作品", tag);
                return PageResult.of(0, page, size, List.of());
            }
            wrapper.in(Artwork::getId, artworkIds);
        }

        if ("trending".equals(sort)) {
            wrapper.orderByDesc(Artwork::getLikesCount);
        } else if ("featured".equals(sort)) {
            wrapper.eq(Artwork::getIsFeatured, true);
            wrapper.orderByDesc(Artwork::getCreatedAt);
        } else {
            wrapper.orderByDesc(Artwork::getCreatedAt);
        }

        Page<Artwork> pageResult = this.page(new Page<>(page, size), wrapper);
        List<Artwork> artworks = pageResult.getRecords();
        log.info("[数据库查询] 作品列表 - 总数={}, 当前页条数={}", pageResult.getTotal(), artworks.size());
        enrichWithUserInteraction(userId, artworks);
        return PageResult.of(pageResult.getTotal(), page, size, artworks);
    }

    private void enrichWithUserInteraction(Long userId, List<Artwork> artworks) {
        if (artworks.isEmpty()) {
            return;
        }
        populateAuthorInfo(artworks);
        if (userId == null) {
            return;
        }
        List<Long> artworkIds = artworks.stream().map(Artwork::getId).collect(Collectors.toList());
        Set<Long> likedIds = likeService.getLikedArtworkIds(userId, artworkIds);
        Set<Long> favoritedIds = favoriteService.getFavoritedArtworkIds(userId, artworkIds);
        for (Artwork artwork : artworks) {
            artwork.setIsLiked(likedIds.contains(artwork.getId()));
            artwork.setIsFavorited(favoritedIds.contains(artwork.getId()));
        }
    }

    private void populateAuthorInfo(List<Artwork> artworks) {
        Set<Long> userIds = artworks.stream()
                .map(Artwork::getUserId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (userIds.isEmpty()) return;

        Map<Long, User> userMap = userService.listByIds(userIds).stream()
                .collect(Collectors.toMap(User::getId, u -> u));

        for (Artwork artwork : artworks) {
            User author = userMap.get(artwork.getUserId());
            if (author != null) {
                User safe = new User();
                safe.setId(author.getId());
                safe.setUsername(author.getUsername());
                safe.setNickname(author.getNickname());
                safe.setAvatarUrl(author.getAvatarUrl());
                artwork.setAuthor(safe);
            }
        }
    }

    @Override
    @CacheEvict(value = {"artworks:list", "artwork:trending"}, allEntries = true)
    public Artwork publishArtwork(Long userId, String title, String description,
                                  String imageUrl, String thumbnailUrl, String tags, String frameType,
                                  String aspectRatio, String bgColor, String watermarkText,
                                  String filter) {
        log.info("[缓存清除] 发布新作品 - userId={}, title={}", userId, title);
        Artwork artwork = new Artwork();
        artwork.setUserId(userId);
        artwork.setTitle(title);
        artwork.setDescription(description);
        artwork.setImageUrl(imageUrl);
        artwork.setThumbnailUrl(thumbnailUrl != null && !thumbnailUrl.isEmpty() ? thumbnailUrl : imageUrl);
        artwork.setTags(tags);
        artwork.setFrameType(frameType);
        artwork.setAspectRatio(aspectRatio);
        artwork.setBgColor(bgColor);
        artwork.setWatermarkText(watermarkText);
        artwork.setFilter(filter);
        artwork.setLikesCount(0);
        artwork.setFavoritesCount(0);
        artwork.setViewsCount(0);
        artwork.setCommentsCount(0);
        artwork.setStatus("published");
        artwork.setIsFeatured(false);
        this.save(artwork);
        log.info("[发布成功] 作品已保存 - artworkId={}, tags={}", artwork.getId(), tags);

        if (tags != null && !tags.isEmpty() && !"[]".equals(tags)) {
            List<String> tagList = JSONUtil.toList(tags, String.class);
            for (String t : tagList) {
                ArtworkTag artworkTag = new ArtworkTag();
                artworkTag.setArtworkId(artwork.getId());
                artworkTag.setTag(t.trim());
                artworkTagMapper.insert(artworkTag);
            }
            log.debug("[标签写入] 作品 {} 添加标签: {}", artwork.getId(), tagList);
        }

        return artwork;
    }

    @Override
    @Cacheable(value = "artwork", key = "#id", unless = "#result == null")
    public Artwork getArtworkDetail(Long id) {
        log.info("[缓存未命中] 查询作品详情 - id={}", id);
        Artwork artwork = this.getById(id);
        if (artwork == null) {
            log.warn("[作品不存在] id={}", id);
            return null;
        }
        log.debug("[作品详情] id={}, title={}, status={}", id, artwork.getTitle(), artwork.getStatus());
        if ("published".equals(artwork.getStatus())) {
            incrementViewCount(id);
        }
        return artwork;
    }

    @Override
    public PageResult<Artwork> getMyArtworks(Long userId, int page, int size) {
        log.debug("[个人作品查询] userId={}, page={}, size={}", userId, page, size);
        LambdaQueryWrapper<Artwork> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Artwork::getUserId, userId)
               .orderByDesc(Artwork::getCreatedAt);

        Page<Artwork> pageResult = this.page(new Page<>(page, size), wrapper);
        return PageResult.of(pageResult.getTotal(), page, size, pageResult.getRecords());
    }

    @Scheduled(fixedRate = 600000)
    public void refreshTrendingCache() {
        log.info("[定时任务] 开始刷新热门作品缓存 - 清除 artworks:list 全部缓存");
        try {
            Objects.requireNonNull(cacheManager.getCache("artworks:list")).clear();
            log.info("[定时任务] 热门作品缓存刷新完成");
        } catch (Exception e) {
            log.error("[定时任务] 刷新缓存失败: {}", e.getMessage(), e);
        }
    }

    @Override
    public Artwork updateArtwork(Long userId, Long id, String title, String description,
                                String tags, String frameType, String aspectRatio,
                                String bgColor, String watermarkText, String filter) {
        Artwork artwork = this.getById(id);
        if (artwork == null || !artwork.getUserId().equals(userId)) {
            throw new BusinessException("无权操作");
        }
        if (title != null) artwork.setTitle(title);
        if (description != null) artwork.setDescription(description);
        if (frameType != null) artwork.setFrameType(frameType);
        if (aspectRatio != null) artwork.setAspectRatio(aspectRatio);
        if (bgColor != null) artwork.setBgColor(bgColor);
        if (watermarkText != null) artwork.setWatermarkText(watermarkText);
        if (filter != null) artwork.setFilter(filter);
        if (tags != null && !"[]".equals(tags)) {
            artwork.setTags(tags);
            artworkTagMapper.delete(new LambdaQueryWrapper<ArtworkTag>().eq(ArtworkTag::getArtworkId, id));
            List<String> tagList = JSONUtil.toList(tags, String.class);
            for (String t : tagList) {
                ArtworkTag artworkTag = new ArtworkTag();
                artworkTag.setArtworkId(id);
                artworkTag.setTag(t.trim());
                artworkTagMapper.insert(artworkTag);
            }
        }
        this.updateById(artwork);
        return artwork;
    }

    @Override
    public void incrementViewCount(Long id) {
        log.debug("[浏览量+1] artworkId={}", id);
        Artwork artwork = this.getById(id);
        if (artwork != null) {
            artwork.setViewsCount(artwork.getViewsCount() + 1);
            this.updateById(artwork);
            if (artwork.getViewsCount() % 100 == 0) {
                log.info("[浏览量里程碑] artworkId={} 浏览量达到 {}", id, artwork.getViewsCount());
            }
        }
    }
}