package com.picflow.server.controller;

import com.picflow.server.common.Result;
import com.picflow.server.entity.AppVersion;
import com.picflow.server.service.AppVersionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * App 版本检查接口——无需认证，供 Flutter 启动时调用
 * 支持：渠道选择、灰度判断、版本区间匹配
 */
@RestController
@RequestMapping("/app")
@RequiredArgsConstructor
@Tag(name = "App 版本检查")
public class AppVersionController {

    private final AppVersionService appVersionService;

    @GetMapping("/version")
    @Operation(summary = "获取最新版本信息")
    public Result<Map<String, Object>> getLatest(
            @RequestParam(defaultValue = "all") String platform,
            @RequestParam(defaultValue = "stable") String channel,
            @RequestParam(required = false) Long userId,
            @RequestParam(defaultValue = "0") int currentVersionCode) {

        AppVersion version = appVersionService.getLatest(platform, channel);
        if (version == null) {
            return Result.ok(Map.of("latest", false));
        }

        boolean inGray = true;
        if (userId != null) {
            inGray = appVersionService.isInGrayRelease(version, userId);
        }

        String updateType = "none"; // none/optional/force
        if (version.getVersionCode() > currentVersionCode && inGray) {
            if (version.getForceUpdate() ||
                (version.getMinVersionCode() != null && currentVersionCode < version.getMinVersionCode())) {
                updateType = "force";
            } else if (version.getMaxVersionCode() == null || currentVersionCode <= version.getMaxVersionCode()) {
                updateType = "optional";
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("latest", !"none".equals(updateType));
        result.put("updateType", updateType);
        result.put("versionName", version.getVersionName());
        result.put("versionCode", version.getVersionCode());
        result.put("description", version.getDescription());
        result.put("releaseNotes", version.getReleaseNotes());
        result.put("downloadUrl", version.getDownloadUrl());
        result.put("hotfixUrl", version.getHotfixUrl());
        result.put("forceUpdate", version.getForceUpdate());
        return Result.ok(result);
    }
}
