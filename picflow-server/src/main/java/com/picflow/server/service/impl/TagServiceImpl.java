package com.picflow.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.picflow.server.entity.Tag;
import com.picflow.server.mapper.TagMapper;
import com.picflow.server.service.TagService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TagServiceImpl extends ServiceImpl<TagMapper, Tag> implements TagService {

    @Override
    public List<Tag> getEnabledTags() {
        return this.list(new LambdaQueryWrapper<Tag>()
                .eq(Tag::getEnabled, true)
                .orderByAsc(Tag::getSortOrder)
                .orderByAsc(Tag::getId));
    }

    @Override
    public List<Tag> getAllTagsAdmin() {
        return this.list(new LambdaQueryWrapper<Tag>()
                .orderByAsc(Tag::getSortOrder)
                .orderByAsc(Tag::getId));
    }

    @Override
    public Tag createTag(String name, String description, Integer sortOrder) {
        Tag tag = new Tag();
        tag.setName(name);
        tag.setDescription(description);
        tag.setSortOrder(sortOrder != null ? sortOrder : 0);
        tag.setEnabled(true);
        this.save(tag);
        return tag;
    }

    @Override
    public Tag updateTag(Long id, String name, String description, Integer sortOrder, Boolean enabled) {
        Tag tag = this.getById(id);
        if (tag == null) return null;
        if (name != null) tag.setName(name);
        if (description != null) tag.setDescription(description);
        if (sortOrder != null) tag.setSortOrder(sortOrder);
        if (enabled != null) tag.setEnabled(enabled);
        this.updateById(tag);
        return tag;
    }

    @Override
    public void deleteTag(Long id) {
        this.removeById(id);
    }
}
