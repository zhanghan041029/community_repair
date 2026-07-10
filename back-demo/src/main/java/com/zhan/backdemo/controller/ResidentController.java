package com.zhan.backdemo.controller;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.common.Result;
import com.zhan.backdemo.context.UserContext;
import com.zhan.backdemo.service.UserService;
import com.zhan.backdemo.vo.ResidentListVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/residents")
@RequiredArgsConstructor
public class ResidentController {

    private final UserService userService;

    @GetMapping
    public Result<PageResult<ResidentListVO>> listResidents(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String phone) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        return Result.success(userService.listResidents(page, pageSize, name, phone));
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteResident(@PathVariable Long id) {
        userService.checkRole(UserContext.getRole(), Constants.ROLE_ADMIN);
        userService.deleteResident(id);
        return Result.success("删除成功");
    }
}
