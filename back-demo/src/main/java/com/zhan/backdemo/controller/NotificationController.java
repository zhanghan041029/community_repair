package com.zhan.backdemo.controller;

import com.zhan.backdemo.common.Result;
import com.zhan.backdemo.context.UserContext;
import com.zhan.backdemo.entity.Notification;
import com.zhan.backdemo.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/unread-count")
    public Result<Long> unreadCount() {
        return Result.success(notificationService.countUnread(UserContext.getUserId()));
    }

    @GetMapping
    public Result<List<Notification>> list(@RequestParam(defaultValue = "10") int limit) {
        return Result.success(notificationService.listByUser(UserContext.getUserId(), limit));
    }

    @PostMapping("/{id}/read")
    public Result<Void> markRead(@PathVariable Long id) {
        notificationService.markRead(id, UserContext.getUserId());
        return Result.success(null);
    }

    @PostMapping("/read-all")
    public Result<Void> markAllRead() {
        notificationService.markAllRead(UserContext.getUserId());
        return Result.success(null);
    }
}
