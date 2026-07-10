package com.zhan.backdemo.dto;

import lombok.Data;

@Data
public class UpdateProfileRequest {

    private String phone;
    private String address;
    private String skill;
    private String password;
}