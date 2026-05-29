package com.picflow.server.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.picflow.server.common.Result;
import com.picflow.server.dto.LoginRequest;
import com.picflow.server.dto.RegisterRequest;
import com.picflow.server.dto.UpdateProfileRequest;
import com.picflow.server.entity.User;
import com.picflow.server.security.JwtTokenProvider;
import com.picflow.server.service.UserService;
import lombok.extern.slf4j.Slf4j;

/** 用户认证接口：注册/登录/个人资料 */
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "认证接口", description = "用户注册、登录")
public class AuthController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;

    private static final long CODE_EXPIRE_SECONDS = 300;
    private final Map<String, CodeEntry> codeStore = new ConcurrentHashMap<>();
    private final Random random = new Random();

    private record CodeEntry(String code, long expireAt) {
        boolean isExpired() {
            return System.currentTimeMillis() > expireAt;
        }
    }

    @PostMapping("/send-code")
    @Operation(summary = "发送短信验证码")
    public Result<Map<String, String>> sendCode(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        if (phone == null || !phone.matches("\\d{11}")) {
            return Result.error("请输入正确的手机号");
        }
        String code = String.format("%06d", random.nextInt(1000000));
        long expireAt = System.currentTimeMillis() + CODE_EXPIRE_SECONDS * 1000;
        codeStore.put(phone, new CodeEntry(code, expireAt));
        log.info("[SMS] 验证码发送到 {}: {} (有效期{}秒)", phone, code, CODE_EXPIRE_SECONDS);
        return Result.ok(Map.of("message", "验证码已发送"));
    }

    @PostMapping("/phone-login")
    @Operation(summary = "手机号验证码登录")
    public Result<Map<String, Object>> phoneLogin(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String code = body.get("code");
        String nickname = body.get("nickname");

        if (phone == null || code == null) {
            return Result.error("手机号和验证码不能为空");
        }
        CodeEntry entry = codeStore.get(phone);
        if (entry == null || !entry.code().equals(code)) {
            return Result.error("验证码错误或已过期");
        }
        if (entry.isExpired()) {
            codeStore.remove(phone);
            return Result.error("验证码已过期，请重新获取");
        }
        codeStore.remove(phone);

        User user = userService.loginByPhone(phone);
        if (user != null && "banned".equals(user.getStatus())) {
            return Result.error("账号已被封禁");
        }
        if (user == null) {
            user = userService.registerByPhone(phone, nickname);
        }
        String token = jwtTokenProvider.generateToken(user.getId(), user.getUsername(), user.getRole());
        return Result.ok(Map.of("token", token, "user", user));
    }

    @PostMapping("/register")
    @Operation(summary = "用户注册")
    public Result<Map<String, Object>> register(@Valid @RequestBody RegisterRequest request) {
        User user = userService.register(request.getUsername(), request.getPassword(), request.getNickname());
        String token = jwtTokenProvider.generateToken(user.getId(), user.getUsername(), user.getRole());
        return Result.ok(Map.of("token", token, "user", user));
    }

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public Result<Map<String, Object>> login(@Valid @RequestBody LoginRequest request) {
        User user = userService.getOne(new LambdaQueryWrapper<User>().eq(User::getUsername, request.getUsername()));
        if (user != null && "banned".equals(user.getStatus())) {
            return Result.error("账号已被封禁");
        }
        String token = userService.login(request.getUsername(), request.getPassword());
        return Result.ok(Map.of("token", token, "user", user));
    }

    @GetMapping("/profile")
    @Operation(summary = "获取当前用户资料")
    public Result<User> profile(@AuthenticationPrincipal Long userId) {
        User user = userService.getById(userId);
        return Result.ok(user);
    }

    @GetMapping("/stats")
    @Operation(summary = "获取当前用户统计数据")
    public Result<Map<String, Object>> stats(@AuthenticationPrincipal Long userId) {
        Map<String, Object> stats = userService.getUserStats(userId);
        return Result.ok(stats);
    }

    @PutMapping("/profile")
    @Operation(summary = "修改当前用户资料")
    public Result<User> updateProfile(@AuthenticationPrincipal Long userId,
                                       @Valid @RequestBody UpdateProfileRequest request) {
        User user = userService.getById(userId);
        if (user == null) {
            return Result.error("用户不存在");
        }
        if (request.getNickname() != null) {
            user.setNickname(request.getNickname());
        }
        if (request.getBio() != null) {
            user.setBio(request.getBio());
        }
        userService.updateById(user);
        return Result.ok(user);
    }
}