package com.picflow.server.controller;

import com.picflow.server.entity.Notification;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * SSE 订阅接口——Flutter App 通过此接口建立长连接，实时接收通知推送
 */
@RestController
@RequestMapping("/sse")
public class SseController {

    /** 所有已连接的客户端 */
    public static final List<SseEmitter> emitters = new CopyOnWriteArrayList<>();

    /**
     * Flutter App 订阅 SSE 推送
     * @return SseEmitter（永不超时，由客户端主动断开）
     */
    @GetMapping("/subscribe")
    public SseEmitter subscribe() {
        SseEmitter emitter = new SseEmitter(Long.MAX_VALUE);
        emitters.add(emitter);
        emitter.onCompletion(() -> emitters.remove(emitter));
        emitter.onTimeout(() -> emitters.remove(emitter));
        emitter.onError(e -> emitters.remove(emitter));

        // 发送初始连接确认
        try {
            emitter.send(SseEmitter.event().name("connected").data("ok"));
        } catch (IOException ignored) {}

        return emitter;
    }

    /**
     * 向所有已连接的 App 广播通知
     * @param notification 通知对象
     */
    public static void broadcast(Notification notification) {
        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event()
                        .name("notification")
                        .data(notification));
            } catch (IOException e) {
                emitters.remove(emitter);
            }
        }
    }
}
