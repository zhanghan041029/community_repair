package com.zhan.backdemo.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Announcement {

    private Long id;
    private String title;
    private String content;
    private Long publisherId;
    private String publisherName;
    private LocalDateTime createTime;
}
