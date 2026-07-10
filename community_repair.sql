/*
 Navicat MySQL Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80012
 Source Host           : localhost:3306
 Source Schema         : community_repair

 Target Server Type    : MySQL
 Target Server Version : 80012
 File Encoding         : 65001

 Date: 25/06/2026 21:14:30
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for announcement
-- ----------------------------
DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告内容',
  `publisher_id` bigint(20) NOT NULL COMMENT '发布者ID',
  `publisher_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发布者名称',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of announcement
-- ----------------------------
INSERT INTO `announcement` VALUES (1, '社区维修服务上线通知', '各位居民和维修工朋友们：\n\n社区维修服务管理平台已正式上线！\n\n居民可以通过平台提交维修工单，查看维修进度，评价维修服务。\n维修工可以接收派单，处理维修任务。\n\n如有任何问题，请联系物业服务中心。\n\n感谢大家的支持！', 41, '系统管理员', '2026-06-20 09:00:00');

-- ----------------------------
-- Table structure for evaluation
-- ----------------------------
DROP TABLE IF EXISTS `evaluation`;
CREATE TABLE `evaluation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '评价ID，主键自增',
  `repair_id` bigint(20) NOT NULL COMMENT '工单ID，关联repair_order.id',
  `user_id` bigint(20) NOT NULL COMMENT '评价居民ID，关联sys_user.id',
  `score` int(11) NOT NULL COMMENT '评分：1-5分',
  `comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '评价内容',
  `reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '维修工回复',
  `reply_time` datetime(0) NULL DEFAULT NULL COMMENT '回复时间',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_repair_id`(`repair_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `fk_evaluation_repair` FOREIGN KEY (`repair_id`) REFERENCES `repair_order` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_evaluation_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '工单评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of evaluation
-- ----------------------------
INSERT INTO `evaluation` VALUES (1, 1, 1, 5, '师傅来得很快，技术很好，修完还清理了现场', '感谢', '2026-06-24 20:59:00', '2026-05-21 10:00:00');
INSERT INTO `evaluation` VALUES (2, 2, 2, 4, '修好了空调，但来得稍微有点晚，整体满意', '感谢好评', '2026-06-24 21:10:42', '2026-05-22 09:00:00');
INSERT INTO `evaluation` VALUES (3, 3, 3, 5, '马桶疏通很专业，还教了我日常保养方法', NULL, NULL, '2026-05-23 14:00:00');
INSERT INTO `evaluation` VALUES (4, 4, 4, 3, '灯修好了，但服务态度一般', NULL, NULL, '2026-05-24 10:30:00');
INSERT INTO `evaluation` VALUES (5, 5, 5, 5, '推拉门修得很好，现在很顺畅，点赞', NULL, NULL, '2026-05-25 11:00:00');
INSERT INTO `evaluation` VALUES (6, 6, 6, 4, '下水道疏通了，味道也没有了，还不错', NULL, NULL, '2026-05-26 09:00:00');
INSERT INTO `evaluation` VALUES (7, 7, 7, 5, '热水器修好了，师傅很耐心讲解了使用注意事项', NULL, NULL, '2026-05-27 15:00:00');
INSERT INTO `evaluation` VALUES (8, 8, 8, 4, '墙面渗水修好了，暂时没发现复发', NULL, NULL, '2026-05-28 10:00:00');
INSERT INTO `evaluation` VALUES (9, 9, 9, 5, '电路问题排查得很仔细，现在用电正常了', NULL, NULL, '2026-05-29 14:00:00');
INSERT INTO `evaluation` VALUES (10, 10, 10, 4, '马桶修好了，就是配件价格稍微有点贵', NULL, NULL, '2026-05-30 09:30:00');
INSERT INTO `evaluation` VALUES (11, 11, 11, 5, '洗衣机排水修好了，师傅态度好', NULL, NULL, '2026-05-31 16:00:00');
INSERT INTO `evaluation` VALUES (12, 12, 12, 3, '冰箱修了三天又坏了，有点失望', NULL, NULL, '2026-06-01 10:00:00');
INSERT INTO `evaluation` VALUES (13, 13, 13, 5, '门锁换好了，很专业，进出正常', NULL, NULL, '2026-06-02 11:00:00');
INSERT INTO `evaluation` VALUES (14, 14, 14, 4, '窗户玻璃换好了，希望能用久一点', NULL, NULL, '2026-06-03 09:00:00');
INSERT INTO `evaluation` VALUES (15, 15, 15, 5, '燃气灶修好了，打火很快，很满意', NULL, NULL, '2026-06-04 14:00:00');
INSERT INTO `evaluation` VALUES (16, 16, 1, 5, '师傅很专业，小问题很快就解决了', NULL, NULL, '2026-06-01 08:00:00');
INSERT INTO `evaluation` VALUES (17, 17, 2, 4, '维修速度很快，价格合理', NULL, NULL, '2026-06-02 09:00:00');
INSERT INTO `evaluation` VALUES (18, 18, 3, 5, '服务态度好，技术过硬，推荐', NULL, NULL, '2026-06-03 10:00:00');
INSERT INTO `evaluation` VALUES (19, 19, 4, 3, '修好了但等了很久才来', NULL, NULL, '2026-06-04 11:00:00');
INSERT INTO `evaluation` VALUES (20, 20, 5, 5, '非常满意，下次还找这个师傅', NULL, NULL, '2026-06-05 14:00:00');
INSERT INTO `evaluation` VALUES (21, 54, 9, 4, '速度快，效果很好', '好', '2026-06-24 21:05:59', '2026-06-11 20:16:00');
INSERT INTO `evaluation` VALUES (22, 64, 19, 5, '非常满意，推荐', NULL, NULL, '2026-06-14 20:16:00');
INSERT INTO `evaluation` VALUES (24, 65, 20, 4, '师傅很耐心，解释清楚', NULL, NULL, '2026-06-09 20:16:01');
INSERT INTO `evaluation` VALUES (25, 45, 20, 4, '效率高，态度亲切', NULL, NULL, '2026-06-09 20:16:01');
INSERT INTO `evaluation` VALUES (27, 56, 11, 4, '很满意，下次还找这位师傅', NULL, NULL, '2026-06-10 20:16:01');
INSERT INTO `evaluation` VALUES (28, 46, 1, 4, '速度很快，服务很好', NULL, NULL, '2026-06-08 20:16:01');
INSERT INTO `evaluation` VALUES (30, 57, 12, 5, '维修很到位，没有后顾之忧', NULL, NULL, '2026-06-08 20:16:01');
INSERT INTO `evaluation` VALUES (31, 67, 2, 4, '非常满意，服务热情', NULL, NULL, '2026-06-10 20:16:01');
INSERT INTO `evaluation` VALUES (33, 58, 13, 5, '认真负责，技术过硬', NULL, NULL, '2026-06-09 20:16:01');
INSERT INTO `evaluation` VALUES (34, 68, 3, 4, '服务周到，非常满意', NULL, NULL, '2026-06-10 20:16:01');
INSERT INTO `evaluation` VALUES (36, 69, 4, 4, '非常满意，维修效果好', NULL, NULL, '2026-06-06 20:16:01');
INSERT INTO `evaluation` VALUES (37, 59, 14, 3, '非常满意，维修效果好', NULL, NULL, '2026-06-11 20:16:01');
INSERT INTO `evaluation` VALUES (39, 60, 15, 3, '很满意，推荐给邻居', NULL, NULL, '2026-06-14 20:16:01');
INSERT INTO `evaluation` VALUES (40, 50, 5, 5, '维修非常棒，效率高', NULL, NULL, '2026-06-09 20:16:01');
INSERT INTO `evaluation` VALUES (42, 61, 16, 5, '非常满意，下次还找', NULL, NULL, '2026-06-09 20:16:01');
INSERT INTO `evaluation` VALUES (43, 71, 6, 4, '技术好，沟通顺畅', NULL, NULL, '2026-06-08 20:16:01');
INSERT INTO `evaluation` VALUES (45, 62, 17, 4, '技术过硬，非常满意', NULL, NULL, '2026-06-13 20:16:01');
INSERT INTO `evaluation` VALUES (46, 52, 7, 4, '维修很及时，服务周到', NULL, NULL, '2026-06-10 20:16:01');
INSERT INTO `evaluation` VALUES (48, 53, 8, 3, '问题彻底解决，好评', NULL, NULL, '2026-06-06 20:16:01');
INSERT INTO `evaluation` VALUES (49, 63, 18, 3, '问题彻底解决，好评', NULL, NULL, '2026-06-11 20:16:01');
INSERT INTO `evaluation` VALUES (51, 66, 1, 5, '好', NULL, NULL, '2026-06-16 22:49:26');
INSERT INTO `evaluation` VALUES (52, 74, 1, 5, '非常nice', '感谢', '2026-06-24 21:04:58', '2026-06-17 20:22:45');
INSERT INTO `evaluation` VALUES (53, 73, 1, 5, '很好', NULL, NULL, '2026-06-17 22:37:33');

-- ----------------------------
-- Table structure for repair_order
-- ----------------------------
DROP TABLE IF EXISTS `repair_order`;
CREATE TABLE `repair_order`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '工单ID，主键自增',
  `user_id` bigint(20) NOT NULL COMMENT '报修居民ID，关联sys_user.id',
  `worker_id` bigint(20) NULL DEFAULT NULL COMMENT '指派的维修工ID，关联sys_user.id，未派单时为NULL',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '报修标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '故障描述',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '维修地址',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '联系电话',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'pending' COMMENT '工单状态：pending/assigned/processing/completed/cancelled',
  `priority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'normal' COMMENT '优先级:normal/urgent',
  `result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '维修结果（状态为completed时填写）',
  `image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '现场照片路径',
  `assign_time` datetime(0) NULL DEFAULT NULL COMMENT '派单时间',
  `finish_time` datetime(0) NULL DEFAULT NULL COMMENT '完成时间',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_worker_id`(`worker_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE,
  CONSTRAINT `fk_repair_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_repair_worker` FOREIGN KEY (`worker_id`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 77 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '维修工单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of repair_order
-- ----------------------------
INSERT INTO `repair_order` VALUES (1, 1, 21, '厨房水龙头漏水', '厨房水龙头关不紧，一直滴水，需要更换阀芯', '1栋101室', '13800000001', 'completed', 'normal', '更换水龙头阀芯，已恢复正常使用', NULL, '2026-05-20 09:00:00', '2026-05-20 14:30:00', '2026-05-20 08:30:00', '2026-06-23 20:57:52');
INSERT INTO `repair_order` VALUES (2, 2, 22, '卧室空调不制冷', '空调开启后吹自然风，不制冷，可能是缺氟', '1栋202室', '13800000002', 'completed', 'normal', '检查发现缺氟，补充制冷剂后恢复正常', NULL, '2026-05-21 10:00:00', '2026-05-21 16:00:00', '2026-05-21 09:00:00', '2026-06-23 20:57:55');
INSERT INTO `repair_order` VALUES (3, 3, 23, '卫生间马桶堵塞', '马桶冲水不畅，下水很慢', '2栋305室', '13800000003', 'completed', 'normal', '使用疏通器疏通，取出堵塞物，恢复正常', NULL, '2026-05-22 09:30:00', '2026-05-22 11:00:00', '2026-05-22 08:00:00', '2026-06-23 20:57:59');
INSERT INTO `repair_order` VALUES (4, 4, 24, '客厅灯管不亮', '客厅吸顶灯不亮，更换灯管后仍不亮', '2栋408室', '13800000004', 'completed', 'normal', '检查发现镇流器损坏，更换后恢复正常', NULL, '2026-05-23 14:00:00', '2026-05-23 15:30:00', '2026-05-23 13:00:00', '2026-06-23 20:58:02');
INSERT INTO `repair_order` VALUES (5, 5, 25, '阳台推拉门卡顿', '阳台推拉门推拉困难，轨道有异物', '3栋1102室', '13800000005', 'completed', 'normal', '清理轨道，调整滑轮，推拉顺畅', NULL, '2026-05-24 08:00:00', '2026-05-24 10:00:00', '2026-05-24 07:30:00', '2026-06-23 20:58:05');
INSERT INTO `repair_order` VALUES (6, 6, 26, '厨房下水道堵塞', '厨房水池排水极慢，有异味', '3栋1205室', '13800000006', 'processing', 'normal', '正在疏通中，预计今天完成', NULL, '2026-06-01 09:00:00', NULL, '2026-06-01 08:00:00', '2026-06-23 20:58:10');
INSERT INTO `repair_order` VALUES (7, 7, 27, '热水器不出热水', '热水器点火正常但不出热水，水温冰凉', '4栋203室', '13800000007', 'processing', 'normal', '检查中，初步判断是加热管问题', NULL, '2026-06-01 10:30:00', NULL, '2026-06-01 09:30:00', '2026-06-23 20:58:13');
INSERT INTO `repair_order` VALUES (8, 8, 28, '墙面渗水发霉', '卧室墙面有渗水痕迹，墙皮脱落', '4栋304室', '13800000008', 'processing', 'normal', '已排查漏水点，正在维修', NULL, '2026-06-02 09:00:00', NULL, '2026-06-02 08:00:00', '2026-06-23 20:58:15');
INSERT INTO `repair_order` VALUES (9, 9, 29, '电路跳闸频繁', '家里总闸频繁跳闸，无法正常用电', '5栋101室', '13800000009', 'processing', 'normal', '检测线路中，排查短路点', NULL, '2026-06-02 14:00:00', NULL, '2026-06-02 13:00:00', '2026-06-23 20:58:21');
INSERT INTO `repair_order` VALUES (10, 10, 30, '马桶水箱漏水', '马桶水箱一直流水，声音很大', '5栋202室', '13800000010', 'processing', 'normal', '更换进水阀中', NULL, '2026-06-03 09:00:00', NULL, '2026-06-03 08:00:00', '2026-06-23 20:58:26');
INSERT INTO `repair_order` VALUES (11, 11, 21, '洗衣机不排水', '洗衣机洗涤正常，但排水不出去', '6栋301室', '13800000011', 'assigned', 'normal', NULL, NULL, '2026-06-03 10:00:00', NULL, '2026-06-03 09:00:00', '2026-06-23 20:58:29');
INSERT INTO `repair_order` VALUES (12, 12, 22, '冰箱不制冷', '冰箱压缩机工作但冷藏室不冷', '6栋402室', '13800000012', 'assigned', 'normal', NULL, NULL, '2026-06-03 11:00:00', NULL, '2026-06-03 09:30:00', '2026-06-23 20:58:31');
INSERT INTO `repair_order` VALUES (13, 13, 23, '门锁损坏', '大门锁芯转动不灵活，钥匙插拔困难', '7栋503室', '13800000013', 'assigned', 'normal', NULL, NULL, '2026-06-03 09:00:00', NULL, '2026-06-02 16:00:00', '2026-06-23 20:58:36');
INSERT INTO `repair_order` VALUES (14, 14, 24, '窗户玻璃裂纹', '卧室窗户玻璃有裂纹，存在安全隐患', '7栋604室', '13800000014', 'assigned', 'normal', NULL, NULL, '2026-06-03 14:00:00', NULL, '2026-06-03 08:00:00', '2026-06-23 20:58:39');
INSERT INTO `repair_order` VALUES (15, 15, 25, '燃气灶打不着火', '燃气灶点火没反应，电池已更换', '8栋705室', '13800000015', 'assigned', 'normal', NULL, NULL, '2026-06-03 15:00:00', NULL, '2026-06-03 10:00:00', '2026-06-23 20:58:41');
INSERT INTO `repair_order` VALUES (16, 12, NULL, '排气扇异响', '卫生间排气扇运行时噪音很大', '8栋806室', '13800000016', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-03 08:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (17, 13, NULL, '水压过低', '家中水压很低，水流很小', '9栋907室', '13800000017', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-03 08:30:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (18, 14, NULL, '地漏反味', '卫生间地漏返臭，异味严重', '9栋1008室', '13800000018', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-03 09:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (19, 15, NULL, '电热水器漏水', '电热水器底部有漏水现象', '10栋1109室', '13800000019', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-03 10:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (20, 16, NULL, '瓷砖空鼓脱落', '厨房墙面瓷砖有几块空鼓脱落', '10栋1210室', '13800000020', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-03 11:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (21, 17, NULL, '临时取消维修', '已经自行修好了，不需要上门了', '1栋101室', '13800000001', 'cancelled', 'normal', NULL, NULL, NULL, NULL, '2026-05-25 09:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (22, 18, NULL, '重复提交', '误操作重复提交，请取消', '2栋305室', '13800000003', 'cancelled', 'normal', NULL, NULL, NULL, NULL, '2026-05-26 10:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (23, 19, NULL, '改约时间', '临时有事，重新预约', '3栋1102室', '13800000005', 'cancelled', 'normal', NULL, NULL, NULL, NULL, '2026-05-27 11:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (24, 20, NULL, '故障自行恢复', '重启后发现好了，不用修了', '4栋203室', '13800000007', 'cancelled', 'normal', NULL, NULL, NULL, NULL, '2026-05-28 14:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (25, 21, NULL, '已联系其他维修', '已经找了外面的师傅修好了', '5栋101室', '13800000009', 'cancelled', 'normal', NULL, NULL, NULL, NULL, '2026-05-29 09:00:00', '2026-06-04 16:23:11');
INSERT INTO `repair_order` VALUES (26, 1, NULL, '厨房下水道堵塞', '洗菜池下水极慢，有异味', '1栋101室', '13800000001', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (27, 2, NULL, '卫生间排气扇异响', '开启后噪音很大，怀疑轴承损坏', '1栋202室', '13800000002', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (28, 3, NULL, '阳台地漏反水', '洗衣机排水时地漏往外冒水', '2栋305室', '13800000003', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-12 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (29, 4, NULL, '卧室窗户关不严', '窗户把手松动，关不紧漏风', '2栋408室', '13800000004', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (30, 5, NULL, '客厅插座没电', '墙壁插座无电，其他正常', '3栋1102室', '13800000005', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (31, 6, NULL, '热水器漏水', '加热时底部有滴水现象', '3栋1205室', '13800000006', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (32, 7, 28, '门禁对讲故障', '楼下按门铃无反应', '4栋203室', '13800000007', 'assigned', 'normal', NULL, NULL, '2026-06-16 19:52:01', NULL, '2026-06-15 23:24:23', '2026-06-16 19:52:00');
INSERT INTO `repair_order` VALUES (33, 8, NULL, '墙面瓷砖脱落', '厨房墙面几块瓷砖空鼓即将脱落', '4栋304室', '13800000008', 'pending', 'normal', NULL, NULL, NULL, NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (34, 9, 21, '冰箱冷藏室结冰', '冷藏室后背结厚冰，温度过低', '5栋101室', '13800000009', 'assigned', 'normal', NULL, NULL, '2026-06-14 23:24:23', NULL, '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (35, 10, 22, '洗衣机不脱水', '洗涤正常，但排水后不脱水', '5栋202室', '13800000010', 'assigned', 'normal', NULL, NULL, '2026-06-14 23:24:23', NULL, '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (36, 11, 23, '燃气灶点火困难', '打火多次才能点燃，有气味', '6栋301室', '13800000011', 'assigned', 'normal', NULL, NULL, '2026-06-15 17:24:23', NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (37, 12, 24, '马桶水箱进水不停', '水箱一直流水，声音明显', '6栋402室', '13800000012', 'assigned', 'normal', NULL, NULL, '2026-06-15 11:24:23', NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (38, 13, 25, '电路跳闸', '偶尔跳闸，合闸后正常', '7栋503室', '13800000013', 'assigned', 'normal', NULL, NULL, '2026-06-15 15:24:23', NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (39, 14, 26, '洗手盆下水管漏水', '软管接口处渗水', '7栋604室', '13800000014', 'processing', 'normal', '已检查，准备更换软管', NULL, '2026-06-14 23:24:23', NULL, '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (40, 15, 27, '浴霸不制热', '照明正常，但取暖灯不热', '8栋705室', '13800000015', 'processing', 'normal', '检测线路中', NULL, '2026-06-13 23:24:23', NULL, '2026-06-12 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (41, 16, 28, '墙面渗水', '窗边墙皮受潮脱落', '8栋806室', '13800000016', 'processing', 'normal', '查找漏水点', NULL, '2026-06-14 23:24:23', NULL, '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (42, 17, 29, '门锁损坏', '钥匙插拔困难，转动不灵', '9栋907室', '13800000017', 'processing', 'normal', '准备更换锁芯', NULL, '2026-06-14 23:24:23', NULL, '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (43, 18, 30, '窗帘轨道脱落', '轨道一端固定螺丝松动', '9栋1008室', '13800000018', 'processing', 'normal', '已修复', NULL, '2026-06-15 18:24:23', NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (44, 19, 21, '灯具闪烁', 'LED灯频闪，更换灯泡无效', '10栋1109室', '13800000019', 'processing', 'normal', '检查驱动电源', NULL, '2026-06-15 20:24:23', NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (45, 20, 22, '水龙头滴水', '更换阀芯后正常', '10栋1210室', '13800000020', 'completed', 'normal', '更换水龙头阀芯，已正常', NULL, '2026-06-10 23:24:23', '2026-06-11 23:24:23', '2026-06-08 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (46, 1, 23, '空调加氟', '补充制冷剂后制冷正常', '1栋101室', '13800000001', 'completed', 'normal', '加氟并检查管路', NULL, '2026-06-11 23:24:23', '2026-06-12 23:24:23', '2026-06-09 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (47, 2, 24, '马桶疏通', '取出异物，下水通畅', '1栋202室', '13800000002', 'completed', 'normal', '使用疏通器疏通', NULL, '2026-06-12 23:24:23', '2026-06-13 23:24:23', '2026-06-10 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (48, 3, 25, '电热水器更换镁棒', '清洗内胆并更换镁棒', '2栋305室', '13800000003', 'completed', 'normal', '已完成，加热效率提升', NULL, '2026-06-09 23:24:23', '2026-06-10 23:24:23', '2026-06-07 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (49, 4, 26, '窗户滑轮更换', '推拉顺畅', '2栋408室', '13800000004', 'completed', 'normal', '更换新滑轮', NULL, '2026-06-13 23:24:23', '2026-06-14 23:24:23', '2026-06-11 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (50, 5, 27, '开关面板更换', '更换后正常', '3栋1102室', '13800000005', 'completed', 'normal', '更换松脱开关', NULL, '2026-06-08 23:24:23', '2026-06-09 23:24:23', '2026-06-06 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (51, 6, 28, '地漏疏通', '清理毛发后排水正常', '3栋1205室', '13800000006', 'completed', 'normal', '疏通并消毒', NULL, '2026-06-12 23:24:23', '2026-06-13 23:24:23', '2026-06-10 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (52, 7, 29, '灯具安装', '安装新吸顶灯', '4栋203室', '13800000007', 'completed', 'normal', '安装牢固，亮度正常', NULL, '2026-06-11 23:24:23', '2026-06-12 23:24:23', '2026-06-09 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (53, 8, 30, '墙面修补', '填补裂缝并刷漆', '4栋304室', '13800000008', 'completed', 'normal', '修补后平整', NULL, '2026-06-10 23:24:23', '2026-06-11 23:24:23', '2026-06-08 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (54, 9, 21, '水压调节', '调整减压阀，水压正常', '5栋101室', '13800000009', 'completed', 'normal', '水压恢复', NULL, '2026-06-13 23:24:23', '2026-06-14 23:24:23', '2026-06-12 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (55, 10, 22, '油烟机清洗', '清洗滤网和内部油污', '5栋202室', '13800000010', 'completed', 'normal', '清洗后吸烟效果改善', NULL, '2026-06-09 23:24:23', '2026-06-10 23:24:23', '2026-06-07 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (56, 11, 23, '暖气片排气', '排出空气后暖气热了', '6栋301室', '13800000011', 'completed', 'normal', '完成排气', NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23', '2026-06-13 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (57, 12, 24, '厨房三角阀更换', '更换漏水三角阀', '6栋402室', '13800000012', 'completed', 'normal', '新阀无渗漏', NULL, '2026-06-11 23:24:23', '2026-06-12 23:24:23', '2026-06-09 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (58, 13, 25, '阳台推拉门维修', '调整轨道滑轮', '7栋503室', '13800000013', 'completed', 'normal', '推拉顺畅', NULL, '2026-06-10 23:24:23', '2026-06-11 23:24:23', '2026-06-08 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (59, 14, 26, '卫生间防水处理', '打胶密封', '7栋604室', '13800000014', 'completed', 'normal', '不再渗水', NULL, '2026-06-12 23:24:23', '2026-06-13 23:24:23', '2026-06-10 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (60, 15, 27, '插座增加', '新装两个五孔插座', '8栋705室', '13800000015', 'completed', 'normal', '安装位置合理，通电正常', NULL, '2026-06-07 23:24:23', '2026-06-08 23:24:23', '2026-06-05 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (61, 16, 28, '网络面板修复', '重新压线，网络恢复', '8栋806室', '13800000016', 'completed', 'normal', '网速正常', NULL, '2026-06-13 23:24:23', '2026-06-14 23:24:23', '2026-06-11 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (62, 17, 29, '可视对讲调试', '重新配对，恢复正常', '9栋907室', '13800000017', 'completed', 'normal', '通话清晰', NULL, '2026-06-11 23:24:23', '2026-06-12 23:24:23', '2026-06-09 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (63, 18, 30, '消防烟感更换', '更换电池并测试', '9栋1008室', '13800000018', 'completed', 'normal', '工作正常', NULL, '2026-06-10 23:24:23', '2026-06-11 23:24:23', '2026-06-08 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (64, 19, 21, '入户门铰链紧固', '上油并紧固螺丝', '10栋1109室', '13800000019', 'completed', 'normal', '开门顺畅无异响', NULL, '2026-06-09 23:24:23', '2026-06-10 23:24:23', '2026-06-07 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (65, 20, 22, '走廊感应灯维修', '更换感应器', '10栋1210室', '13800000020', 'completed', 'normal', '人来灯亮', NULL, '2026-06-12 23:24:23', '2026-06-13 23:24:23', '2026-06-10 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (66, 1, 23, '窗户密封条更换', '更换老化密封条', '1栋101室', '13800000001', 'completed', 'normal', '密封性提高', NULL, '2026-06-08 23:24:23', '2026-06-09 23:24:23', '2026-06-06 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (67, 2, 24, '水管保温棉包裹', '防止冬季冻裂', '1栋202室', '13800000002', 'completed', 'normal', '已包裹', NULL, '2026-06-10 23:24:23', '2026-06-11 23:24:23', '2026-06-08 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (68, 3, 25, '吊顶修复', '更换破损扣板', '2栋305室', '13800000003', 'completed', 'normal', '修复平整', NULL, '2026-06-07 23:24:23', '2026-06-08 23:24:23', '2026-06-05 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (69, 4, 26, '马桶盖更换', '换新马桶盖', '2栋408室', '13800000004', 'completed', 'normal', '安装稳固', NULL, '2026-06-14 23:24:23', '2026-06-15 23:24:23', '2026-06-12 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (70, 5, 27, '水槽密封胶重打', '重新打玻璃胶', '3栋1102室', '13800000005', 'completed', 'normal', '不再漏水', NULL, '2026-06-11 23:24:23', '2026-06-12 23:24:23', '2026-06-09 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (71, 6, 28, '花洒更换', '换新花洒头', '3栋1205室', '13800000006', 'completed', 'normal', '出水正常', NULL, '2026-06-13 23:24:23', '2026-06-14 23:24:23', '2026-06-11 23:24:23', '2026-06-15 23:24:23');
INSERT INTO `repair_order` VALUES (72, 1, NULL, '门坏了', '门卡死了，开不起来', '1栋101室', '13800000001', 'cancelled', 'normal', NULL, NULL, NULL, NULL, '2026-06-16 21:15:54', '2026-06-16 21:25:33');
INSERT INTO `repair_order` VALUES (73, 1, 23, '门坏了', '门开不了', '1栋101室', '13800000001', 'completed', 'normal', '门修好了', NULL, '2026-06-17 22:35:04', '2026-06-17 22:36:51', '2026-06-16 21:26:47', '2026-06-17 22:36:51');
INSERT INTO `repair_order` VALUES (74, 1, 21, '马桶堵住了', '冲不下去', '1栋101室', '13800000001', 'completed', 'normal', '修好了', NULL, '2026-06-16 22:30:07', '2026-06-17 20:22:25', '2026-06-16 21:40:39', '2026-06-17 20:22:24');
INSERT INTO `repair_order` VALUES (75, 1, 22, '空调坏了', '滴水', '1栋101室', '13800000001', 'processing', 'normal', NULL, '/uploads/repair/20260624/0d9d7ff35adf4e9e8aa72651201541ca.jpg', '2026-06-24 20:36:41', NULL, '2026-06-24 20:31:51', '2026-06-24 20:37:12');
INSERT INTO `repair_order` VALUES (76, 1, NULL, '门打不开', '轮子坏了', '1栋101室', '13800000001', 'pending', 'urgent', NULL, '', NULL, NULL, '2026-06-24 21:01:39', '2026-06-24 21:01:39');

-- ----------------------------
-- Table structure for sys_notification
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification`;
CREATE TABLE `sys_notification`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '接收用户ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '内容',
  `type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '类型',
  `is_read` tinyint(4) NULL DEFAULT 0 COMMENT '是否已读 0-未读 1-已读',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_user_read`(`user_id`, `is_read`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notification
-- ----------------------------
INSERT INTO `sys_notification` VALUES (1, 41, '新工单提醒', '居民提交了新的报修工单：门坏了', 'new_repair', 1, '2026-06-16 21:15:54');
INSERT INTO `sys_notification` VALUES (2, 42, '新工单提醒', '居民提交了新的报修工单：门坏了', 'new_repair', 0, '2026-06-16 21:15:54');
INSERT INTO `sys_notification` VALUES (3, 41, '新工单提醒', '居民提交了新的报修工单：门坏了', 'new_repair', 1, '2026-06-16 21:26:47');
INSERT INTO `sys_notification` VALUES (4, 42, '新工单提醒', '居民提交了新的报修工单：门坏了', 'new_repair', 0, '2026-06-16 21:26:47');
INSERT INTO `sys_notification` VALUES (5, 41, '新工单提醒', '居民提交了新工单：门坏了（工单号 #73），请及时处理。', 'repair', 1, '2026-06-16 21:26:47');
INSERT INTO `sys_notification` VALUES (6, 42, '新工单提醒', '居民提交了新工单：门坏了（工单号 #73），请及时处理。', 'repair', 0, '2026-06-16 21:26:47');
INSERT INTO `sys_notification` VALUES (7, 41, '新工单提醒', '居民提交了新的报修工单：马桶堵住了', 'new_repair', 1, '2026-06-16 21:40:39');
INSERT INTO `sys_notification` VALUES (8, 42, '新工单提醒', '居民提交了新的报修工单：马桶堵住了', 'new_repair', 0, '2026-06-16 21:40:39');
INSERT INTO `sys_notification` VALUES (9, 41, '新工单提醒', '居民提交了新工单：马桶堵住了（工单号 #74），请及时处理。', 'repair', 1, '2026-06-16 21:40:39');
INSERT INTO `sys_notification` VALUES (10, 42, '新工单提醒', '居民提交了新工单：马桶堵住了（工单号 #74），请及时处理。', 'repair', 0, '2026-06-16 21:40:39');
INSERT INTO `sys_notification` VALUES (11, 21, '新派单提醒', '您有新的维修工单：马桶堵住了', 'assigned', 1, '2026-06-16 22:30:07');
INSERT INTO `sys_notification` VALUES (12, 1, '工单处理中', '您的工单「马桶堵住了」已开始处理', 'processing', 1, '2026-06-16 22:30:28');
INSERT INTO `sys_notification` VALUES (13, 41, '新维修工注册', '有新的维修工「杭神」提交了注册申请，请尽快审核', 'worker_register', 1, '2026-06-17 20:20:07');
INSERT INTO `sys_notification` VALUES (14, 42, '新维修工注册', '有新的维修工「杭神」提交了注册申请，请尽快审核', 'worker_register', 0, '2026-06-17 20:20:07');
INSERT INTO `sys_notification` VALUES (15, 45, '审核通过', '您的维修工账号已通过审核，可以开始接单了', 'review_passed', 1, '2026-06-17 20:20:49');
INSERT INTO `sys_notification` VALUES (16, 1, '工单已完成', '您的工单「马桶堵住了」已完成维修', 'completed', 1, '2026-06-17 20:22:24');
INSERT INTO `sys_notification` VALUES (17, 23, '新派单提醒', '您有新的维修工单：门坏了', 'assigned', 1, '2026-06-17 22:35:04');
INSERT INTO `sys_notification` VALUES (18, 1, '工单处理中', '您的工单「门坏了」已开始处理', 'processing', 1, '2026-06-17 22:35:40');
INSERT INTO `sys_notification` VALUES (19, 1, '工单已完成', '您的工单「门坏了」已完成维修', 'completed', 1, '2026-06-17 22:36:51');
INSERT INTO `sys_notification` VALUES (20, 41, '新工单提醒', '居民提交了新的报修工单：空调坏了', 'new_repair', 0, '2026-06-24 20:31:51');
INSERT INTO `sys_notification` VALUES (21, 42, '新工单提醒', '居民提交了新的报修工单：空调坏了', 'new_repair', 0, '2026-06-24 20:31:51');
INSERT INTO `sys_notification` VALUES (22, 41, '新工单提醒', '居民提交了新工单：空调坏了（工单号 #75），请及时处理。', 'repair', 0, '2026-06-24 20:31:51');
INSERT INTO `sys_notification` VALUES (23, 42, '新工单提醒', '居民提交了新工单：空调坏了（工单号 #75），请及时处理。', 'repair', 0, '2026-06-24 20:31:51');
INSERT INTO `sys_notification` VALUES (24, 22, '新派单提醒', '您有新的维修工单：空调坏了', 'assigned', 1, '2026-06-24 20:36:40');
INSERT INTO `sys_notification` VALUES (25, 1, '工单处理中', '您的工单「空调坏了」已开始处理', 'processing', 1, '2026-06-24 20:37:12');
INSERT INTO `sys_notification` VALUES (26, 41, '新工单提醒', '居民提交了新的报修工单：门打不开', 'new_repair', 0, '2026-06-24 21:01:39');
INSERT INTO `sys_notification` VALUES (27, 42, '新工单提醒', '居民提交了新的报修工单：门打不开', 'new_repair', 0, '2026-06-24 21:01:39');
INSERT INTO `sys_notification` VALUES (28, 41, '新工单提醒', '居民提交了新工单：门打不开（工单号 #76），请及时处理。', 'repair', 0, '2026-06-24 21:01:39');
INSERT INTO `sys_notification` VALUES (29, 42, '新工单提醒', '居民提交了新工单：门打不开（工单号 #76），请及时处理。', 'repair', 0, '2026-06-24 21:01:39');
INSERT INTO `sys_notification` VALUES (30, 2, '评价回复提醒', '维修工已回复您的评价（工单：卧室空调不制冷）：感谢好评', 'evaluation_reply', 1, '2026-06-24 21:10:42');
INSERT INTO `sys_notification` VALUES (31, 1, '新公告通知', '管理员发布了新公告：公告', 'announcement', 1, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (32, 2, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (33, 3, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (34, 4, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (35, 5, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (36, 6, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (37, 7, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (38, 8, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (39, 9, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (40, 10, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (41, 11, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (42, 12, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (43, 13, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (44, 14, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (45, 15, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (46, 16, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (47, 17, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (48, 18, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (49, 19, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (50, 20, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (51, 43, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (52, 44, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (53, 21, '新公告通知', '管理员发布了新公告：公告', 'announcement', 1, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (54, 22, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (55, 23, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (56, 24, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (57, 25, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (58, 26, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (59, 27, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (60, 28, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (61, 29, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (62, 30, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (63, 31, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');
INSERT INTO `sys_notification` VALUES (64, 45, '新公告通知', '管理员发布了新公告：公告', 'announcement', 0, '2026-06-25 21:05:09');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID，主键自增',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录用户名，唯一',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '加密密码（BCrypt）',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '手机号',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色：resident/worker/admin',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '居住地址（居民角色必填）',
  `skill` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '技能特长（维修工角色）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'active' COMMENT '状态：active/pending/rejected（维修工审核状态，居民/管理员为active）',
  `register_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'register' COMMENT '注册来源：register（自主注册）/admin_add（管理员添加），仅维修工',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '审核拒绝原因（status=rejected时填写）',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像URL（相对路径或完整URL）',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username`) USING BTREE,
  INDEX `idx_role`(`role`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'zhangwuji', '$2a$10$mMf/IbiDp0/I2GcPjCIcDe2yNd5CdgsO.2L7kcWfDNPelyHmVcRj6', '张无忌', '13800000001', 'resident', '1栋101室', NULL, 'active', 'register', NULL, '/uploads/avatar/20260615/4a5f59cc-afe1-438d-b0f8-c22505bf973b.webp', '2026-06-04 16:23:10', '2026-06-15 22:27:19');
INSERT INTO `sys_user` VALUES (2, 'zhouzhiruo', '$2a$10$.FT/Zg1a2LZbrQE3ONfqnO4XT0aEG9ocuS9piud26OiwRqVz/6wji', '周芷若', '13800000002', 'resident', '1栋202室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-24 21:11:40');
INSERT INTO `sys_user` VALUES (3, 'zhaomin', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '赵敏', '13800000003', 'resident', '2栋305室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (4, 'xiaozhao', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '小昭', '13800000004', 'resident', '2栋408室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (5, 'yangxiao', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '杨逍', '13800000005', 'resident', '3栋1102室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (6, 'fanya', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '范遥', '13800000006', 'resident', '3栋1205室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (7, 'yinliting', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '殷梨亭', '13800000007', 'resident', '4栋203室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (8, 'songyuanqiao', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '宋远桥', '13800000008', 'resident', '4栋304室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (9, 'yuyan', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '俞岩', '13800000009', 'resident', '5栋101室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (10, 'mogu', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '莫谷', '13800000010', 'resident', '5栋202室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (11, 'lidawei', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '李大伟', '13800000011', 'resident', '6栋301室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (12, 'wangfang', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '王芳', '13800000012', 'resident', '6栋402室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (13, 'chenming', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '陈明', '13800000013', 'resident', '7栋503室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (14, 'zhaoli', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '赵丽', '13800000014', 'resident', '7栋604室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (15, 'zhoujie', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '周杰', '13800000015', 'resident', '8栋705室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (16, 'wujing', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '吴静', '13800000016', 'resident', '8栋806室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (17, 'zhengyong', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '郑勇', '13800000017', 'resident', '9栋907室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (18, 'liuqiang', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '刘强', '13800000018', 'resident', '9栋1008室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (19, 'xujie', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '徐杰', '13800000019', 'resident', '10栋1109室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (20, 'huangwei', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '黄伟', '13800000020', 'resident', '10栋1210室', NULL, 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (21, 'zhangsan', '$2a$10$Q/7fMbVQ0QwdiQGrafu9o.9ZLp51znqcM7S5uYYa3DgB5pjCQrx.6', '张三', '13900000001', 'worker', '', '水电维修、管道疏通', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-23 21:06:18');
INSERT INTO `sys_user` VALUES (22, 'lisi', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '李四', '13900000002', 'worker', NULL, '家电维修、空调清洗', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (23, 'wangwu', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '王五', '13900000003', 'worker', NULL, '木工、门窗维修', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (24, 'zhaoliu', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '赵六', '13900000004', 'worker', NULL, '电路检修、灯具安装', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (25, 'sunqi', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '孙七', '13900000005', 'worker', NULL, '防水补漏、墙面修复', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (26, 'zhouba', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '周八', '13900000006', 'worker', NULL, '下水道疏通、马桶维修', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (27, 'wujiu', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '吴九', '13900000007', 'worker', NULL, '暖气维修、水管更换', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (28, 'zhengshi', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '郑十', '13900000008', 'worker', NULL, '家电维修、电路检修', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (29, 'linzi', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '林子', '13900000009', 'worker', NULL, '门窗安装、锁具维修', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (30, 'huanghe', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '黄河', '13900000010', 'worker', NULL, '水电综合维修', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (31, 'wangqiang', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '王强', '15900000001', 'worker', NULL, '家电维修', 'active', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-16 19:55:08');
INSERT INTO `sys_user` VALUES (32, 'liyan', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '李燕', '15900000002', 'worker', NULL, '水电维修', 'pending', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (33, 'chengang', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '陈刚', '15900000003', 'worker', NULL, '管道疏通', 'pending', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (34, 'yangfan', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '杨帆', '15900000004', 'worker', NULL, '空调维修', 'pending', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (35, 'zhangwei', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '张伟', '15900000005', 'worker', NULL, '木工', 'pending', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (36, 'luming', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '陆明', '15800000001', 'worker', NULL, '普通维修', 'rejected', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (37, 'kongliang', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '孔亮', '15800000002', 'worker', NULL, '水电', 'rejected', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (38, 'shijie', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '石杰', '15800000003', 'worker', NULL, '家电', 'rejected', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (39, 'hejun', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '何军', '15800000004', 'worker', NULL, '维修', 'rejected', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (40, 'lixin', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '李欣', '15800000005', 'worker', NULL, '水电', 'rejected', 'register', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (41, 'admin1', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '系统管理员', '18800000001', 'admin', '', '', 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-25 18:12:31');
INSERT INTO `sys_user` VALUES (42, 'admin2', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '运维专员', '18800000002', 'admin', '物业办公室', NULL, 'active', 'admin_add', NULL, NULL, '2026-06-04 16:23:10', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (43, 'resident1', '$2a$10$gk1GylAX3tA5JrP0h/Sn1uz7PCg8QxmyofdExuqdQDPUIpGfzPfL2', '测试居民', '13800000077', 'resident', '1栋101室', NULL, 'active', 'register', NULL, NULL, '2026-06-15 17:47:40', '2026-06-15 18:07:11');
INSERT INTO `sys_user` VALUES (44, 'kangkang', '$2a$10$L6dx4PNMMJi6xujaK2Sk0uOG1pyZcEzP8wwWkEKobiyaxZINOBUlO', '康神', '13800000021', 'resident', '2栋606室', NULL, 'active', 'register', NULL, NULL, '2026-06-17 20:18:18', '2026-06-17 20:18:18');
INSERT INTO `sys_user` VALUES (45, 'hanghang', '$2a$10$85KTngDspM3wwzKgYWINOeoGfV.MCylvK9mb7qOc7vaIn.fZ7A5ji', '杭神', '15800000006', 'worker', NULL, '水电维修', 'active', 'register', NULL, NULL, '2026-06-17 20:20:07', '2026-06-17 20:20:49');

SET FOREIGN_KEY_CHECKS = 1;
