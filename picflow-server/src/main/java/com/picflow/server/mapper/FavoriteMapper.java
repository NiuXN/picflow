package com.picflow.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.picflow.server.entity.Favorite;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface FavoriteMapper extends BaseMapper<Favorite> {
}