package com.zhan.backdemo.dto;

import lombok.Data;

@Data
public class LoginResponse {

    private String token;
    private Long userId;
    private String role;
    private String avatar;
    private String status;
}
