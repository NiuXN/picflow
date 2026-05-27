package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.entity.AppVersion;
import com.picflow.server.mapper.AppVersionMapper;
import com.picflow.server.service.AppVersionService;
import org.springframework.stereotype.Service;

/**
 * App 版本服务实现
 * 支持渠道筛选、灰度判断、版本区间匹配
 */
@Service
public class AppVersionServiceImpl extends ServiceImpl<AppVersionMapper, AppVersion> implements AppVersionService {

    @Override
    public AppVersion getLatest(String platform, String channel) {
        return this.getOne(new LambdaQueryWrapper<AppVersion>()
                .eq(AppVersion::getEnabled, true)
                .and(w -> w.eq(AppVersion::getPlatform, "all").or().eq(AppVersion::getPlatform, platform))
                .eq(AppVersion::getChannel, channel)
                .orderByDesc(AppVersion::getVersionCode)
                .last("LIMIT 1"));
    }

    @Override
    public boolean isInGrayRelease(AppVersion version, Long userId) {
        if (version == null) return false;
        int percent = version.getGrayPercent() != null ? version.getGrayPercent() : 100;
        if (percent >= 100) return true;  // 全量发布
        if (percent <= 0) return false;   // 完全关闭
        // 基于 userId 的 hash 做灰度判断，保证同一用户始终在同一个灰度组
        int bucket = Math.abs(userId.hashCode()) % 100;
        return bucket < percent;
    }
}
