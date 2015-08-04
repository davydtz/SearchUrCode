//
//  DetailViewController.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/27.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "DetailViewController.h"
#import "Record.h"
#import "Reply.h"
#import "DataBaseTool.h"
#import "AFNetworking.h"

@interface DetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *replys;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UITextField *replyField;
@property (nonatomic, strong) UIButton *badBtn;
@property (nonatomic, strong) UILabel *lable;
@property (nonatomic, strong) UIView *replyView;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络数据";
    
    //添加触摸手势
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    self.view.backgroundColor = [UIColor orangeColor];
    //键盘出现的通知，键盘隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    //显示标题
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 320, 100)];
    title.text = _record.title;
    [self.view addSubview:title];
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


    //添加两个按钮，赞、踩
    UIButton *goodBtn = [[UIButton alloc] init];
    goodBtn.frame = CGRectMake(0, CGRectGetMaxY(content.frame)+2, 160, 17);
    [goodBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [goodBtn setTitle:[NSString stringWithFormat:@"%d",_record.good] forState:UIControlStateNormal];
    goodBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [goodBtn addTarget:self action:@selector(good_or_bad_Click:) forControlEvents:UIControlEventTouchUpInside];
    goodBtn.tag = 0;
    [self.view addSubview:goodBtn];
    
    
    UIButton *badBtn = [[UIButton alloc] init];
    badBtn.frame = CGRectMake(160, CGRectGetMaxY(content.frame)+2, 160, 17);
    [badBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    [badBtn setTitle:[NSString stringWithFormat:@"%d",_record.bad] forState:UIControlStateNormal];
    badBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [badBtn addTarget:self action:@selector(good_or_bad_Click:) forControlEvents:UIControlEventTouchUpInside];
    badBtn.tag = 1;
    [self.view addSubview:badBtn];
    _badBtn = badBtn;
    
    //显示评论的内容,这个评论数据是从服务器获取的
    [self getReply];
    
}
-(void)removeReplyView{
    _table = nil;
    _lable = nil;
    _replyView = nil;
}
-(void)addReplyView{
    //从服务器获取Reply之后
    if (_replys.count > 0) {
        //添加评论模块
        UITableView *table = [[UITableView alloc] init];
        table.frame = CGRectMake(0, CGRectGetMaxY(_badBtn.frame)+7, 320, 200);
        table.backgroundColor = [UIColor orangeColor];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.delegate = self;
        table.dataSource = self;
        [self.view addSubview:table];
        _table = table;
        table.rowHeight = 20;
        
        UIView *replyView = [self getReplyView];
        
        table.tableFooterView = replyView;
    }else{
        UILabel *lable = [[UILabel alloc] init];
        lable.font = [UIFont systemFontOfSize:13];
        lable.frame = CGRectMake(10, CGRectGetMaxY(_badBtn.frame)+3, 320, 30);
        lable.text = @"没有评论...";
        [self.view addSubview:lable];
        _lable = lable;
        
        UIView *replyView = [self getReplyView];
        replyView.frame = CGRectMake(0, CGRectGetMaxY(lable.frame), 320, 100);
        [self.view addSubview:replyView];
        _replyView = replyView;
    }
}

//从服务器获取replys的值,赋值给Replys数组
-(void)getReply{
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    // 2.封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"r_id"] = [NSString stringWithFormat:@"%d",self.record.ID];
    
    [mgr POST:@"http://localhost/getReplyOfId.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        //        NSLog(@"%@", responseObject);
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in responseObject) {
            Reply *reply = [[Reply alloc] init];
            reply.r_id = [dict[@"r_id"] intValue];
            reply.content = dict[@"reply"];
            NSLog(@"%d--%@",reply.r_id,reply.content);
            [array addObject:reply];
        }
        self.replys = nil;
        self.replys = array;
    
        [self addReplyView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

-(UIView *)getReplyView{
    UIView *replyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    replyView.backgroundColor = [UIColor greenColor];
    //在ReplyView里放入控件
    //放入一个评论控件
    UITextField *replyField = [[UITextField alloc] initWithFrame:CGRectMake(0, 3, 320, 70)];
    replyField.font = [UIFont systemFontOfSize:13];
    [replyField setTextColor:[UIColor lightGrayColor]];
    replyField.borderStyle = UITextBorderStyleRoundedRect;
    _replyField = replyField;
    [replyView addSubview:replyField];
    //放入一个按钮控件
    UIButton *replyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(replyField.frame), 320, 30)];
    replyBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [replyBtn setTitle:@"提交评论" forState:UIControlStateNormal];
    [replyBtn addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:replyBtn];
    return replyView;
}

#pragma mark -tableView的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.replys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"reuse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    Reply *reply = self.replys[indexPath.row];
    cell.textLabel.text = reply.content;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}


-(void)edit{
    NSLog(@"edit");
}

-(void)good_or_bad_Click:(UIButton *)btn{
    btn.userInteractionEnabled = NO;
    NSString *good_or_bad = [[NSString alloc] init];
    int num = 0;
    if (btn.tag == 0) {
        num = _record.good+1;
        good_or_bad = @"good";
    }else{
        num = _record.bad+1;
        good_or_bad = @"bad";
    }
    AFHTTPRequestOperationManager *manage = [AFHTTPRequestOperationManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 2.封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    params[@"r_id"] = [NSString stringWithFormat:@"%d",self.record.ID];
    params[@"good_or_bad"] = good_or_bad;
    
    [manage POST:@"http://localhost/good&badProcess.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
        
        [btn setTitle:[NSString stringWithFormat:@"%d",num] forState:UIControlStateNormal];
        btn.enabled = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}

-(void)reply{
    AFHTTPRequestOperationManager *manage = [AFHTTPRequestOperationManager manager];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 2.封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger ID = [defaults integerForKey:@"ID"];
    params[@"r_id"] = [NSString stringWithFormat:@"%d",self.record.ID];
    params[@"u_id"] = [NSString stringWithFormat:@"%ld",ID];
    params[@"reply"] = _replyField.text;
    [manage POST:@"http://localhost/replyProcess.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"%@",str);
        
        //刷新这个界面的回复区域
        [self removeReplyView];
        [self getReply];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

-(void)keyboardWillShowFrame:(NSNotification *)note{
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height + 50;
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}
-(void)keyboardWillHide:(NSNotification *)note{
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewTapped{
    [self.view endEditing:YES];
}
@end
