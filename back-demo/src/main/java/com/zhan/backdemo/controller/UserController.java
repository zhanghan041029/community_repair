package com.zhan.backdemo.controller;

import com.zhan.backdemo.common.Result;
import com.zhan.backdemo.context.UserContext;
import com.zhan.backdemo.dto.ChangePasswordRequest;
import com.zhan.backdemo.dto.ResidentRegisterRequest;
import com.zhan.backdemo.dto.UpdateProfileRequest;
import com.zhan.backdemo.service.UserService;
import com.zhan.backdemo.vo.UserInfoVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/register")
    public Result<Void> register(@Valid @RequestBody ResidentRegisterRequest request) {
        userService.registerResident(request);
        return Result.success("注册成功");
    }

    @GetMapping("/current")
    public Result<UserInfoVO> getCurrentUser() {
        return Result.success(userService.getCurrentUser(UserContext.getUserId()));
    }

    @PostMapping("/avatar")
    public Result<Map<String, Object>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        return Result.success("头像上传成功", userService.uploadAvatar(UserContext.getUserId(), file));
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody UpdateProfileRequest request) {
        userService.updateProfile(UserContext.getUserId(), request);
        return Result.success("修改成功");
    }

    @PutMapping("/password")
    public Result<Void> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        userService.changePassword(UserContext.getUserId(), request.getOldPassword(), request.getNewPassword());
        return Result.success("密码修改成功");
    }

    @PostMapping("/reset-password")
    public Result<Void> resetPassword(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String phone = body.get("phone");
        String newPassword = body.getOrDefault("newPassword", "123456");
        userService.resetPassword(username, phone, newPassword);
        return Result.success("密码重置成功，新密码为：" + newPassword);
    }
}