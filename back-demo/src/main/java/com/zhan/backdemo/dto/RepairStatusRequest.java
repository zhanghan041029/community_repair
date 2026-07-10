package com.zhan.backdemo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RepairStatusRequest {

    @NotNull(message = "工单ID不能为空")
    private Long repairId;

    @NotBlank(message = "状态不能为空")
    private String status;

    private String result;
}
