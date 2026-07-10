package com.zhan.backdemo.common;

public final class Constants {

    private Constants() {
    }

    public static final String ROLE_RESIDENT = "resident";
    public static final String ROLE_WORKER = "worker";
    public static final String ROLE_ADMIN = "admin";

    public static final String USER_STATUS_ACTIVE = "active";
    public static final String USER_STATUS_PENDING = "pending";
    public static final String USER_STATUS_REJECTED = "rejected";

    public static final String REGISTER_TYPE_REGISTER = "register";
    public static final String REGISTER_TYPE_ADMIN_ADD = "admin_add";

    public static final String REPAIR_STATUS_PENDING = "pending";
    public static final String REPAIR_STATUS_ASSIGNED = "assigned";
    public static final String REPAIR_STATUS_PROCESSING = "processing";
    public static final String REPAIR_STATUS_COMPLETED = "completed";
    public static final String REPAIR_STATUS_CANCELLED = "cancelled";
}
