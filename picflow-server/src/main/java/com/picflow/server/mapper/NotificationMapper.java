package com.picflow.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.picflow.server.entity.Notification;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {
}