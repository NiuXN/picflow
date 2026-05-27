package com.picflow.server.common;

import lombok.Data;
import java.util.List;

@Data
public class PageResult<T> {

    private long total;
    private int page;
    private int size;
    private int totalPages;
    private List<T> items;

    public static <T> PageResult<T> of(long total, int page, int size, List<T> items) {
        PageResult<T> result = new PageResult<>();
        result.total = total;
        result.page = page;
        result.size = size;
        result.totalPages = (int) Math.ceil((double) total / size);
        result.items = items;
        return result;
    }
}