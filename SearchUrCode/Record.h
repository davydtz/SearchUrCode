//
//  Recode.h
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/24.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject

@property (nonatomic, assign) int ID;
@property (nonatomic, assign) int u_id;
@property (nonatomic, assign) int r_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) int good;
@property (nonatomic, assign) int bad;
@property (nonatomic, assign) int changed;

@end
