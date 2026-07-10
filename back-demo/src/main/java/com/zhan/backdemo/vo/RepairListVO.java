package com.zhan.backdemo.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RepairListVO {

    private Long id;
    private String title;
    private String description;
    private String address;
    private String status;
    private String priority;
    private LocalDateTime createTime;
    private String workerName;
    private String workerAvatar;
    private String userName;
    private Boolean hasEvaluation;
    private Integer evaluationScore;
    private String evaluationContent;
    private String result;
    private String image;
    private Integer pendingDays;
}
