package com.zhan.backdemo.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class SysUser {

    private Long id;
    private String username;
    private String password;
    private String name;
    private String phone;
    private String role;
    private String address;
    private String skill;
    private String status;
    private String registerType;
    private String avatar;
    private String rejectReason;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
