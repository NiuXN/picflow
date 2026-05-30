package com.picflow.server.common;

import lombok.Data;

@Data
public class Result<T> {

    private int code;
    private String message;
    private T data;

    public static <T> Result<T> ok(T data) {
        Result<T> result = new Result<>();
        result.code = ErrorCode.SUCCESS.getCode();
        result.message = ErrorCode.SUCCESS.getMessage();
        result.data = data;
        return result;
    }

    public static <T> Result<T> ok() {
        return ok(null);
    }

    public static <T> Result<T> error(ErrorCode errorCode) {
        Result<T> result = new Result<>();
        result.code = errorCode.getCode();
        result.message = errorCode.getMessage();
        return result;
    }

    public static <T> Result<T> error(int code, String message) {
        Result<T> result = new Result<>();
        result.code = code;
        result.message = message;
        return result;
    }

    public static <T> Result<T> error(String message) {
        return error(ErrorCode.INTERNAL_SERVER_ERROR.getCode(), message);
    }
}