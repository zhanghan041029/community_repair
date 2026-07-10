package com.zhan.backdemo.mapper;

import com.zhan.backdemo.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface NotificationMapper {

    int insert(Notification notification);

    int batchInsert(@Param("list") List<Map<String, Object>> notifications);

    int markRead(@Param("id") Long id, @Param("userId") Long userId);

    int markAllRead(@Param("userId") Long userId);

    long countUnread(@Param("userId") Long userId);

    List<Notification> listByUser(@Param("userId") Long userId, @Param("limit") int limit);
}
