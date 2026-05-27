package com.picflow.server.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;

@Data
public class ArtworkRequest {

    @NotBlank(message = "标题不能为空")
    private String title;

    private String description;

    @NotBlank(message = "图片地址不能为空")
    private String imageUrl;

    private List<String> tags;

    private String frameType;
    private String aspectRatio;
    private String bgColor;
    private String watermarkText;
    private String filter;
}