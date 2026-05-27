package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.Comment;

import java.util.List;

public interface CommentService extends IService<Comment> {

    Comment addComment(Long userId, Long artworkId, String content, Long parentId);

    void deleteComment(Long commentId, Long userId);
}