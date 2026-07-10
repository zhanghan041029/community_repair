package com.zhan.backdemo.service;

import com.zhan.backdemo.entity.Notification;
import com.zhan.backdemo.mapper.NotificationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationMapper notificationMapper;

    public void sendNotification(Long userId, String title, String content, String type) {
        Notification n = new Notification();
        n.setUserId(userId);
        n.setTitle(title);
        n.setContent(content);
        n.setType(type);
        n.setIsRead(0);
        notificationMapper.insert(n);
    }

    public long countUnread(Long userId) {
        return notificationMapper.countUnread(userId);
    }

    public List<Notification> listByUser(Long userId, int limit) {
        return notificationMapper.listByUser(userId, limit);
    }

    public void markRead(Long id, Long userId) {
        notificationMapper.markRead(id, userId);
    }

    public void markAllRead(Long userId) {
        notificationMapper.markAllRead(userId);
    }
}
