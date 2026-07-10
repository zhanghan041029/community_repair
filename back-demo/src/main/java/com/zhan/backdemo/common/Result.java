package com.zhan.backdemo.common;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {

    private Integer code;
    private String msg;
    private T data;

    public static <T> Result<T> success(T data) {
        return new Result<>(1, "success", data);
    }

    public static <T> Result<T> success(String msg, T data) {
        return new Result<>(1, msg, data);
    }

    public static <T> Result<T> success(String msg) {
        return new Result<>(1, msg, null);
    }

    public static <T> Result<T> fail(String msg) {
        return new Result<>(0, msg, null);
    }

    public static <T> Result<T> fail(String msg, T data) {
        return new Result<>(0, msg, data);
    }
}
