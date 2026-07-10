package com.zhan.backdemo.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RepairDetailVO {

    private Long id;
    private Long userId;
    private String userName;
    private Long workerId;
    private String workerName;
    private String workerAvatar;
    private String title;
    private String description;
    private String address;
    private String contactPhone;
    private String status;
    private String priority;
    private String result;
    private String image;
    private LocalDateTime assignTime;
    private LocalDateTime finishTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
