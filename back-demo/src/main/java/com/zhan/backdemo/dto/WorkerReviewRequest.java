package com.zhan.backdemo.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class WorkerReviewRequest {

    @NotNull(message = "维修工ID不能为空")
    private Long workerId;

    @NotNull(message = "审核结果不能为空")
    private Boolean approved;

    private String rejectReason;
}
