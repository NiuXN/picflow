package com.picflow.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.picflow.server.entity.User;

import java.util.Map;

public interface UserService extends IService<User> {

    User register(String username, String password, String nickname);

    User registerByPhone(String phone, String nickname);

    String login(String username, String password);

    User loginByPhone(String phone);

    User getCurrentUser();

    Map<String, Object> getUserStats(Long userId);
}