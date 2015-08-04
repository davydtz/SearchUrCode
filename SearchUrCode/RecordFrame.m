//
//  RecordFrame.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/28.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "RecordFrame.h"
#import "Record.h"

@implementation RecordFrame

-(void)setRecord:(Record *)record{
    _record = record;
   
    
        //设置title的frame
        CGFloat titltX = 2;
        CGFloat titltY = 0;
    CGSize titltSize = [record.title sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(300, MAXFLOAT)];
    _titleViewF = (CGRect){{titltX,titltY},titltSize};
    
    //设置image的frame
    CGFloat imageX = 300;
    CGFloat imageY = 0;
    CGFloat imageW = 20;
    CGFloat imageH = 20;
    _imageViewF = CGRectMake(imageX, imageY, imageW, imageH);
    
        //设置Record的frame
        CGFloat recordX = 2;
    CGFloat recordY = MAX(CGRectGetMaxY(_titleViewF), imageW) + 5;
    CGSize recordSize = [record.content sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(320, 74)];
    _recordViewF = (CGRect){{recordX,recordY},recordSize};
        
    
    
    _cellHeight = CGRectGetMaxY(_recordViewF) + 10;
}

@end
