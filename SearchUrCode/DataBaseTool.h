//
//  DataBaseTool.h
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/24.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataBaseTool : NSObject

+(void)createTable;
+(void)dml:(NSString *)sql;
+(NSArray *)records;
+(NSArray *)recordsWithCondition:(NSString *)condition;
+(NSArray *)replysWithR_id:(int)r_id;
+(NSArray *)recordsWithChange;
//计算本地有多少条数据
+(int)numOfRecords;
+(void)clearReply;
@end
