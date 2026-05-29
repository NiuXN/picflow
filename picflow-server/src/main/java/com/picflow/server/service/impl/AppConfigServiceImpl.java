package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.entity.AppConfig;
import com.picflow.server.mapper.AppConfigMapper;
import com.picflow.server.service.AppConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AppConfigServiceImpl extends ServiceImpl<AppConfigMapper, AppConfig> implements AppConfigService {

    @Override
    public List<AppConfig> getConfigsByType(String configType) {
        return this.list(new LambdaQueryWrapper<AppConfig>()
                .eq(AppConfig::getConfigType, configType)
                .orderByAsc(AppConfig::getSortOrder)
                .orderByAsc(AppConfig::getId));
    }

    @Override
    public List<AppConfig> getEnabledConfigsByType(String configType) {
        return this.list(new LambdaQueryWrapper<AppConfig>()
                .eq(AppConfig::getConfigType, configType)
                .eq(AppConfig::getEnabled, true)
                .orderByAsc(AppConfig::getSortOrder)
                .orderByAsc(AppConfig::getId));
    }

    @Override
    public List<AppConfig> getAllConfigsAdmin() {
        return this.list(new LambdaQueryWrapper<AppConfig>()
                .orderByAsc(AppConfig::getConfigType)
                .orderByAsc(AppConfig::getSortOrder)
                .orderByAsc(AppConfig::getId));
    }

    @Override
    public AppConfig createConfig(String configType, String configKey, String configValue,
                                  String label, String description, Integer sortOrder) {
        AppConfig config = new AppConfig();
        config.setConfigType(configType);
        config.setConfigKey(configKey);
        config.setConfigValue(configValue);
        config.setLabel(label);
        config.setDescription(description);
        config.setSortOrder(sortOrder != null ? sortOrder : 0);
        config.setEnabled(true);
        this.save(config);
        return config;
    }

    @Override
    public AppConfig updateConfig(Long id, String configKey, String configValue,
                                  String label, String description, Integer sortOrder, Boolean enabled) {
        AppConfig config = this.getById(id);
        if (config == null) return null;
        if (configKey != null) config.setConfigKey(configKey);
        if (configValue != null) config.setConfigValue(configValue);
        if (label != null) config.setLabel(label);
        if (description != null) config.setDescription(description);
        if (sortOrder != null) config.setSortOrder(sortOrder);
        if (enabled != null) config.setEnabled(enabled);
        this.updateById(config);
        return config;
    }

    @Override
    public void deleteConfig(Long id) {
        this.removeById(id);
    }
}
