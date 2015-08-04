//
//  DataBaseTool.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/24.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "DataBaseTool.h"
#import <sqlite3.h>
#import "Record.h"
#import "Reply.h"

@implementation DataBaseTool

static sqlite3 *_db;

#pragma mark 打开数据库
+ (void)initialize
{
    // 0.获得沙盒中的数据库文件名
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"code.sqlite"];
    
    // 1.创建(打开)数据库（如果数据库文件不存在，会自动创建）
    int result = sqlite3_open(filename.UTF8String, &_db);
    if (result == SQLITE_OK) {
        NSLog(@"成功打开数据库");
        //建表reply
        const char *sql = "create table if not exists reply (id integer primary key autoincrement, r_id integer, u_id integer, record_id integer, content text);";
        char *errorMesg = NULL;
        int result = sqlite3_exec(_db, sql, NULL, NULL, &errorMesg);
        
        //创建表record
        sql = "create table if not exists record (id integer primary key autoincrement, title text, content text, good integer default 0, bad integer default 0, changed integer default 1);";
        result = sqlite3_exec(_db, sql, NULL, NULL, &errorMesg);
        
        if (result == SQLITE_OK) {
            NSLog(@"成功创建表");
        }else{
            NSLog(@"创建表失败了");
        }
    }else{
        NSLog(@"打开数据库失败");
    }
}

#pragma mark 执行dml语句
+(void)dml:(NSString *)sql{
    NSLog(@"现在是更改changed的时候");
    NSLog(@"%@",sql);
        char *errorMesg = NULL;
        int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errorMesg);
        if (result == SQLITE_OK) {
            NSLog(@"%@语句操作成功。",sql);
        } else {
            NSLog(@"%@语句操失败,原因:%s", sql, errorMesg);
        }
    
}
#pragma mark 执行dql语句
+(NSArray *)records{
    // 0.定义数组
    NSMutableArray *records = nil;
    
    const char *sql = "select id,title, content,good, bad,changed from record;";
    
    // 2.定义一个stmt存放结果集
    sqlite3_stmt *stmt = NULL;
    
    // 3.检测SQL语句的合法性
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询语句是合法的");
        records = [NSMutableArray array];
        
        // 4.执行SQL语句，从结果集中取出数据
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一行数据
            // 获得这行对应的数据
            
            Record *record = [[Record alloc] init];
            
            // 获得第0列的id
            record.r_id = sqlite3_column_int(stmt, 0);
            
            // 获得第1列的title
            const unsigned char *title = sqlite3_column_text(stmt, 1);
            record.title = [NSString stringWithUTF8String:(const char *)title];
            
            // 获得第2列的content
            const unsigned char *content = sqlite3_column_text(stmt, 2);
            record.content = [NSString stringWithUTF8String:(const char *)content];
            
            //获得第三列的good
            record.good = sqlite3_column_int(stmt, 3);
            //获得第三列的bad
            record.bad = sqlite3_column_int(stmt, 4);
            //获得第三列的change
            record.changed = sqlite3_column_int(stmt, 5);
            // 添加到数组
            [records addObject:record];
        }
    } else {
//        NSLog(@"查询语句非合法");
         NSAssert1(0,@"Error:%s",sqlite3_errmsg(_db));
    }
    return records;
}

+(NSArray *)recordsWithCondition:(NSString *)condition{
    // 0.定义数组
    NSMutableArray *records = nil;
    
    // 1.定义sql语句
    const char *sql = "select id,title, content,good, bad,changed from record where title like ?;";
    
    // 2.定义一个stmt存放结果集
    sqlite3_stmt *stmt = NULL;
    
    // 3.检测SQL语句的合法性
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询语句是合法的");
        records = [NSMutableArray array];
        
        // 填补占位符的内容
        NSString *newCondition = [NSString stringWithFormat:@"%%%@%%", condition];
        //        NSLog(@"%@", newCondition);
        sqlite3_bind_text(stmt, 1, newCondition.UTF8String, -1, NULL);
        
        // 4.执行SQL语句，从结果集中取出数据
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一行数据
            // 获得这行对应的数据
            
            Record *record = [[Record alloc] init];
            
            // 获得第0列的id
            record.r_id = sqlite3_column_int(stmt, 0);
            
            // 获得第1列的title
            const unsigned char *title = sqlite3_column_text(stmt, 1);
            record.title = [NSString stringWithUTF8String:(const char *)title];
            
            // 获得第2列的content
            const unsigned char *content = sqlite3_column_text(stmt, 2);
            record.content = [NSString stringWithUTF8String:(const char *)content];
            
            //获得第三列的good
            record.good = sqlite3_column_int(stmt, 3);
            //获得第三列的bad
            record.bad = sqlite3_column_int(stmt, 4);
            //获得第三列的change
            record.changed = sqlite3_column_int(stmt, 5);
            // 添加到数组
            [records addObject:record];
        }
    } else {
        NSLog(@"查询语句非合法");
    }
    
    return records;
}

+(NSArray *)replysWithR_id:(int)r_id{
    // 0.定义数组
    NSMutableArray *replys = nil;
    
    // 1.定义sql语句
    const char *sql = "select id, u_id,content from reply where record_id = ?;";
    // 2.定义一个stmt存放结果集
    sqlite3_stmt *stmt = NULL;
    
    // 3.检测SQL语句的合法性
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询语句是合法的");
        replys = [NSMutableArray array];
        
        // 填补占位符的内容
        NSString *newCondition = [NSString stringWithFormat:@"%d", r_id];
        //        NSLog(@"%@", newCondition);
        sqlite3_bind_text(stmt, 1, newCondition.UTF8String, -1, NULL);
        
        // 4.执行SQL语句，从结果集中取出数据
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一行数据
            // 获得这行对应的数据
            
            Reply *reply = [[Reply alloc] init];
            
            // 获得第0列的id
            reply.ID = sqlite3_column_int(stmt, 0);
            
            // 获得第1列的
            reply.u_id = sqlite3_column_int(stmt, 1);
            
            
            const unsigned char *content = sqlite3_column_text(stmt, 2);
            reply.content = [NSString stringWithUTF8String:(const char *)content];

           
            // 添加到数组
            [replys addObject:reply];
        }
    } else {
        NSLog(@"查询语句非合法");
    }
    
    return replys;
}

//这里的数据是要上传到服务器的
+(NSArray *)recordsWithChange{
    // 0.定义数组
    NSMutableArray *records = nil;
    
    const char *sql = "select id,title, content,good, bad from record where changed = 1;";
    
    // 2.定义一个stmt存放结果集
    sqlite3_stmt *stmt = NULL;
    
    // 3.检测SQL语句的合法性
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询语句是合法的");
        records = [NSMutableArray array];
        
        // 4.执行SQL语句，从结果集中取出数据
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一行数据
            // 获得这行对应的数据
            
            Record *record = [[Record alloc] init];
            
            // 获得第0列的id
            record.ID = sqlite3_column_int(stmt, 0);
            
            // 获得第1列的title
            const unsigned char *title = sqlite3_column_text(stmt, 1);
            record.title = [NSString stringWithUTF8String:(const char *)title];
            
            // 获得第2列的content
            const unsigned char *content = sqlite3_column_text(stmt, 2);
            record.content = [NSString stringWithUTF8String:(const char *)content];
            
            //获得第三列的good
            record.good = sqlite3_column_int(stmt, 3);
            //获得第三列的bad
            record.bad = sqlite3_column_int(stmt, 4);
            // 添加到数组
            [records addObject:record];
        }
    } else {
        //        NSLog(@"查询语句非合法");
        NSAssert1(0,@"Error:%s",sqlite3_errmsg(_db));
    }
    return records;
}

+(int)numOfRecords{
    // 0.定义数组
    int num = 0;
    const char *sql = "select count(*) from record;";
    
    // 2.定义一个stmt存放结果集
    sqlite3_stmt *stmt = NULL;
    
    // 3.检测SQL语句的合法性
    int result = sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询语句是合法的");
        // 4.执行SQL语句，从结果集中取出数据
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 真的查询到一行数据
            // 获得这行对应的数据
            
            // 获得第0列的id
             num = sqlite3_column_int(stmt, 0);
            }
    } else {
        //        NSLog(@"查询语句非合法");
        NSAssert1(0,@"Error:%s",sqlite3_errmsg(_db));
    }
    return num;
}

//删除回复表中的数据
+(void)clearReply{
    const char *sql = "delete from reply;";
    char *errorMesg = NULL;
    sqlite3_exec(_db, sql, NULL, NULL, &errorMesg);
}
@end
