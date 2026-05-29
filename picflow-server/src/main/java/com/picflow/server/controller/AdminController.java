package com.picflow.server.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.picflow.server.common.PageResult;
import com.picflow.server.common.Result;
import com.picflow.server.entity.AppConfig;
import com.picflow.server.entity.AppVersion;
import com.picflow.server.entity.Artwork;
import com.picflow.server.entity.Notification;
import com.picflow.server.entity.User;
import com.picflow.server.service.AppConfigService;
import com.picflow.server.service.AppVersionService;
import com.picflow.server.service.ArtworkService;
import com.picflow.server.service.NotificationService;
import com.picflow.server.service.TagService;
import com.picflow.server.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@Tag(name = "管理后台", description = "管理员专属接口")
public class AdminController {

    private final AppVersionService appVersionService;
    private final ArtworkService artworkService;
    private final UserService userService;
    private final NotificationService notificationService;
    private final TagService tagService;
    private final AppConfigService appConfigService;
    private final StringRedisTemplate stringRedisTemplate;

    @GetMapping("/dashboard")
    @Operation(summary = "数据仪表盘")
    public Result<Map<String, Object>> dashboard() {
        long totalUsers = userService.count();
        long totalArtworks = artworkService.count();

        LambdaQueryWrapper<Artwork> todayWrapper = new LambdaQueryWrapper<>();
        todayWrapper.ge(Artwork::getCreatedAt, LocalDate.now().atStartOfDay());
        long todayNew = artworkService.count(todayWrapper);

        return Result.ok(Map.of(
                "totalArtworks", totalArtworks,
                "totalUsers", totalUsers,
                "todayNew", todayNew
        ));
    }

    @GetMapping("/dashboard/trend")
    @Operation(summary = "近7日数据趋势")
    public Result<Map<String, Object>> dashboardTrend() {
        List<String> dates = new ArrayList<>();
        List<Long> counts = new ArrayList<>();

        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.plusDays(1).atStartOfDay();

            LambdaQueryWrapper<Artwork> wrapper = new LambdaQueryWrapper<>();
            wrapper.ge(Artwork::getCreatedAt, start).lt(Artwork::getCreatedAt, end);
            long count = artworkService.count(wrapper);

            dates.add(date.getMonthValue() + "/" + date.getDayOfMonth());
            counts.add(count);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("dates", dates);
        result.put("counts", counts);
        return Result.ok(result);
    }

    @GetMapping("/artworks")
    @Operation(summary = "作品管理列表")
    public Result<PageResult<Artwork>> artworkList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Artwork> pageResult = artworkService.page(new Page<>(page, size));
        return Result.ok(PageResult.of(pageResult.getTotal(), page, size, pageResult.getRecords()));
    }

    @PutMapping("/artworks/{id}/review")
    @Operation(summary = "审核作品")
    public Result<Map<String, String>> review(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Artwork artwork = artworkService.getById(id);
        if (artwork != null) {
            artwork.setStatus(body.getOrDefault("status", "published"));
            artworkService.updateById(artwork);
        }
        return Result.ok(Map.of("message", "审核完成"));
    }

    @PutMapping("/artworks/{id}/featured")
    @Operation(summary = "设置精选")
    public Result<Map<String, String>> setFeatured(@PathVariable Long id, @RequestBody Map<String, Boolean> body) {
        Artwork artwork = artworkService.getById(id);
        if (artwork != null) {
            artwork.setIsFeatured(body.getOrDefault("isFeatured", false));
            artworkService.updateById(artwork);
        }
        return Result.ok(Map.of("message", "操作成功"));
    }

    @DeleteMapping("/artworks/{id}")
    @Operation(summary = "下架作品")
    public Result<Map<String, String>> remove(@PathVariable Long id) {
        Artwork artwork = artworkService.getById(id);
        if (artwork != null) {
            artwork.setStatus("removed");
            artworkService.updateById(artwork);
        }
        return Result.ok(Map.of("message", "已下架"));
    }

    @GetMapping("/versions")
    @Operation(summary = "版本列表")
    public Result<java.util.List<AppVersion>> versionList() {
        return Result.ok(appVersionService.list());
    }

    @PostMapping("/versions")
    @Operation(summary = "发布新版本")
    public Result<AppVersion> createVersion(@RequestBody AppVersion version) {
        appVersionService.save(version);
        return Result.ok(version);
    }

    @PutMapping("/versions/{id}")
    @Operation(summary = "编辑版本")
    public Result<AppVersion> updateVersion(@PathVariable Long id, @RequestBody AppVersion version) {
        version.setId(id);
        appVersionService.updateById(version);
        return Result.ok(version);
    }

    @DeleteMapping("/versions/{id}")
    @Operation(summary = "删除版本")
    public Result<Map<String, String>> deleteVersion(@PathVariable Long id) {
        appVersionService.removeById(id);
        return Result.ok(Map.of("message", "已删除"));
    }

    @PostMapping("/notifications")
    @Operation(summary = "发布通知")
    public Result<Notification> createNotification(@RequestBody Map<String, String> body) {
        String title = body.get("title");
        String content = body.get("content");
        Notification notification = notificationService.createNotification(title, content);
        return Result.ok(notification);
    }

    @GetMapping("/users")
    @Operation(summary = "用户管理列表")
    public Result<PageResult<User>> userList(@RequestParam(defaultValue = "1") int page,
                                              @RequestParam(defaultValue = "20") int size,
                                              @RequestParam(required = false) String status) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(User::getStatus, status);
        }
        wrapper.orderByDesc(User::getCreatedAt);

        Page<User> pageResult = userService.page(new Page<>(page, size), wrapper);
        return Result.ok(PageResult.of(pageResult.getTotal(), page, size, pageResult.getRecords()));
    }

    @PutMapping("/users/{id}/status")
    @Operation(summary = "封禁/解封用户")
    public Result<User> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        User user = userService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        String status = body.get("status");
        user.setStatus(status);
        userService.updateById(user);

        if ("banned".equals(status)) {
            try {
                stringRedisTemplate.opsForSet().add("blacklist:tokens", id.toString());
            } catch (Exception e) {
                log.warn("Redis 黑名单写入失败 userId={}: {}", id, e.getMessage());
            }
        } else {
            try {
                stringRedisTemplate.opsForSet().remove("blacklist:tokens", id.toString());
            } catch (Exception e) {
                log.warn("Redis 黑名单移除失败 userId={}: {}", id, e.getMessage());
            }
        }

        return Result.ok(user);
    }

    @GetMapping("/tags")
    @Operation(summary = "标签管理列表")
    public Result<List<com.picflow.server.entity.Tag>> tagList() {
        return Result.ok(tagService.getAllTagsAdmin());
    }

    @PostMapping("/tags")
    @Operation(summary = "创建标签")
    public Result<com.picflow.server.entity.Tag> createTag(@RequestBody Map<String, Object> body) {
        String name = (String) body.get("name");
        String description = (String) body.get("description");
        Integer sortOrder = body.get("sortOrder") != null ? ((Number) body.get("sortOrder")).intValue() : 0;
        com.picflow.server.entity.Tag tag = tagService.createTag(name, description, sortOrder);
        return Result.ok(tag);
    }

    @PutMapping("/tags/{id}")
    @Operation(summary = "更新标签")
    public Result<com.picflow.server.entity.Tag> updateTag(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String name = (String) body.get("name");
        String description = (String) body.get("description");
        Integer sortOrder = body.get("sortOrder") != null ? ((Number) body.get("sortOrder")).intValue() : null;
        Boolean enabled = (Boolean) body.get("enabled");
        com.picflow.server.entity.Tag tag = tagService.updateTag(id, name, description, sortOrder, enabled);
        if (tag == null) return Result.error("标签不存在");
        return Result.ok(tag);
    }

    @DeleteMapping("/tags/{id}")
    @Operation(summary = "删除标签")
    public Result<Map<String, String>> deleteTag(@PathVariable Long id) {
        tagService.deleteTag(id);
        return Result.ok(Map.of("message", "已删除"));
    }

    @GetMapping("/configs")
    @Operation(summary = "配置管理列表")
    public Result<List<AppConfig>> configList(@RequestParam(required = false) String configType) {
        if (configType != null && !configType.isEmpty()) {
            return Result.ok(appConfigService.getConfigsByType(configType));
        }
        return Result.ok(appConfigService.getAllConfigsAdmin());
    }

    @PostMapping("/configs")
    @Operation(summary = "创建配置")
    public Result<AppConfig> createConfig(@RequestBody Map<String, Object> body) {
        String configType = (String) body.get("configType");
        String configKey = (String) body.get("configKey");
        String configValue = (String) body.get("configValue");
        String label = (String) body.get("label");
        String description = (String) body.get("description");
        Integer sortOrder = body.get("sortOrder") != null ? ((Number) body.get("sortOrder")).intValue() : 0;
        AppConfig config = appConfigService.createConfig(configType, configKey, configValue, label, description, sortOrder);
        return Result.ok(config);
    }

    @PutMapping("/configs/{id}")
    @Operation(summary = "更新配置")
    public Result<AppConfig> updateConfig(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String configKey = (String) body.get("configKey");
        String configValue = (String) body.get("configValue");
        String label = (String) body.get("label");
        String description = (String) body.get("description");
        Integer sortOrder = body.get("sortOrder") != null ? ((Number) body.get("sortOrder")).intValue() : null;
        Boolean enabled = (Boolean) body.get("enabled");
        AppConfig config = appConfigService.updateConfig(id, configKey, configValue, label, description, sortOrder, enabled);
        if (config == null) return Result.error("配置不存在");
        return Result.ok(config);
    }

    @DeleteMapping("/configs/{id}")
    @Operation(summary = "删除配置")
    public Result<Map<String, String>> deleteConfig(@PathVariable Long id) {
        appConfigService.deleteConfig(id);
        return Result.ok(Map.of("message", "已删除"));
    }
}