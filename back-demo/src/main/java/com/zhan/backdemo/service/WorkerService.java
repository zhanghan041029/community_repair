package com.zhan.backdemo.service;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.dto.WorkerAddRequest;
import com.zhan.backdemo.dto.WorkerRegisterRequest;
import com.zhan.backdemo.dto.WorkerReviewRequest;
import com.zhan.backdemo.entity.SysUser;
import com.zhan.backdemo.exception.BusinessException;
import com.zhan.backdemo.mapper.RepairOrderMapper;
import com.zhan.backdemo.mapper.SysUserMapper;
import com.zhan.backdemo.vo.WorkerListVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class WorkerService {

    private final SysUserMapper sysUserMapper;
    private final RepairOrderMapper repairOrderMapper;
    private final PasswordEncoder passwordEncoder;
    private final NotificationService notificationService;

    public Map<String, Object> registerWorker(WorkerRegisterRequest request) {
        if (sysUserMapper.findByUsername(request.getUsername()) != null) {
            throw new BusinessException("用户名已存在");
        }
        if (sysUserMapper.findByPhone(request.getPhone()) != null) {
            throw new BusinessException("手机号已被注册");
        }

        SysUser user = new SysUser();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setPhone(request.getPhone());
        user.setSkill(request.getSkill());
        user.setRole(Constants.ROLE_WORKER);
        user.setStatus(Constants.USER_STATUS_PENDING);
        user.setRegisterType(Constants.REGISTER_TYPE_REGISTER);
        sysUserMapper.insert(user);

        Map<String, Object> data = new HashMap<>();
        data.put("workerId", user.getId());
        data.put("status", user.getStatus());

        // 通知所有管理员
        List<SysUser> admins = sysUserMapper.listByRole(Constants.ROLE_ADMIN);
        for (SysUser admin : admins) {
            notificationService.sendNotification(admin.getId(), "新维修工注册",
                    "有新的维修工「" + user.getName() + "」提交了注册申请，请尽快审核", "worker_register");
        }

        return data;
    }

    public Map<String, Object> addWorker(WorkerAddRequest request) {
        if (sysUserMapper.findByUsername(request.getUsername()) != null) {
            throw new BusinessException("用户名已存在");
        }
        if (sysUserMapper.findByPhone(request.getPhone()) != null) {
            throw new BusinessException("手机号已被注册");
        }

        SysUser user = new SysUser();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setPhone(request.getPhone());
        user.setSkill(request.getSkill());
        user.setRole(Constants.ROLE_WORKER);
        user.setStatus(Constants.USER_STATUS_ACTIVE);
        user.setRegisterType(Constants.REGISTER_TYPE_ADMIN_ADD);
        sysUserMapper.insert(user);

        Map<String, Object> data = new HashMap<>();
        data.put("workerId", user.getId());
        return data;
    }

    public PageResult<WorkerListVO> listWorkers(Integer page, Integer pageSize, String name, String phone, String status) {
        int currentPage = page == null || page < 1 ? 1 : page;
        int size = pageSize == null || pageSize < 1 ? 10 : pageSize;
        int offset = (currentPage - 1) * size;

        long total = sysUserMapper.countWorkers(name, phone, status);
        List<WorkerListVO> rows = sysUserMapper.listWorkers(name, phone, status, offset, size);
        return new PageResult<>(total, rows);
    }

    public void reviewWorker(WorkerReviewRequest request) {
        SysUser worker = sysUserMapper.findById(request.getWorkerId());
        if (worker == null || !Constants.ROLE_WORKER.equals(worker.getRole())) {
            throw new BusinessException("维修工不存在");
        }
        if (!Constants.USER_STATUS_PENDING.equals(worker.getStatus())) {
            throw new BusinessException("该维修工不在待审核状态");
        }

        SysUser update = new SysUser();
        update.setId(worker.getId());
        if (Boolean.TRUE.equals(request.getApproved())) {
            update.setStatus(Constants.USER_STATUS_ACTIVE);
            update.setRejectReason(null);
        } else {
            if (!StringUtils.hasText(request.getRejectReason())) {
                throw new BusinessException("拒绝原因不能为空");
            }
            update.setStatus(Constants.USER_STATUS_REJECTED);
            update.setRejectReason(request.getRejectReason());
        }
        sysUserMapper.update(update);

        // 通知维修工审核结果
        if (Boolean.TRUE.equals(request.getApproved())) {
            notificationService.sendNotification(worker.getId(), "审核通过",
                    "您的维修工账号已通过审核，可以开始接单了", "review_passed");
        } else {
            notificationService.sendNotification(worker.getId(), "审核未通过",
                    "您的维修工账号审核未通过，原因：" + request.getRejectReason(), "review_rejected");
        }
    }

    public void deleteWorker(Long id) {
        SysUser worker = sysUserMapper.findById(id);
        if (worker == null || !Constants.ROLE_WORKER.equals(worker.getRole())) {
            throw new BusinessException("维修工不存在");
        }
        int incompleteCount = repairOrderMapper.countIncompleteByWorkerId(id);
        if (incompleteCount > 0) {
            throw new BusinessException("该维修工存在未完成的工单，无法删除");
        }
        sysUserMapper.deleteById(id);
    }

    public SysUser getActiveWorker(Long workerId) {
        SysUser worker = sysUserMapper.findById(workerId);
        if (worker == null || !Constants.ROLE_WORKER.equals(worker.getRole())) {
            throw new BusinessException("维修工不存在");
        }
        if (!Constants.USER_STATUS_ACTIVE.equals(worker.getStatus())) {
            throw new BusinessException("只能指派状态为 active 的维修工");
        }
        return worker;
    }
}
