package com.zhan.backdemo;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.zhan.backdemo.mapper")
public class BackDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackDemoApplication.class, args);
    }

}
