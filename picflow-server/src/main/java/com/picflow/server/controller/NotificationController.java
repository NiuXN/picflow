package com.picflow.server.controller;

import com.picflow.server.common.PageResult;
import com.picflow.server.common.Result;
import com.picflow.server.entity.Notification;
import com.picflow.server.service.NotificationService;

/** 通知公告接口：获取通知列表 */
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@Tag(name = "通知接口", description = "通知公告查询")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @Operation(summary = "获取通知列表")
    public Result<PageResult<Notification>> list(@RequestParam(defaultValue = "1") int page,
                                                  @RequestParam(defaultValue = "20") int size) {
        return Result.ok(notificationService.getNotifications(page, size));
    }
}