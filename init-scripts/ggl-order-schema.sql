-- ============================================
-- GGL-Hub 订单服务数据库初始化脚本
-- 数据库: ggl_order
-- 创建时间: $(date)
-- ============================================

-- 创建订单数据库
CREATE DATABASE IF NOT EXISTS `ggl_order` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ggl_order`;

-- ============================================
-- 1. 用户表
-- ============================================
CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================
-- 2. 订单表
-- ============================================
CREATE TABLE IF NOT EXISTS `order` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(32) NOT NULL COMMENT '订单编号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `total_amount` decimal(10,2) NOT NULL COMMENT '订单总金额',
  `discount_amount` decimal(10,2) DEFAULT '0.00' COMMENT '优惠金额',
  `pay_amount` decimal(10,2) NOT NULL COMMENT '实际支付金额',
  `payment_method` varchar(20) DEFAULT NULL COMMENT '支付方式：ALIPAY, WECHAT, BANK_CARD',
  `payment_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '支付状态：0-待支付，1-已支付，2-支付失败，3-已退款',
  `order_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '订单状态：0-待处理，1-已确认，2-已发货，3-已完成，4-已取消',
  `shipping_address` varchar(500) DEFAULT NULL COMMENT '收货地址',
  `shipping_contact` varchar(50) DEFAULT NULL COMMENT '收货人',
  `shipping_phone` varchar(20) DEFAULT NULL COMMENT '收货电话',
  `remark` varchar(500) DEFAULT NULL COMMENT '订单备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `complete_time` datetime DEFAULT NULL COMMENT '完成时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_pay_time` (`pay_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- ============================================
-- 3. 订单项表
-- ============================================
CREATE TABLE IF NOT EXISTS `order_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单项ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `product_name` varchar(200) NOT NULL COMMENT '商品名称',
  `product_image` varchar(255) DEFAULT NULL COMMENT '商品图片',
  `product_price` decimal(10,2) NOT NULL COMMENT '商品单价',
  `quantity` int(11) NOT NULL COMMENT '购买数量',
  `subtotal` decimal(10,2) NOT NULL COMMENT '小计金额',
  `specifications` json DEFAULT NULL COMMENT '商品规格',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_order_item_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单项表';

-- ============================================
-- 4. 支付记录表
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '支付记录ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `payment_no` varchar(32) NOT NULL COMMENT '支付流水号',
  `payment_method` varchar(20) NOT NULL COMMENT '支付方式',
  `payment_amount` decimal(10,2) NOT NULL COMMENT '支付金额',
  `payment_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '支付状态：0-处理中，1-成功，2-失败',
  `payment_time` datetime DEFAULT NULL COMMENT '支付时间',
  `transaction_id` varchar(64) DEFAULT NULL COMMENT '第三方交易ID',
  `payer_info` json DEFAULT NULL COMMENT '支付者信息',
  `error_message` varchar(500) DEFAULT NULL COMMENT '错误信息',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_payment_no` (`payment_no`),
  UNIQUE KEY `uk_transaction_id` (`transaction_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_payment_time` (`payment_time`),
  CONSTRAINT `fk_payment_record_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付记录表';

-- ============================================
-- 5. 物流记录表
-- ============================================
CREATE TABLE IF NOT EXISTS `shipping_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '物流记录ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `shipping_no` varchar(32) NOT NULL COMMENT '物流单号',
  `shipping_company` varchar(50) NOT NULL COMMENT '物流公司',
  `shipping_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '物流状态：0-待发货，1-已发货，2-运输中，3-已签收',
  `sender_address` varchar(500) DEFAULT NULL COMMENT '发货地址',
  `receiver_address` varchar(500) DEFAULT NULL COMMENT '收货地址',
  `receiver_name` varchar(50) DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) DEFAULT NULL COMMENT '收货人电话',
  `estimated_delivery_time` datetime DEFAULT NULL COMMENT '预计送达时间',
  `actual_delivery_time` datetime DEFAULT NULL COMMENT '实际送达时间',
  `tracking_info` json DEFAULT NULL COMMENT '物流跟踪信息',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_shipping_no` (`shipping_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_shipping_status` (`shipping_status`),
  CONSTRAINT `fk_shipping_record_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='物流记录表';

-- ============================================
-- 6. 退款记录表
-- ============================================
CREATE TABLE IF NOT EXISTS `refund_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '退款记录ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `refund_no` varchar(32) NOT NULL COMMENT '退款单号',
  `refund_amount` decimal(10,2) NOT NULL COMMENT '退款金额',
  `refund_reason` varchar(500) DEFAULT NULL COMMENT '退款原因',
  `refund_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '退款状态：0-申请中，1-已退款，2-拒绝退款',
  `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
  `approver` varchar(50) DEFAULT NULL COMMENT '审核人',
  `approve_time` datetime DEFAULT NULL COMMENT '审核时间',
  `approve_remark` varchar(500) DEFAULT NULL COMMENT '审核备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_refund_no` (`refund_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_refund_status` (`refund_status`),
  CONSTRAINT `fk_refund_record_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款记录表';

-- ============================================
-- 7. 优惠券表
-- ============================================
CREATE TABLE IF NOT EXISTS `coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '优惠券ID',
  `coupon_code` varchar(20) NOT NULL COMMENT '优惠券码',
  `coupon_name` varchar(100) NOT NULL COMMENT '优惠券名称',
  `coupon_type` tinyint(1) NOT NULL COMMENT '优惠券类型：1-满减券，2-折扣券，3-现金券',
  `discount_value` decimal(10,2) NOT NULL COMMENT '优惠值',
  `min_order_amount` decimal(10,2) DEFAULT '0.00' COMMENT '最低订单金额',
  `max_discount_amount` decimal(10,2) DEFAULT NULL COMMENT '最大优惠金额',
  `total_quantity` int(11) NOT NULL COMMENT '总数量',
  `used_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '已使用数量',
  `valid_from` datetime NOT NULL COMMENT '有效期开始',
  `valid_to` datetime NOT NULL COMMENT '有效期结束',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupon_code` (`coupon_code`),
  KEY `idx_status` (`status`),
  KEY `idx_valid_from` (`valid_from`),
  KEY `idx_valid_to` (`valid_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='优惠券表';

-- ============================================
-- 8. 用户优惠券表
-- ============================================
CREATE TABLE IF NOT EXISTS `user_coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户优惠券ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `coupon_id` bigint(20) NOT NULL COMMENT '优惠券ID',
  `order_id` bigint(20) DEFAULT NULL COMMENT '使用的订单ID',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态：0-未使用，1-已使用，2-已过期',
  `receive_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `use_time` datetime DEFAULT NULL COMMENT '使用时间',
  `expire_time` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_coupon` (`user_id`, `coupon_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expire_time` (`expire_time`),
  CONSTRAINT `fk_user_coupon_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_coupon_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_coupon_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户优惠券表';

-- ============================================
-- 9. 商品表（简化版）
-- ============================================
CREATE TABLE IF NOT EXISTS `product` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `product_code` varchar(50) NOT NULL COMMENT '商品编码',
  `product_name` varchar(200) NOT NULL COMMENT '商品名称',
  `product_description` text COMMENT '商品描述',
  `category_id` bigint(20) DEFAULT NULL COMMENT '分类ID',
  `brand` varchar(100) DEFAULT NULL COMMENT '品牌',
  `unit_price` decimal(10,2) NOT NULL COMMENT '单价',
  `stock_quantity` int(11) NOT NULL DEFAULT '0' COMMENT '库存数量',
  `min_stock` int(11) DEFAULT '10' COMMENT '最低库存',
  `image_url` varchar(255) DEFAULT NULL COMMENT '商品图片',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：0-下架，1-上架',
  `specifications` json DEFAULT NULL COMMENT '商品规格',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_code` (`product_code`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品表';

-- ============================================
-- 10. 库存变更记录表
-- ============================================
CREATE TABLE IF NOT EXISTS `inventory_change` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '库存变更ID',
  `product_id` bigint(20) NOT NULL COMMENT '商品ID',
  `change_type` tinyint(1) NOT NULL COMMENT '变更类型：1-入库，2-出库，3-调整',
  `change_quantity` int(11) NOT NULL COMMENT '变更数量',
  `before_quantity` int(11) NOT NULL COMMENT '变更前数量',
  `after_quantity` int(11) NOT NULL COMMENT '变更后数量',
  `reference_no` varchar(50) DEFAULT NULL COMMENT '关联单号',
  `reference_type` varchar(20) DEFAULT NULL COMMENT '关联类型：ORDER, PURCHASE, ADJUSTMENT',
  `operator` varchar(50) DEFAULT NULL COMMENT '操作人',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_change_type` (`change_type`),
  KEY `idx_reference_no` (`reference_no`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `fk_inventory_change_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存变更记录表';

-- ============================================
-- 11. 插入测试数据
-- ============================================

-- 插入测试用户
INSERT IGNORE INTO `user` (`username`, `password`, `email`, `phone`, `nickname`, `status`) VALUES