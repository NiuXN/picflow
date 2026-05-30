package com.picflow.server.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * MyBatis-Plus 全局审计字段自动填充处理器
 *
 * 功能:
 * 1. 自动填充 createdAt (创建时间)
 * 2. 自动填充 updatedAt (更新时间)
 * 3. deleted (逻辑删除) 由 @TableLogic 自动处理，无需手动填充
 *
 * 使用方式:
 * 在实体类字段上添加 @TableField(fill = FieldFill.INSERT) 或 @TableField(fill = FieldFill.INSERT_UPDATE)
 *
 * 支持的字段名:
 * - createdAt / created_at / createTime / create_time
 * - updatedAt / updated_at / updateTime / update_time
 */
@Component
public class GlobalMetaObjectHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createdAt", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "created_at", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "createTime", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "create_time", LocalDateTime.class, LocalDateTime.now());

        this.strictInsertFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "updated_at", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "update_time", LocalDateTime.class, LocalDateTime.now());
        
        // deleted 由 @TableLogic 自动处理
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
        this.strictUpdateFill(metaObject, "updated_at", LocalDateTime.class, LocalDateTime.now());
        this.strictUpdateFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
        this.strictUpdateFill(metaObject, "update_time", LocalDateTime.class, LocalDateTime.now());
    }
}
