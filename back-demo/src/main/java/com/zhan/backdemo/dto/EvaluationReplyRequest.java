package com.zhan.backdemo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class EvaluationReplyRequest {

    @NotNull(message = "评价ID不能为空")
    private Long evaluationId;

    @NotBlank(message = "回复内容不能为空")
    private String reply;
}
