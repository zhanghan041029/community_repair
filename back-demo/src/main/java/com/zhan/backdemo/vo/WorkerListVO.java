package com.zhan.backdemo.vo;

import lombok.Data;

@Data
public class WorkerListVO {

    private Long id;
    private String name;
    private String phone;
    private String avatar;
    private String skill;
    private String status;
    private Integer workCount;
    private Double avgScore;
    private String registerType;
}
