package com.picflow.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.picflow.server.entity.Artwork;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ArtworkMapper extends BaseMapper<Artwork> {
}