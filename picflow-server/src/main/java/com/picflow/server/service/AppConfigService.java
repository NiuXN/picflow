package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.AppConfig;

import java.util.List;

public interface AppConfigService extends IService<AppConfig> {

    List<AppConfig> getConfigsByType(String configType);

    List<AppConfig> getEnabledConfigsByType(String configType);

    List<AppConfig> getAllConfigsAdmin();

    AppConfig createConfig(String configType, String configKey, String configValue,
                           String label, String description, Integer sortOrder);

    AppConfig updateConfig(Long id, String configKey, String configValue,
                           String label, String description, Integer sortOrder, Boolean enabled);

    void deleteConfig(Long id);
}
