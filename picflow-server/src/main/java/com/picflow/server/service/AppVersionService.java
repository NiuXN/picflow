package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.AppVersion;

/**
 * App 版本服务接口
 */
public interface AppVersionService extends IService<AppVersion> {

    /** 获取指定平台和渠道的最新启用版本 */
    AppVersion getLatest(String platform, String channel);

    /** 判断用户是否在灰度范围内 */
    boolean isInGrayRelease(AppVersion version, Long userId);
}
