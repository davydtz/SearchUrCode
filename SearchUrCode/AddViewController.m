
//
//  AddViewController.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/25.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "AddViewController.h"
#import "DataBaseTool.h"

@interface AddViewController()
@property (nonatomic, weak) UITextField *r_title;
@property (nonatomic, weak) UITextView *r_content;
@end

@implementation AddViewController

-(void)viewDidLoad{
    self.title = @"添加记录";
    self.view.backgroundColor = [UIColor yellowColor];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    //键盘出现的通知，键盘隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //标题
    UITextField *title = [[UITextField alloc] initWithFrame:CGRectMake(0,64, 320, 60)];
    title.backgroundColor = [UIColor orangeColor];
    title.placeholder = @"请输入标题";
    [self.view addSubview:title];
    self.r_title = title;
    
    //内容
    UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(0,134, 320, 240)];
    content.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:content];
    self.r_content = content;
    
    //按钮
    UIButton *btn = [[UIButton alloc] init];
    btn.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height-90);
    btn.bounds = CGRectMake(0, 0, 100, 50);
    [btn setBackgroundColor:[UIColor grayColor]];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTintColor:[UIColor blackColor]];
    [self.view addSubview:btn];
    
}

-(void)btnClick{
    NSString *sql = [NSString stringWithFormat:@"insert into record (title, content) values ('%@','%@');",self.r_title.text,self.r_content.text];
    [DataBaseTool dml:sql];
    self.tabBarController.selectedIndex = 0;
}

-(void)viewTapped{
    [self.view endEditing:YES];
}

-(void)keyboardWillShowFrame:(NSNotification *)note{
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height + 190;
    
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
@end
