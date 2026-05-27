package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.common.PageResult;
import com.picflow.server.entity.Notification;

public interface NotificationService extends IService<Notification> {

    PageResult<Notification> getNotifications(int page, int size);

    Notification createNotification(String title, String content);
}