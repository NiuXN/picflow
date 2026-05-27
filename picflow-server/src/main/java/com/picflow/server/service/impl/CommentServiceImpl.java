package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.entity.Artwork;
import com.picflow.server.entity.Comment;
import com.picflow.server.mapper.ArtworkMapper;
import com.picflow.server.mapper.CommentMapper;
import com.picflow.server.service.CommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommentServiceImpl extends ServiceImpl<CommentMapper, Comment> implements CommentService {

    private final ArtworkMapper artworkMapper;

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
}