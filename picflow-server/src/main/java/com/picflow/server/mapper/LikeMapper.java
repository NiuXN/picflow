package com.picflow.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.picflow.server.entity.Like;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface LikeMapper extends BaseMapper<Like> {
}