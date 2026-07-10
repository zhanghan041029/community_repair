package com.zhan.backdemo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ResidentRegisterRequest {

    @NotBlank(message = "姓名不能为空")
    private String name;

    @NotBlank(message = "用户名不能为空")
    private String username;

    @NotBlank(message = "手机号不能为空")
    private String phone;

    @NotBlank(message = "居住地址不能为空")
    private String address;

    @NotBlank(message = "密码不能为空")
    private String password;
}
