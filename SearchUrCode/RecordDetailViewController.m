//
//  RecordDetailViewController.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/25.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "RecordDetailViewController.h"
#import "Record.h"
#import "DataBaseTool.h"
#import "Reply.h"
#import "DataBaseTool.h"

@interface RecordDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *replys;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UITextView *content;
@end

@implementation RecordDetailViewController

-(void)viewDidLoad{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed:0x44/255.0 green:0xCE/255.0 blue:0xF6/255.0 alpha:0];
    self.view.backgroundColor = [UIColor orangeColor];
    self.title = @"本地数据";
    
    //右上角按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(btnClick:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    
    //显示标题
    UILabel *title = [[UILabel alloc] init];
    title.text = _record.title;
    CGSize titleSize = [title.text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13] constrainedToSize:CGSizeMake(320, MAXFLOAT)];
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    title.frame = (CGRect){{0,70},titleSize};
    title.numberOfLines = 0;
    title.tintColor = [UIColor whiteColor];
    [self.view addSubview:title];
    
    
    //加一条横线
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, CGRectGetMaxY(title.frame)+2, 320, 0.5);
    lineView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineView];
    
    //显示内容
    UITextView *content = [[UITextView alloc] init];
    content.editable = NO;
    content.text = _record.content;
    content.font = [UIFont systemFontOfSize:13];
    CGFloat contentY = CGRectGetMaxY(lineView.frame) + 2;
    content.frame = CGRectMake(0, contentY, 320, 200);
    content.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:content];
    _content = content;
    
    
    //添加两个按钮，赞、踩
    UIButton *goodBtn = [[UIButton alloc] init];
    goodBtn.frame = CGRectMake(0, CGRectGetMaxY(content.frame)+2, 160, 17);
    [goodBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [goodBtn setTitle:[NSString stringWithFormat:@"%d",_record.good] forState:UIControlStateNormal];
    goodBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    goodBtn.userInteractionEnabled = NO;
    [self.view addSubview:goodBtn];
  
    
    UIButton *badBtn = [[UIButton alloc] init];
    badBtn.frame = CGRectMake(160, CGRectGetMaxY(content.frame)+2, 160, 17);
    [badBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    [badBtn setTitle:[NSString stringWithFormat:@"%d",_record.bad] forState:UIControlStateNormal];
    badBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    badBtn.userInteractionEnabled = NO;
    [self.view addSubview:badBtn];
    
    
    //显示评论的内容
    NSLog(@"******%d",_record.r_id);
    _replys = [DataBaseTool replysWithR_id:_record.r_id];
    if (_replys.count > 0) {
        UITableView *table = [[UITableView alloc] init];
        table.frame = CGRectMake(0, CGRectGetMaxY(badBtn.frame)+7, 320, 200);
        table.backgroundColor = [UIColor orangeColor];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.delegate = self;
        table.dataSource = self;
        [self.view addSubview:table];
        _table = table;
        table.rowHeight = 20;
    }else{
        UILabel *lable = [[UILabel alloc] init];
        lable.font = [UIFont systemFontOfSize:13];
        lable.frame = CGRectMake(10, CGRectGetMaxY(badBtn.frame)+3, 320, 30);
        lable.text = @"没有评论...";
        [self.view addSubview:lable];
    }
    
}


#pragma mark -tableView的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _replys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"reuse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    Reply *reply = _replys[indexPath.row];
    cell.textLabel.text = reply.content;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}


-(void)btnClick:(UIBarButtonItem *)btn{
    if (_content.editable == NO) {
        //进入编辑状态
        _content.editable = YES;
        [_content becomeFirstResponder];
        btn.title = @"保存";
    }else{
        //进入保存状态
        NSLog(@"保存了");
        _content.editable = NO;
        btn.title = @"编辑";
        NSString *sql = [NSString stringWithFormat:@"update record set content='%@',changed=1 where id=%d;",_content.text,_record.r_id];
        [DataBaseTool dml:sql];
    }
    
}



@end
