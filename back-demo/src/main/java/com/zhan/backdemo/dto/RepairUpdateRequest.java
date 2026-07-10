package com.zhan.backdemo.dto;

import lombok.Data;

@Data
public class RepairUpdateRequest {

    private Long id;
    private String title;
    private String description;
    private String address;
}
