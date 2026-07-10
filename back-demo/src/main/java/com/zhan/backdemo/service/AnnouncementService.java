package com.zhan.backdemo.service;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.dto.AnnouncementCreateRequest;
import com.zhan.backdemo.entity.Announcement;
import com.zhan.backdemo.entity.SysUser;
import com.zhan.backdemo.mapper.AnnouncementMapper;
import com.zhan.backdemo.mapper.NotificationMapper;
import com.zhan.backdemo.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AnnouncementService {

    private final AnnouncementMapper announcementMapper;
    private final SysUserMapper sysUserMapper;
    private final NotificationMapper notificationMapper;

    @Transactional
    public Announcement create(AnnouncementCreateRequest request, Long publisherId) {
        // 获取发布者名称
        SysUser publisher = sysUserMapper.findById(publisherId);
        String publisherName = publisher != null ? publisher.getName() : "管理员";

        // 保存公告
        Announcement announcement = new Announcement();
        announcement.setTitle(request.getTitle());
        announcement.setContent(request.getContent());
        announcement.setPublisherId(publisherId);
        announcement.setPublisherName(publisherName);
        announcementMapper.insert(announcement);

        // 查询所有活跃的居民和维修工，发送通知
        List<SysUser> residents = sysUserMapper.listByRole(Constants.ROLE_RESIDENT);
        List<SysUser> workers = sysUserMapper.listActiveWorkers();

        List<Map<String, Object>> notifications = new ArrayList<>();
        for (SysUser user : residents) {
            Map<String, Object> n = new HashMap<>();
            n.put("userId", user.getId());
            n.put("title", "新公告通知");
            n.put("content", "管理员发布了新公告：" + request.getTitle());
            n.put("type", "announcement");
            notifications.add(n);
        }
        for (SysUser user : workers) {
            Map<String, Object> n = new HashMap<>();
            n.put("userId", user.getId());
            n.put("title", "新公告通知");
            n.put("content", "管理员发布了新公告：" + request.getTitle());
            n.put("type", "announcement");
            notifications.add(n);
        }

        if (!notifications.isEmpty()) {
            notificationMapper.batchInsert(notifications);
        }

        return announcement;
    }

    public List<Announcement> listAll() {
        return announcementMapper.listAll();
    }

    public Announcement getById(Long id) {
        return announcementMapper.findById(id);
    }

    public void delete(Long id) {
        announcementMapper.deleteById(id);
    }
}
