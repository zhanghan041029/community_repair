package com.zhan.backdemo.controller;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.common.Result;
import com.zhan.backdemo.context.UserContext;
import com.zhan.backdemo.dto.RepairAssignRequest;
import com.zhan.backdemo.dto.RepairCreateRequest;
import com.zhan.backdemo.dto.RepairStatusRequest;
import com.zhan.backdemo.dto.RepairUpdateRequest;
import com.zhan.backdemo.entity.SysUser;
import com.zhan.backdemo.mapper.SysUserMapper;
import com.zhan.backdemo.service.NotificationService;
import com.zhan.backdemo.service.RepairService;
import com.zhan.backdemo.service.UserService;
import com.zhan.backdemo.vo.RepairDetailVO;
import com.zhan.backdemo.vo.RepairListVO;
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

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/repairs")
@RequiredArgsConstructor
public class RepairController {

    private final RepairService repairService;
    private final UserService userService;
    private final NotificationService notificationService;
    private final SysUserMapper sysUserMapper;

    @GetMapping
    public Result<PageResult<RepairListVO>> listRepairs(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String residentName,
            @RequestParam(required = false) String workerName,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {
        return Result.success(repairService.listRepairs(
                UserContext.getRole(),
                UserContext.getUserId(),
                page,
                pageSize,
                title,
                status,
                residentName,
                workerName,
                startTime,
                endTime
        ));
    }

    @PostMapping
    public Result<Map<String, Object>> createRepair(@Valid @RequestBody RepairCreateRequest request) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_RESIDENT);
        Map<String, Object> result = repairService.createRepair(UserContext.getUserId(), request);

        // 给所有管理员发送新工单通知
        Long repairId = ((Number) result.get("repairId")).longValue();
        List<SysUser> admins = sysUserMapper.listByRole(Constants.ROLE_ADMIN);
        for (SysUser admin : admins) {
            notificationService.sendNotification(
                    admin.getId(),
                    "新工单提醒",
                    "居民提交了新工单：" + request.getTitle() + "（工单号 #" + repairId + "），请及时处理。",
                    "repair"
            );
        }
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<RepairDetailVO> getRepairDetail(@PathVariable Long id) {
        return Result.success(repairService.getRepairDetail(id, UserContext.getRole(), UserContext.getUserId()));
    }

    @PutMapping
    public Result<Void> updateRepair(@RequestBody RepairUpdateRequest request) {
        repairService.updateRepair(request, UserContext.getRole(), UserContext.getUserId());
        return Result.success("修改成功");
    }

    @DeleteMapping("/{id}")
    public Result<Void> cancelRepair(@PathVariable Long id) {
        repairService.cancelRepair(id, UserContext.getRole(), UserContext.getUserId());
        return Result.success("取消成功");
    }

    @PostMapping("/assign")
    public Result<Void> assignRepair(@Valid @RequestBody RepairAssignRequest request) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        repairService.assignRepair(request);
        return Result.success("派单成功");
    }

    @PutMapping("/status")
    public Result<Void> updateRepairStatus(@Valid @RequestBody RepairStatusRequest request) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_WORKER);
        repairService.updateRepairStatus(request, UserContext.getUserId());
        return Result.success("状态更新成功");
    }

    @GetMapping("/stats")
    public Result<Map<String, Object>> getRepairStats() {
        return Result.success(repairService.getRepairStats(UserContext.getUserId()));
    }

    @GetMapping("/admin/dashboard")
    public Result<Map<String, Object>> getAdminDashboardStats() {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        return Result.success(repairService.getAdminDashboardStats());
    }
}
