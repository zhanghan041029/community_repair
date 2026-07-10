package com.zhan.backdemo.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Evaluation {

    private Long id;
    private Long repairId;
    private Long userId;
    private Integer score;
    private String comment;
    private String reply;
    private LocalDateTime replyTime;
    private LocalDateTime createTime;
}
