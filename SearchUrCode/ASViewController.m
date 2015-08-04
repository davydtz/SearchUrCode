//
//  ASViewController.m
//  ASTextViewDemo
//
//  Created by Adil Soomro on 4/14/14.
//  Copyright (c) 2014 Adil Soomro. All rights reserved.
//

#import "ASViewController.h"
#import "ASTextField.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"

@interface ASViewController ()
@property (weak, nonatomic) IBOutlet ASTextField *passWordLable;
@property (weak, nonatomic) IBOutlet ASTextField *userNameLable;
@property (weak, nonatomic) IBOutlet UILabel *loginState;
@property (weak, nonatomic) IBOutlet UIButton *login_Or_Register_Btn;
@property (nonatomic,retain) NSMutableArray *cellArray;
@end

@implementation ASViewController

- (id)init
{
    self = [super initWithNibName:@"ASViewController" bundle:nil];
    if (self) {
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        tapGr.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGr];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //bake a cellArray to contain all cells
    self.cellArray = [NSMutableArray arrayWithObjects: _usernameCell, _passwordCell, _doneCell, nil];
    //setup text field with respective icons
    [_usernameField setupTextFieldWithIconName:@"user_name_icon"];
    [_passwordField setupTextFieldWithIconName:@"password_icon"];
    
    //键盘出现的通知，键盘隐藏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - tableview deleagate datasource stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return cell's height for particular row
    return ((UITableViewCell*)[self.cellArray objectAtIndex:indexPath.row]).frame.size.height;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return number of cells for the table
    return self.cellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    //return cell for particular row
    cell = [self.cellArray objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //set clear color to cell.
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)changeFieldBackground:(UISegmentedControl *)segment {
    if ([segment selectedSegmentIndex] == 0) {
        [_login_Or_Register_Btn setTitle:@"LOGIN" forState:UIControlStateNormal];
        _login_Or_Register_Btn.tag = 0;
        _loginState.text = @"LOGIN";
        //setup text field with default respective icons
        [_usernameField setupTextFieldWithIconName:@"user_name_icon"];
        [_passwordField setupTextFieldWithIconName:@"password_icon"];
    }else{
        [_login_Or_Register_Btn setTitle:@"REGISTER" forState:UIControlStateNormal];
        _login_Or_Register_Btn.tag = 1;
        _loginState.text = @"REGISTER";
        [_usernameField setupTextFieldWithType:ASTextFieldTypeRound withIconName:@"user_name_icon"];
        [_passwordField setupTextFieldWithType:ASTextFieldTypeRound withIconName:@"password_icon"];
    }
}

- (IBAction)letMeIn:(UIButton *)sender {
    if (sender.tag == 0) {
        [self loginProcess];
    }else{
        [self registerProcess];
    }
}

-(void)loginProcess{
    //处理登录
    if ([self.userNameLable.text isEqualToString:@""] || [self.passWordLable.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"用户名和密码不能为空"];
        return;
    }
    // AFNetworking\AFN
    // 1.创建请求管理对象
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 2.封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"name"] = self.userNameLable.text;
    params[@"password"] = self.passWordLable.text;
    
    // 3.发送请求
    [mgr POST:@"http://localhost/loginProcess.php" parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
          NSString *str1 = [str stringByReplacingOccurrencesOfString:@"ï»¿" withString:@""];
          NSLog(@"%@",str1);
          NSInteger num = [str1 integerValue];
          NSLog(@"---%ld", num);
          
          switch (num) {
              case 0:
                  //密码不正确
                  NSLog(@"密码错误");
                  break;
              case 1:
                  //无该用户，需要注册
                  NSLog(@"无该用户，需要注册");
                  break;
              default:
                  //登录成功，将数据存入偏好设置
              {
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  [defaults setInteger:num forKey:@"ID"];
                  [defaults setObject:self.userNameLable.text forKey:@"name"];
                  [defaults setObject:self.passWordLable.text forKey:@"password"];
                  
                  [self.navigationController popViewControllerAnimated:YES];
              }
                  break;
          }
          
          
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@",[error localizedDescription]);
      }];
    

}
-(void)registerProcess{
    //处理注册
    if ([self.userNameLable.text isEqualToString:@""] || [self.passWordLable.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"用户名和密码不能为空"];
        return;
    }
    // AFNetworking\AFN
    // 1.创建请求管理对象
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 2.封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"name"] = self.userNameLable.text;
    params[@"password"] = self.passWordLable.text;

    [mgr POST:@"http://localhost/registerProcess.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        NSString *str1 = [str stringByReplacingOccurrencesOfString:@"ï»¿" withString:@""];
        NSLog(@"%@", str1);
        NSInteger ID = [str1 integerValue];
        NSLog(@"%ld",ID);
        if (ID == 0) {
            NSLog(@"已经存在于服务器数据库。");
        }else{
            //            存储用户数据
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:ID forKey:@"ID"];
            [defaults setObject:self.userNameLable.text forKey:@"name"];
            [defaults setObject:self.passWordLable.text forKey:@"password"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];

}
- (void)viewTapped{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

#pragma mark 键盘的处理
//{
//    UIKeyboardAnimationCurveUserInfoKey = 7;
//    UIKeyboardAnimationDurationUserInfoKey = "0.25";
//    UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {320, 253}}";
//    UIKeyboardCenterBeginUserInfoKey = "NSPoint: {160, 694.5}";
//    UIKeyboardCenterEndUserInfoKey = "NSPoint: {160, 441.5}";
//    UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 568}, {320, 253}}";
//    UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 315}, {320, 253}}";
//}

-(void)keyboardWillShowFrame:(NSNotification *)note{
    // 设置窗口的颜色
    self.view.window.backgroundColor = self.tableView.backgroundColor;
    
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height + 150;
    
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}
-(void)keyboardWillHide:(NSNotification *)note{
    // 设置窗口的颜色
    self.view.window.backgroundColor = self.tableView.backgroundColor;
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
