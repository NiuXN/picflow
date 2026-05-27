package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.common.PageResult;
import com.picflow.server.controller.SseController;
import com.picflow.server.entity.Notification;
import com.picflow.server.mapper.NotificationMapper;
import com.picflow.server.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl extends ServiceImpl<NotificationMapper, Notification> implements NotificationService {

    @Override
    public PageResult<Notification> getNotifications(int page, int size) {
        LambdaQueryWrapper<Notification> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Notification::getCreatedAt);

        Page<Notification> pageResult = this.page(new Page<>(page, size), wrapper);
        return PageResult.of(pageResult.getTotal(), page, size, pageResult.getRecords());
    }

    @Override
    public Notification createNotification(String title, String content) {
        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setContent(content);
        notification.setTarget("all");
        this.save(notification);
        // SSE 实时推送到所有已连接的 App
        SseController.broadcast(notification);
        return notification;
    }
}