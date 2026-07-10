package com.zhan.backdemo.service;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.dto.LoginRequest;
import com.zhan.backdemo.dto.LoginResponse;
import com.zhan.backdemo.dto.ResidentRegisterRequest;
import com.zhan.backdemo.dto.UpdateProfileRequest;
import com.zhan.backdemo.entity.SysUser;
import com.zhan.backdemo.exception.BusinessException;
import com.zhan.backdemo.mapper.RepairOrderMapper;
import com.zhan.backdemo.mapper.SysUserMapper;
import com.zhan.backdemo.util.JwtUtil;
import com.zhan.backdemo.vo.ResidentListVO;
import com.zhan.backdemo.vo.UserInfoVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final SysUserMapper sysUserMapper;
    private final RepairOrderMapper repairOrderMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // 使用项目根目录下的 uploads 文件夹，兼容不同电脑的路径
    private static final String UPLOAD_DIR = System.getProperty("user.dir") + "/uploads/avatar/";
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024;
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    public LoginResponse login(LoginRequest request) {
        SysUser user = sysUserMapper.findByUsername(request.getUsername());
        if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        if (!request.getRole().equals(user.getRole())) {
            throw new BusinessException("身份错误，请选择正确的身份登录");
        }

        if (Constants.ROLE_WORKER.equals(user.getRole())) {
            if (Constants.USER_STATUS_PENDING.equals(user.getStatus())) {
                LoginResponse response = new LoginResponse();
                response.setUserId(user.getId());
                response.setRole(user.getRole());
                response.setStatus(user.getStatus());
                throw new BusinessException("账号尚未通过审核，请联系管理员", response);
            }
            if (Constants.USER_STATUS_REJECTED.equals(user.getStatus())) {
                LoginResponse response = new LoginResponse();
                response.setUserId(user.getId());
                response.setRole(user.getRole());
                response.setStatus(user.getStatus());
                throw new BusinessException("账号审核未通过，请联系管理员", response);
            }
        }

        LoginResponse response = new LoginResponse();
        response.setToken(jwtUtil.generateToken(user.getId(), user.getRole()));
        response.setUserId(user.getId());
        response.setRole(user.getRole());
        response.setAvatar(user.getAvatar());
        return response;
    }

    public void registerResident(ResidentRegisterRequest request) {
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
        user.setAddress(request.getAddress());
        user.setRole(Constants.ROLE_RESIDENT);
        user.setStatus(Constants.USER_STATUS_ACTIVE);
        user.setRegisterType(Constants.REGISTER_TYPE_REGISTER);
        sysUserMapper.insert(user);
    }

    public UserInfoVO getCurrentUser(Long userId) {
        SysUser user = sysUserMapper.findById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        UserInfoVO vo = new UserInfoVO();
        vo.setId(user.getId());
        vo.setName(user.getName());
        vo.setUsername(user.getUsername());
        vo.setPhone(user.getPhone());
        vo.setRole(user.getRole());
        vo.setAvatar(user.getAvatar());
        if (Constants.ROLE_RESIDENT.equals(user.getRole())) {
            vo.setAddress(user.getAddress());
        }
        if (Constants.ROLE_WORKER.equals(user.getRole())) {
            vo.setSkill(user.getSkill());
            vo.setStatus(user.getStatus());
        }
        return vo;
    }

    public Map<String, Object> uploadAvatar(Long userId, MultipartFile file) {
        if (file.isEmpty()) {
            throw new BusinessException("文件不能为空");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new BusinessException("文件大小不能超过2MB");
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || !originalFilename.matches(".*\\.(jpg|jpeg|png|gif|webp)$")) {
            throw new BusinessException("仅支持 jpg、png、gif、webp 格式的图片");
        }

        String dateDir = LocalDate.now().format(DATE_FMT);
        String ext = originalFilename.substring(originalFilename.lastIndexOf("."));
        String newFilename = UUID.randomUUID().toString() + ext;
        String relativePath = dateDir + "/" + newFilename;

        File destDir = new File(UPLOAD_DIR, dateDir);
        if (!destDir.exists()) {
            destDir.mkdirs();
        }

        try {
            file.transferTo(new File(UPLOAD_DIR + relativePath));
        } catch (IOException e) {
            throw new BusinessException("头像上传失败");
        }

        String avatarUrl = "/uploads/avatar/" + relativePath;
        SysUser update = new SysUser();
        update.setId(userId);
        update.setAvatar(avatarUrl);
        sysUserMapper.update(update);

        Map<String, Object> data = new HashMap<>();
        data.put("avatarUrl", avatarUrl);
        return data;
    }

    public void updateProfile(Long userId, UpdateProfileRequest request) {
        SysUser user = sysUserMapper.findById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        SysUser update = new SysUser();
        update.setId(userId);

        if (StringUtils.hasText(request.getPhone())) {
            if (!request.getPhone().equals(user.getPhone())) {
                if (sysUserMapper.findByPhone(request.getPhone()) != null) {
                    throw new BusinessException("手机号已被注册");
                }
            }
            update.setPhone(request.getPhone());
        }
        if (request.getAddress() != null) {
            update.setAddress(request.getAddress());
        }
        if (request.getSkill() != null) {
            update.setSkill(request.getSkill());
        }
        if (StringUtils.hasText(request.getPassword())) {
            update.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        sysUserMapper.update(update);
    }

    public void changePassword(Long userId, String oldPassword, String newPassword) {
        SysUser user = sysUserMapper.findById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BusinessException("原密码错误");
        }
        if (newPassword == null || newPassword.length() < 6) {
            throw new BusinessException("新密码长度不能少于6位");
        }
        SysUser update = new SysUser();
        update.setId(userId);
        update.setPassword(passwordEncoder.encode(newPassword));
        sysUserMapper.update(update);
    }

    public void resetPassword(String username, String phone, String newPassword) {
        SysUser user = sysUserMapper.findByUsername(username);
        if (user == null) {
            throw new BusinessException("用户名不存在");
        }
        if (!phone.equals(user.getPhone())) {
            throw new BusinessException("手机号与注册时不一致");
        }
        if (newPassword == null || newPassword.length() < 6) {
            throw new BusinessException("新密码长度不能少于6位");
        }
        SysUser update = new SysUser();
        update.setId(user.getId());
        update.setPassword(passwordEncoder.encode(newPassword));
        sysUserMapper.update(update);
    }

    public void checkRole(String role, String... allowedRoles) {
        for (String allowedRole : allowedRoles) {
            if (allowedRole.equals(role)) {
                return;
            }
        }
        throw new BusinessException("无权限访问");
    }

    public PageResult<ResidentListVO> listResidents(Integer page, Integer pageSize, String name, String phone) {
        int currentPage = page == null || page < 1 ? 1 : page;
        int size = pageSize == null || pageSize < 1 ? 10 : pageSize;
        int offset = (currentPage - 1) * size;

        long total = sysUserMapper.countResidents(name, phone);
        List<ResidentListVO> rows = sysUserMapper.listResidents(name, phone, offset, size);
        return new PageResult<>(total, rows);
    }

    public void deleteResident(Long id) {
        SysUser resident = sysUserMapper.findById(id);
        if (resident == null || !Constants.ROLE_RESIDENT.equals(resident.getRole())) {
            throw new BusinessException("居民不存在");
        }
        int incompleteCount = repairOrderMapper.countIncompleteByResidentId(id);
        if (incompleteCount > 0) {
            throw new BusinessException("该居民存在未完成的工单，无法删除");
        }
        sysUserMapper.deleteById(id);
    }
}
