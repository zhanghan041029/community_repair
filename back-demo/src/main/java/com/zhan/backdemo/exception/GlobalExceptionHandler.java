package com.zhan.backdemo.exception;

import com.zhan.backdemo.common.Result;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public Result<Object> handleBusinessException(BusinessException ex) {
        return Result.fail(ex.getMessage(), ex.getData());
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    public Result<Object> handleValidationException(Exception ex) {
        String message = "参数校验失败";
        if (ex instanceof MethodArgumentNotValidException validException) {
            if (validException.getBindingResult().getFieldError() != null) {
                message = validException.getBindingResult().getFieldError().getDefaultMessage();
            }
        } else if (ex instanceof BindException bindException) {
            if (bindException.getBindingResult().getFieldError() != null) {
                message = bindException.getBindingResult().getFieldError().getDefaultMessage();
            }
        }
        return Result.fail(message);
    }

    @ExceptionHandler(Exception.class)
    public Result<Object> handleException(Exception ex) {
        ex.printStackTrace();
        return Result.fail("系统异常：" + ex.getMessage());
    }
}
