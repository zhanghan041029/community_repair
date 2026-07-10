package com.zhan.backdemo.mapper;

import com.zhan.backdemo.entity.Announcement;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AnnouncementMapper {

    int insert(Announcement announcement);

    List<Announcement> listAll();

    Announcement findById(@Param("id") Long id);

    int deleteById(@Param("id") Long id);
}
