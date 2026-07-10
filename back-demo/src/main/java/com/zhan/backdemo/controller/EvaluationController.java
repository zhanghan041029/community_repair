package com.zhan.backdemo.controller;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.common.Result;
import com.zhan.backdemo.context.UserContext;
import com.zhan.backdemo.dto.EvaluationCreateRequest;
import com.zhan.backdemo.dto.EvaluationReplyRequest;
import com.zhan.backdemo.service.EvaluationService;
import com.zhan.backdemo.service.UserService;
import com.zhan.backdemo.vo.EvaluationVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/evaluations")
@RequiredArgsConstructor
public class EvaluationController {

    private final EvaluationService evaluationService;
    private final UserService userService;

    @PostMapping
    public Result<Void> createEvaluation(@Valid @RequestBody EvaluationCreateRequest request) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_RESIDENT);
        evaluationService.createEvaluation(UserContext.getUserId(), request);
        return Result.success("评价成功");
    }

    @GetMapping("/repair/{repairId}")
    public Result<EvaluationVO> getEvaluationByRepairId(@PathVariable Long repairId) {
        return Result.success(evaluationService.getEvaluationByRepairId(
                repairId,
                UserContext.getRole(),
                UserContext.getUserId()
        ));
    }

    @GetMapping("/my")
    public Result<PageResult<EvaluationVO>> getMyEvaluations(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer pageSize) {
        return Result.success(evaluationService.getMyEvaluations(
                UserContext.getUserId(), page, pageSize));
    }

    @PutMapping("/reply")
    public Result<Void> replyEvaluation(@Valid @RequestBody EvaluationReplyRequest request) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_WORKER);
        evaluationService.replyEvaluation(request, UserContext.getUserId());
        return Result.success("回复成功");
    }
}
