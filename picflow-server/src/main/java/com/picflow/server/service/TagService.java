package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.Tag;

import java.util.List;

public interface TagService extends IService<Tag> {

    List<Tag> getEnabledTags();

    List<Tag> getAllTagsAdmin();

    Tag createTag(String name, String description, Integer sortOrder);

    Tag updateTag(Long id, String name, String description, Integer sortOrder, Boolean enabled);

    void deleteTag(Long id);
}
