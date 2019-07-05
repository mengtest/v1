/*
 * @Author: Michael Zhang
 * @Date: 2019-05-06 15:39:35
 * @LastEditTime: 2019-05-06 16:25:10
 */


/**
 * doc 创建时间 plugin。其中在 插入一条 doc 时 同时创建 createdAt 和 updateAt 字段
 *
 * @param schema
 * @param options
 */
function createdAt(schema, options) {
    schema.add({createdAt: Date});
    schema.add({updatedAt: Date});

    schema.pre('save', function (next) {
        let now = Date.now();
        this.createdAt = now;
        this.updatedAt = now;
        next();
    });

    if (options && options.index) {
        schema.path('createdAt').index(options.index);
        schema.path('updatedAt').index(options.index);
    }
}


/**
 * doc 更新时间 plugin
 *
 * @param schema
 * @param options
 */
function updatedAt(schema, options) {
    schema.pre('update', function (next) {
        this.update({}, {$set: {updatedAt: new Date()}});
        next();
    });

    if (options && options.index) {
        schema.path('updatedAt').index(options.index);
    }
}


module.exports = {
    createdAt: createdAt,
    updatedAt: updatedAt,
};