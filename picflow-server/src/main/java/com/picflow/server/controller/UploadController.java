package com.picflow.server.controller;

import com.picflow.server.annotation.RateLimit;
import com.picflow.server.common.BusinessException;
import com.picflow.server.common.Result;

/** 文件上传接口：图片上传 + 安全校验 + 缩略图生成 */
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import net.coobird.thumbnailator.Thumbnails;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/upload")
@Tag(name = "文件上传", description = "图片上传")
public class UploadController {

    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of("image/jpeg", "image/png", "image/webp");
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(".jpg", ".jpeg", ".png", ".webp");

    @Value("${picflow.upload.path:./uploads}")
    private String uploadPath;

    @Value("${picflow.upload.max-size:10MB}")
    private String maxSizeConfig;

    @RateLimit(capacity = 10, refillTokens = 10, refillMinutes = 1)
    @PostMapping("/image")
    @Operation(summary = "上传图片")
    public Result<Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return Result.error("文件为空");
        }

        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
            throw new BusinessException("不支持的文件类型，仅允许 jpg/png/webp");
        }

        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();
            if (!ALLOWED_EXTENSIONS.contains(ext)) {
                throw new BusinessException("不支持的文件类型，仅允许 jpg/png/webp");
            }
        } else {
            throw new BusinessException("无法识别文件扩展名");
        }

        long maxSizeBytes = parseMaxSize(maxSizeConfig);
        if (file.getSize() > maxSizeBytes) {
            throw new BusinessException("文件大小不能超过 " + maxSizeConfig);
        }

        BufferedImage image = ImageIO.read(file.getInputStream());
        if (image == null) {
            throw new BusinessException("无法解析图片文件");
        }
        if (image.getWidth() > 4096 || image.getHeight() > 4096) {
            throw new BusinessException("图片尺寸不能超过 4096×4096 像素");
        }

        Path dir = Paths.get(uploadPath);
        if (!Files.exists(dir)) {
            Files.createDirectories(dir);
        }

        String newFileName = UUID.randomUUID().toString() + ext;
        Path targetPath = dir.resolve(newFileName);
        file.transferTo(targetPath.toFile());

        String thumbFileName = "thumb_" + newFileName;
        Path thumbPath = dir.resolve(thumbFileName);
        Thumbnails.of(targetPath.toFile())
                .width(300)
                .keepAspectRatio(true)
                .toFile(thumbPath.toFile());

        String url = "/uploads/" + newFileName;
        String thumbnailUrl = "/uploads/" + thumbFileName;
        return Result.ok(Map.of("url", url, "thumbnailUrl", thumbnailUrl));
    }

    private long parseMaxSize(String config) {
        if (config == null || config.isEmpty()) {
            return 10 * 1024 * 1024;
        }
        config = config.trim().toUpperCase();
        long multiplier = 1;
        if (config.endsWith("MB")) {
            multiplier = 1024 * 1024;
            config = config.substring(0, config.length() - 2).trim();
        } else if (config.endsWith("KB")) {
            multiplier = 1024;
            config = config.substring(0, config.length() - 2).trim();
        } else if (config.endsWith("GB")) {
            multiplier = 1024 * 1024 * 1024;
            config = config.substring(0, config.length() - 2).trim();
        } else if (config.endsWith("B")) {
            config = config.substring(0, config.length() - 1).trim();
        }
        try {
            return (long) (Double.parseDouble(config) * multiplier);
        } catch (NumberFormatException e) {
            return 10 * 1024 * 1024;
        }
    }
}