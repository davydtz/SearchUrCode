//
//  RecordCell.h
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/28.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordFrame.h"

@interface RecordCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) RecordFrame *recordsFrame;
@end
