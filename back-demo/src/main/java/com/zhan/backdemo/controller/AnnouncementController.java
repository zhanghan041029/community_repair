package com.zhan.backdemo.controller;

import com.zhan.backdemo.common.Result;
import com.zhan.backdemo.context.UserContext;
import com.zhan.backdemo.dto.AnnouncementCreateRequest;
import com.zhan.backdemo.entity.Announcement;
import com.zhan.backdemo.service.AnnouncementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;

    @PostMapping
    public Result<Announcement> create(@Valid @RequestBody AnnouncementCreateRequest request) {
        Announcement announcement = announcementService.create(request, UserContext.getUserId());
        return Result.success(announcement);
    }

    @GetMapping
    public Result<List<Announcement>> list() {
        return Result.success(announcementService.listAll());
    }

    @GetMapping("/{id}")
    public Result<Announcement> detail(@PathVariable Long id) {
        return Result.success(announcementService.getById(id));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        announcementService.delete(id);
        return Result.success(null);
    }
}
