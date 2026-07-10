package com.zhan.backdemo.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class EvaluationVO {

    private Long id;
    private Long repairId;
    private Long userId;
    private String userName;
    private Integer score;
    private String comment;
    private String reply;
    private LocalDateTime replyTime;
    private String repairTitle;
    private LocalDateTime createTime;
}
