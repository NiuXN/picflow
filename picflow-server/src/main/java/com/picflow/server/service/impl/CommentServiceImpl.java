package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.PageResult;
import com.picflow.server.entity.Artwork;
import com.picflow.server.entity.Comment;
import com.picflow.server.entity.User;
import com.picflow.server.mapper.ArtworkMapper;
import com.picflow.server.mapper.CommentMapper;
import com.picflow.server.service.CommentService;
import com.picflow.server.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentServiceImpl extends ServiceImpl<CommentMapper, Comment> implements CommentService {

    private final ArtworkMapper artworkMapper;
    private final UserService userService;

    @Override
    @Transactional
    public Comment addComment(Long userId, Long artworkId, String content, Long parentId) {
        Comment comment = new Comment();
        comment.setUserId(userId);
        comment.setArtworkId(artworkId);
        comment.setContent(content);
        comment.setParentId(parentId);
        comment.setStatus("published");
        this.save(comment);

        Artwork artwork = artworkMapper.selectById(artworkId);
        if (artwork != null) {
            artwork.setCommentsCount(artwork.getCommentsCount() + 1);
            artworkMapper.updateById(artwork);
        }

        return comment;
    }

    @Override
    public void deleteComment(Long commentId, Long userId) {
        Comment comment = this.getById(commentId);
        if (comment != null && (comment.getUserId().equals(userId))) {
            this.removeById(commentId);
        }
    }

    @Override
    public PageResult<Comment> getCommentsWithAuthor(Long artworkId, int page, int size) {
        Page<Comment> pageResult = this.page(
                new Page<>(page, size),
                new LambdaQueryWrapper<Comment>()
                        .eq(Comment::getArtworkId, artworkId)
                        .isNull(Comment::getParentId)
                        .orderByDesc(Comment::getCreatedAt));

        List<Comment> comments = pageResult.getRecords();
        populateAuthorInfo(comments);
        return PageResult.of(pageResult.getTotal(), page, size, comments);
    }

    private void populateAuthorInfo(List<Comment> comments) {
        Set<Long> userIds = comments.stream()
                .map(Comment::getUserId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        if (userIds.isEmpty()) return;

        Map<Long, User> userMap = userService.listByIds(userIds).stream()
                .collect(Collectors.toMap(User::getId, u -> u));

        for (Comment comment : comments) {
            User author = userMap.get(comment.getUserId());
            if (author != null) {
                User safe = new User();
                safe.setId(author.getId());
                safe.setUsername(author.getUsername());
                safe.setNickname(author.getNickname());
                safe.setAvatarUrl(author.getAvatarUrl());
                comment.setAuthor(safe);
            }
        }
    }
}