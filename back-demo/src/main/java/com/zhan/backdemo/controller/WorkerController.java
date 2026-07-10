package com.zhan.backdemo.controller;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.common.Result;
import com.zhan.backdemo.context.UserContext;
import com.zhan.backdemo.dto.WorkerAddRequest;
import com.zhan.backdemo.dto.WorkerRegisterRequest;
import com.zhan.backdemo.dto.WorkerReviewRequest;
import com.zhan.backdemo.service.UserService;
import com.zhan.backdemo.service.WorkerService;
import com.zhan.backdemo.vo.WorkerListVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/workers")
@RequiredArgsConstructor
public class WorkerController {

    private final WorkerService workerService;
    private final UserService userService;

    @PostMapping("/register")
    public Result<Map<String, Object>> registerWorker(@Valid @RequestBody WorkerRegisterRequest request) {
        Map<String, Object> data = workerService.registerWorker(request);
        return Result.success("注册成功，请等待管理员审核", data);
    }

    @PostMapping
    public Result<Map<String, Object>> addWorker(@Valid @RequestBody WorkerAddRequest request) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        return Result.success(workerService.addWorker(request));
    }

    @GetMapping
    public Result<PageResult<WorkerListVO>> listWorkers(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String phone,
            @RequestParam(required = false) String status) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        return Result.success(workerService.listWorkers(page, pageSize, name, phone, status));
    }

    @GetMapping("/active")
    public Result<PageResult<WorkerListVO>> listActiveWorkers(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String name) {
        return Result.success(workerService.listWorkers(page, pageSize, name, null, Constants.USER_STATUS_ACTIVE));
    }

    @PutMapping("/review")
    public Result<Void> reviewWorker(@Valid @RequestBody WorkerReviewRequest request) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        workerService.reviewWorker(request);
        return Result.success("审核完成");
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteWorker(@PathVariable Long id) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        workerService.deleteWorker(id);
        return Result.success("删除成功");
    }
}
