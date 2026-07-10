package com.zhan.backdemo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RepairCreateRequest {

    @NotBlank(message = "报修标题不能为空")
    private String title;

    @NotBlank(message = "故障描述不能为空")
    private String description;

    @NotBlank(message = "维修地址不能为空")
    private String address;

    @NotBlank(message = "联系电话不能为空")
    private String contactPhone;

    private String image;

    private String priority;
}
