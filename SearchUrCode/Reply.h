//
//  Reply.h
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/25.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reply : NSObject

@property (nonatomic, assign) int ID;
@property (nonatomic, assign) int u_id;
@property (nonatomic, assign) int r_id;
@property (nonatomic, assign) int record_id;
@property (nonatomic, copy) NSString *content;

@end
