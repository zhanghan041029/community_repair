package com.zhan.backdemo.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RepairAssignRequest {

    @NotNull(message = "工单ID不能为空")
    private Long repairId;

    @NotNull(message = "维修工ID不能为空")
    private Long workerId;
}
