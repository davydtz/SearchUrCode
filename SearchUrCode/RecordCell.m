//
//  RecordCell.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/28.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "RecordCell.h"
#import "RecordFrame.h"
#import "Record.h"
#import "UIImage+Resize.h"

@interface RecordCell ()

@property (nonatomic, weak) UILabel *titleLabe;
@property (nonatomic, weak) UILabel *recordLable;
@property (nonatomic, weak) UIImageView *image;

@end

@implementation RecordCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"record";
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[RecordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSubviews];
        
        

    }
    return self;
}

-(void)setSubviews{
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
//    titleLable.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:titleLable];
    self.titleLabe = titleLable;
    
    UILabel *recordLabe = [[UILabel alloc] init];
    recordLabe.textColor = [UIColor brownColor];
    recordLabe.font = [UIFont systemFontOfSize:13];
    recordLabe.numberOfLines = 3;
    [self.contentView addSubview:recordLabe];
    self.recordLable = recordLabe;
    
    UIImageView *image = [[UIImageView alloc] init];
    image.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:image];
    self.image = image;

}

-(void)setRecordsFrame:(RecordFrame *)recordsFrame{
    _recordsFrame = recordsFrame;
    Record *record = self.recordsFrame.record;
    
    self.titleLabe.text = record.title;
    self.titleLabe.frame = self.recordsFrame.titleViewF;
    
    self.recordLable.text = record.content;
    self.recordLable.frame = self.recordsFrame.recordViewF;
    
    //加一条横线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(2, self.recordLable.frame.origin.y-3, 310, 0.5)];
    lineView.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:lineView];
    
    self.image.image = [UIImage imageNamed:@"imaage"];
    self.image.frame = self.recordsFrame.imageViewF;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.recordsFrame.cellHeight)];
    UIImageView *cellBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.recordsFrame.cellHeight)];
    
    cellBgImage.image = [UIImage resizedImageWithName:@"cell_background"];
    [view addSubview:cellBgImage];
    self.backgroundView = view;
}


@end
