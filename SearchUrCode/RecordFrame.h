//
//  RecordFrame.h
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/28.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class Record;

@interface RecordFrame : NSObject
@property (nonatomic, strong) Record *record;

@property (nonatomic, assign, readonly) CGRect titleViewF;
@property (nonatomic, assign, readonly) CGRect recordViewF;
@property (nonatomic, assign, readonly) CGRect imageViewF;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@end
