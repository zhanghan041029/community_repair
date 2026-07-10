package com.zhan.backdemo.service;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.dto.RepairAssignRequest;
import com.zhan.backdemo.dto.RepairCreateRequest;
import com.zhan.backdemo.dto.RepairStatusRequest;
import com.zhan.backdemo.dto.RepairUpdateRequest;
import com.zhan.backdemo.entity.RepairOrder;
import com.zhan.backdemo.entity.SysUser;
import com.zhan.backdemo.exception.BusinessException;
import com.zhan.backdemo.mapper.RepairOrderMapper;
import com.zhan.backdemo.mapper.SysUserMapper;
import com.zhan.backdemo.vo.RepairDetailVO;
import com.zhan.backdemo.vo.RepairListVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RepairService {

    private final RepairOrderMapper repairOrderMapper;
    private final SysUserMapper sysUserMapper;
    private final WorkerService workerService;
    private final NotificationService notificationService;

    public PageResult<RepairListVO> listRepairs(String role, Long userId, Integer page, Integer pageSize,
                                                String title, String status, String residentName, String workerName,
                                                String startTime, String endTime) {
        int currentPage = page == null || page < 1 ? 1 : page;
        int size = pageSize == null || pageSize < 1 ? 10 : pageSize;
        int offset = (currentPage - 1) * size;

        long total = repairOrderMapper.countRepairs(role, userId, title, status, residentName, workerName, startTime, endTime);
        List<RepairListVO> rows = repairOrderMapper.listRepairs(role, userId, title, status, residentName, workerName, startTime, endTime, offset, size);
        return new PageResult<>(total, rows);
    }

    public Map<String, Object> createRepair(Long userId, RepairCreateRequest request) {
        RepairOrder order = new RepairOrder();
        order.setUserId(userId);
        order.setTitle(request.getTitle());
        order.setDescription(request.getDescription());
        order.setAddress(request.getAddress());
        order.setContactPhone(request.getContactPhone());
        order.setImage(request.getImage());
        order.setPriority(request.getPriority() != null ? request.getPriority() : "normal");
        order.setStatus(Constants.REPAIR_STATUS_PENDING);
        repairOrderMapper.insert(order);

        Map<String, Object> data = new HashMap<>();
        data.put("repairId", order.getId());

        // 通知所有管理员
        List<SysUser> admins = sysUserMapper.listByRole(Constants.ROLE_ADMIN);
        for (SysUser admin : admins) {
            notificationService.sendNotification(admin.getId(), "新工单提醒",
                    "居民提交了新的报修工单：" + order.getTitle(), "new_repair");
        }

        return data;
    }

    public RepairDetailVO getRepairDetail(Long id, String role, Long userId) {
        RepairDetailVO detail = repairOrderMapper.findDetailById(id);
        if (detail == null) {
            throw new BusinessException("工单不存在");
        }
        checkRepairAccess(detail, role, userId);
        return detail;
    }

    public void updateRepair(RepairUpdateRequest request, String role, Long userId) {
        if (request.getId() == null) {
            throw new BusinessException("工单ID不能为空");
        }
        if (!StringUtils.hasText(request.getTitle())
                && !StringUtils.hasText(request.getDescription())
                && !StringUtils.hasText(request.getAddress())) {
            throw new BusinessException("至少填写一项修改内容");
        }

        RepairOrder order = repairOrderMapper.findById(request.getId());
        if (order == null) {
            throw new BusinessException("工单不存在");
        }
        checkRepairOwner(order, role, userId);
        if (!Constants.REPAIR_STATUS_PENDING.equals(order.getStatus())) {
            throw new BusinessException("仅待派单状态的工单可以修改");
        }

        RepairOrder update = new RepairOrder();
        update.setId(order.getId());
        update.setTitle(request.getTitle());
        update.setDescription(request.getDescription());
        update.setAddress(request.getAddress());
        repairOrderMapper.update(update);
    }

    public void cancelRepair(Long id, String role, Long userId) {
        RepairOrder order = repairOrderMapper.findById(id);
        if (order == null) {
            throw new BusinessException("工单不存在");
        }
        checkRepairOwner(order, role, userId);
        if (!Constants.REPAIR_STATUS_PENDING.equals(order.getStatus())) {
            throw new BusinessException("仅待派单状态的工单可以取消");
        }

        RepairOrder update = new RepairOrder();
        update.setId(id);
        update.setStatus(Constants.REPAIR_STATUS_CANCELLED);
        repairOrderMapper.update(update);
    }

    public void assignRepair(RepairAssignRequest request) {
        RepairOrder order = repairOrderMapper.findById(request.getRepairId());
        if (order == null) {
            throw new BusinessException("工单不存在");
        }
        if (!Constants.REPAIR_STATUS_PENDING.equals(order.getStatus())) {
            throw new BusinessException("仅待派单状态的工单可以派单");
        }
        workerService.getActiveWorker(request.getWorkerId());

        RepairOrder update = new RepairOrder();
        update.setId(order.getId());
        update.setWorkerId(request.getWorkerId());
        update.setStatus(Constants.REPAIR_STATUS_ASSIGNED);
        update.setAssignTime(LocalDateTime.now());
        repairOrderMapper.update(update);

        // 通知维修工
        notificationService.sendNotification(request.getWorkerId(), "新派单提醒",
                "您有新的维修工单：" + order.getTitle(), "assigned");
    }

    public void updateRepairStatus(RepairStatusRequest request, Long workerId) {
        RepairOrder order = repairOrderMapper.findById(request.getRepairId());
        if (order == null) {
            throw new BusinessException("工单不存在");
        }
        if (!workerId.equals(order.getWorkerId())) {
            throw new BusinessException("只能更新指派给自己的工单");
        }

        String status = request.getStatus();
        if (!Constants.REPAIR_STATUS_PROCESSING.equals(status)
                && !Constants.REPAIR_STATUS_COMPLETED.equals(status)) {
            throw new BusinessException("状态只能更新为 processing 或 completed");
        }

        if (Constants.REPAIR_STATUS_PROCESSING.equals(status)) {
            if (!Constants.REPAIR_STATUS_ASSIGNED.equals(order.getStatus())) {
                throw new BusinessException("仅已派单状态的工单可以开始处理");
            }
        }

        if (Constants.REPAIR_STATUS_COMPLETED.equals(status)) {
            if (!Constants.REPAIR_STATUS_PROCESSING.equals(order.getStatus())
                    && !Constants.REPAIR_STATUS_ASSIGNED.equals(order.getStatus())) {
                throw new BusinessException("当前工单状态无法标记为完成");
            }
            if (!StringUtils.hasText(request.getResult())) {
                throw new BusinessException("完成工单时必须填写维修结果");
            }
        }

        RepairOrder update = new RepairOrder();
        update.setId(order.getId());
        update.setStatus(status);
        if (Constants.REPAIR_STATUS_COMPLETED.equals(status)) {
            update.setResult(request.getResult());
            update.setFinishTime(LocalDateTime.now());
        }
        repairOrderMapper.update(update);

        // 通知居民
        if (Constants.REPAIR_STATUS_PROCESSING.equals(status)) {
            notificationService.sendNotification(order.getUserId(), "工单处理中",
                    "您的工单「" + order.getTitle() + "」已开始处理", "processing");
        } else if (Constants.REPAIR_STATUS_COMPLETED.equals(status)) {
            notificationService.sendNotification(order.getUserId(), "工单已完成",
                    "您的工单「" + order.getTitle() + "」已完成维修", "completed");
        }
    }

    public RepairOrder getRepairOrder(Long id) {
        RepairOrder order = repairOrderMapper.findById(id);
        if (order == null) {
            throw new BusinessException("工单不存在");
        }
        return order;
    }

    public Map<String, Object> getRepairStats(Long userId) {
        long total = repairOrderMapper.countByUserIdAndStatus(userId, null);
        long pending = repairOrderMapper.countByUserIdAndStatus(userId, Constants.REPAIR_STATUS_PENDING);
        long assigned = repairOrderMapper.countByUserIdAndStatus(userId, Constants.REPAIR_STATUS_ASSIGNED);
        long processing = repairOrderMapper.countByUserIdAndStatus(userId, Constants.REPAIR_STATUS_PROCESSING);
        long completed = repairOrderMapper.countByUserIdAndStatus(userId, Constants.REPAIR_STATUS_COMPLETED);
        long cancelled = repairOrderMapper.countByUserIdAndStatus(userId, Constants.REPAIR_STATUS_CANCELLED);

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("total", total);
        stats.put("pending", pending);
        stats.put("assigned", assigned);
        stats.put("processing", processing);
        stats.put("completed", completed);
        stats.put("cancelled", cancelled);
        return stats;
    }

    public Map<String, Object> getAdminDashboardStats() {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        String todayStr = today.format(fmt);
        String weekAgo = today.minusDays(6).format(fmt);
        String monthStart = today.withDayOfMonth(1).format(fmt);

        long todayNew = repairOrderMapper.countRepairs(null, null, null, null, null, null, todayStr, todayStr);
        long pending = repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_PENDING);
        long assigned = repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_ASSIGNED);
        long processing = repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_PROCESSING);
        long monthCompleted = repairOrderMapper.countRepairs(null, null, null, Constants.REPAIR_STATUS_COMPLETED, null, null, monthStart, todayStr);
        long totalWorkers = sysUserMapper.countWorkers(null, null, Constants.USER_STATUS_ACTIVE);

        List<Map<String, Object>> dailyRaw = repairOrderMapper.countDaily(weekAgo, todayStr);
        List<Map<String, Object>> dailyTrend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            String date = today.minusDays(i).format(fmt);
            long count = 0;
            for (Map<String, Object> item : dailyRaw) {
                if (date.equals(item.get("date").toString())) {
                    count = ((Number) item.get("count")).longValue();
                    break;
                }
            }
            Map<String, Object> point = new LinkedHashMap<>();
            point.put("date", date);
            point.put("count", count);
            dailyTrend.add(point);
        }

        Map<String, Object> statusDist = new LinkedHashMap<>();
        statusDist.put("待派单", repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_PENDING));
        statusDist.put("已派单", repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_ASSIGNED));
        statusDist.put("处理中", repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_PROCESSING));
        statusDist.put("已完成", repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_COMPLETED));
        statusDist.put("已取消", repairOrderMapper.countByStatus(Constants.REPAIR_STATUS_CANCELLED));

        List<RepairListVO> recentList = repairOrderMapper.listRecent(10);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("todayNew", todayNew);
        result.put("pendingTotal", pending + assigned + processing);
        result.put("monthCompleted", monthCompleted);
        result.put("totalWorkers", totalWorkers);
        result.put("dailyTrend", dailyTrend);
        result.put("statusDist", statusDist);
        result.put("recentList", recentList);
        return result;
    }

    private void checkRepairOwner(RepairOrder order, String role, Long userId) {
        if (Constants.ROLE_ADMIN.equals(role)) {
            return;
        }
        if (Constants.ROLE_RESIDENT.equals(role) && userId.equals(order.getUserId())) {
            return;
        }
        throw new BusinessException("无权限操作该工单");
    }

    private void checkRepairAccess(RepairDetailVO detail, String role, Long userId) {
        if (Constants.ROLE_ADMIN.equals(role)) {
            return;
        }
        if (Constants.ROLE_RESIDENT.equals(role) && userId.equals(detail.getUserId())) {
            return;
        }
        if (Constants.ROLE_WORKER.equals(role) && userId.equals(detail.getWorkerId())) {
            return;
        }
        throw new BusinessException("无权限查看该工单");
    }
}
