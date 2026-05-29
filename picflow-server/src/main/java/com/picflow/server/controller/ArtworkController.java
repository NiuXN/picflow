package com.picflow.server.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.picflow.server.annotation.RateLimit;
import com.picflow.server.common.PageResult;
import com.picflow.server.common.Result;
import com.picflow.server.dto.ArtworkRequest;
import com.picflow.server.entity.Artwork;
import com.picflow.server.entity.Comment;
import com.picflow.server.service.ArtworkService;

/** 作品接口：CRUD、点赞、收藏、评论 */
import com.picflow.server.service.CommentService;
import com.picflow.server.service.FavoriteService;
import com.picflow.server.service.LikeService;
import com.picflow.server.service.TagService;
import com.picflow.server.service.AppConfigService;
import com.picflow.server.entity.Tag;
import com.picflow.server.entity.AppConfig;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/artworks")
@RequiredArgsConstructor
@Tag(name = "作品接口", description = "作品的增删改查")
public class ArtworkController {

    private final ArtworkService artworkService;
    private final CommentService commentService;
    private final LikeService likeService;
    private final FavoriteService favoriteService;
    private final TagService tagService;
    private final AppConfigService appConfigService;

    @GetMapping
    @Operation(summary = "获取作品列表")
    public Result<PageResult<Artwork>> list(
            @AuthenticationPrincipal Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "latest") String sort,
            @RequestParam(required = false) String tag) {
        PageResult<Artwork> result = artworkService.getArtworks(userId, page, size, sort, tag);
        return Result.ok(result);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取作品详情")
    public Result<Artwork> detail(@PathVariable Long id) {
        Artwork artwork = artworkService.getArtworkDetail(id);
        return artwork != null ? Result.ok(artwork) : Result.error("作品不存在");
    }

    @PostMapping
    @Operation(summary = "发布作品")
    public Result<Artwork> publish(@AuthenticationPrincipal Long userId,
                                    @Valid @RequestBody ArtworkRequest request) {
        Artwork artwork = artworkService.publishArtwork(
                userId, request.getTitle(), request.getDescription(),
                request.getImageUrl(), request.getThumbnailUrl(),
                request.getTags() != null ? request.getTags().toString() : "[]",
                request.getFrameType(), request.getAspectRatio(),
                request.getBgColor(), request.getWatermarkText(),
                request.getFilter());
        return Result.ok(artwork);
    }

    @PutMapping("/{id}")
    @Operation(summary = "编辑作品")
    public Result<Artwork> update(@AuthenticationPrincipal Long userId,
                                   @PathVariable Long id,
                                   @RequestBody ArtworkRequest request) {
        Artwork artwork = artworkService.updateArtwork(
                userId, id, request.getTitle(), request.getDescription(),
                request.getTags() != null ? request.getTags().toString() : null,
                request.getFrameType(), request.getAspectRatio(),
                request.getBgColor(), request.getWatermarkText(),
                request.getFilter());
        return Result.ok(artwork);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除作品")
    public Result<Map<String, String>> delete(@PathVariable Long id, @AuthenticationPrincipal Long userId) {
        Artwork artwork = artworkService.getById(id);
        if (artwork == null || !artwork.getUserId().equals(userId)) {
            return Result.error("无权操作");
        }
        artworkService.removeById(id);
        return Result.ok(Map.of("message", "删除成功"));
    }

    @GetMapping("/tags")
    @Operation(summary = "获取所有标签")
    public Result<Map<String, Object>> tags() {
        List<Tag> tags = tagService.getEnabledTags();
        List<String> tagNames = tags.stream().map(Tag::getName).toList();
        return Result.ok(Map.of("items", tagNames));
    }

    @GetMapping("/configs")
    @Operation(summary = "获取App配置（相框/滤镜）")
    public Result<Map<String, Object>> configs(@RequestParam String type) {
        List<AppConfig> configs = appConfigService.getEnabledConfigsByType(type);
        return Result.ok(Map.of("items", configs));
    }

    @GetMapping("/my")
    @Operation(summary = "获取我的作品")
    public Result<PageResult<Artwork>> myArtworks(
            @AuthenticationPrincipal Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.ok(artworkService.getMyArtworks(userId, page, size));
    }

    @RateLimit(capacity = 30, refillTokens = 30, refillMinutes = 1)
    @PostMapping("/{id}/like")
    @Operation(summary = "点赞作品")
    public Result<Map<String, Object>> like(@PathVariable Long id, @AuthenticationPrincipal Long userId) {
        try {
            likeService.like(userId, id);
        } catch (RuntimeException e) {
            return Result.error(HttpStatus.CONFLICT.value(), e.getMessage());
        }
        Artwork artwork = artworkService.getById(id);
        return Result.ok(Map.of("is_liked", true, "likes_count", artwork != null ? artwork.getLikesCount() : 0));
    }

    @DeleteMapping("/{id}/like")
    @Operation(summary = "取消点赞")
    public Result<Map<String, Object>> unlike(@PathVariable Long id, @AuthenticationPrincipal Long userId) {
        likeService.unlike(userId, id);
        Artwork artwork = artworkService.getById(id);
        return Result.ok(Map.of("is_liked", false, "likes_count", artwork != null ? artwork.getLikesCount() : 0));
    }

    @PostMapping("/{id}/favorite")
    @Operation(summary = "收藏作品")
    public Result<Map<String, Object>> favorite(@PathVariable Long id, @AuthenticationPrincipal Long userId) {
        try {
            favoriteService.favorite(userId, id);
        } catch (RuntimeException e) {
            return Result.error(HttpStatus.CONFLICT.value(), e.getMessage());
        }
        Artwork artwork = artworkService.getById(id);
        return Result.ok(Map.of("is_favorited", true, "favorites_count", artwork != null ? artwork.getFavoritesCount() : 0));
    }

    @DeleteMapping("/{id}/favorite")
    @Operation(summary = "取消收藏")
    public Result<Map<String, Object>> unfavorite(@PathVariable Long id, @AuthenticationPrincipal Long userId) {
        favoriteService.unfavorite(userId, id);
        Artwork artwork = artworkService.getById(id);
        return Result.ok(Map.of("is_favorited", false, "favorites_count", artwork != null ? artwork.getFavoritesCount() : 0));
    }

    @GetMapping("/{id}/comments")
    @Operation(summary = "获取评论列表")
    public Result<PageResult<Comment>> comments(@PathVariable Long id,
                                                 @RequestParam(defaultValue = "1") int page,
                                                 @RequestParam(defaultValue = "20") int size) {
        return Result.ok(commentService.getCommentsWithAuthor(id, page, size));
    }

    @PostMapping("/{id}/comments")
    @Operation(summary = "发表评论")
    public Result<Map<String, String>> addComment(@PathVariable Long id,
                                                   @AuthenticationPrincipal Long userId,
                                                   @RequestBody Map<String, String> body) {
        commentService.addComment(userId, id, body.get("content"), null);
        return Result.ok(Map.of("message", "评论成功"));
    }
}