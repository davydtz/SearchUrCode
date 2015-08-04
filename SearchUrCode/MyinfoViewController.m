//
//  MyinfoViewController.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/25.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "MyinfoViewController.h"
#import "DataBaseTool.h"
#import "Record.h"
#import "Reply.h"
#import "AFNetworking.h"
#import "ASViewController.h"

@interface MyinfoViewController (){
    NSInteger ID;
    NSString *name;
    NSString *password;
    
}

@end

@implementation MyinfoViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"个人信息";
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgImageView.image = [UIImage imageNamed:@"bgImage"];
    [self.view addSubview:bgImageView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ID = [defaults integerForKey:@"ID"];
    //根据name的值来判断该显示什么控制器
    if (ID) {
        name = [defaults objectForKey:@"name"];
        password = [defaults objectForKey:@"password"];
        [self setupView];
        
    }else{
        ASViewController *loginVc = [[ASViewController alloc] init];
//        LoginViewController *loginVc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVc animated:YES];
    }
}

-(void)setupView{
    UILabel *idLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 30)];
    idLable.text = [NSString stringWithFormat:@"ID=%ld",(long)ID];
    idLable.textAlignment = 1;
    
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 30)];
    nameLable.text = [NSString stringWithFormat:@"name:%@",name];
    nameLable.textAlignment = 1;
    
    UILabel *passwordLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 320, 30)];
    passwordLable.text = [NSString stringWithFormat:@"password:%@",password];
    passwordLable.textAlignment = 1;
    
    [self.view addSubview:nameLable];
    [self.view addSubview:idLable];
    [self.view addSubview:passwordLable];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 300, 128, 128)];
    button.center = CGPointMake(self.view.frame.size.width * 0.5, 250);
    [button setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor blackColor]];
    [self.view addSubview:button];
    
    //更换背景按钮
    UIButton *changeBgimageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 370, 160, 50)];
    [changeBgimageBtn setTitle:@"更换背景" forState:UIControlStateNormal];
    changeBgimageBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:changeBgimageBtn];
    
    //注销帐号按钮
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 370, 160, 50)];
    [logoutBtn setTitle:@"注销帐号" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:logoutBtn];

    
}
-(void)btnClick{
    NSLog(@"开始同步数据了");
    
    //取得本地的笔记，上传到服务器
    NSArray *records = [DataBaseTool recordsWithChange];
    NSLog(@"%lu",(unsigned long)records.count);
    //开始将被修改的笔记发送给服务器
    
    for (int i =0; i<records.count; i++) {
        //向服务器发送数据，开始上传笔记
        NSURL *url = [NSURL URLWithString:@"http://localhost/uploadNewRecordsProcess.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";

        Record *record = records[i];
 
            NSString *str = [NSString stringWithFormat:@"u_id=%ld&r_id=%d&title=%@&content=%@",ID,record.ID,record.title,record.content];
        NSLog(@"%@", str);
            request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
        
//            连接，异步
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError == nil) {
                    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSLog(@"%@",str);
                    }];
                }
            }];
    }
    
    //将本地数据的change状态该为0，即与服务器同步状态
    NSString *sql = [NSString stringWithFormat:@"update record set changed = 0 where changed =1;"];
    [DataBaseTool dml:sql];
    
    
    //将服务器change状态为1的数据同步到本地,先把数据下载下来，保存到本地，在获取本地记录的总数，得到这些记录应该在本地是第几条记录，将r_id插入到服务器
    
    // AFNetworking\AFN
    // 1.创建请求管理对象
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
//    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    // 2.封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //参数为空，直接请求数据
    params[@"u_id"] = [NSString stringWithFormat:@"%ld", ID];
    
    [mgr POST:@"http://localhost/getChangedRecords.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (NSDictionary *dict in responseObject) {
//            NSLog(@"%@", dict[@"r_id"]);
//            NSLog(@"%@",dict[@"content"]);
//            NSLog(@"%@", dict[@"good"]);
//            NSLog(@"%@", dict[@"bad"]);

            NSString *sql = [NSString stringWithFormat:@"update record set content='%@',good=%@, bad=%@ where id=%@",dict[@"content"],dict[@"good"],dict[@"bad"],dict[@"r_id"]];
            NSLog(@"%@",sql);
            [DataBaseTool dml:sql];
        }
        
        //到这里已经将服务器上good,bad被修改过的数据同步到本地了，接下来计算本地有多少数据,在服务器上新插入的数据r_id是多少
        int num = [DataBaseTool numOfRecords];
        NSLog(@"----%d---",num);
        
        //开始给服务器的新数据更新r_id把这个数据在服务器上的r_id修改，并把这条数据插入数据库
        for (int i=0; i<[responseObject count]; i++) {
            NSDictionary *dict = [responseObject objectAtIndex:i];
            if ([dict[@"r_id"] isEqualToString:@"0"]) {
                //
                NSLog(@"%@--%@--%@",dict[@"id"],dict[@"title"],dict[@"content"]);
                // 2.封装请求参数
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                //参数为空，直接请求数据
                AFHTTPRequestOperationManager *manage = [AFHTTPRequestOperationManager manager];
                manage.responseSerializer = [AFHTTPResponseSerializer serializer];
                params[@"r_id"] = [NSString stringWithFormat:@"%d",++num];
                params[@"ID"] = dict[@"id"];
                [manage POST:@"http://localhost/uploadR_idOfRecord.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
                    NSLog(@"%@",str);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@",[error localizedDescription]);
                }];
                
                NSString *sql = [NSString stringWithFormat:@"insert into record (title,content,good,bad,changed) values ('%@','%@',%@,%@,%d)",dict[@"title"],dict[@"content"],dict[@"good"],dict[@"bad"],0];
                [DataBaseTool dml:sql];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    
    //将数据库中的回复删光，以便存入新的回复数据
    [DataBaseTool clearReply];
    //讲服务器的评论数据下载到本地
    AFHTTPRequestOperationManager *manage = [AFHTTPRequestOperationManager manager];
    manage.responseSerializer = [AFJSONResponseSerializer serializer];
    // 2.封装请求参数
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"u_id"] = [NSString stringWithFormat:@"%ld",(long)ID];
    [manage POST:@"http://localhost/getReply.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (NSDictionary *dict  in responseObject) {
//            Reply *reply = [[Reply alloc] init];
//            reply.ID = [dict[@"id"] intValue];
//            reply.u_id = [dict[@"u_id"] intValue];
//            reply.r_id = [dict[@"r_id"] intValue];
//            reply.content = dict[@"reply"];
            NSString *sql1 = [NSString stringWithFormat:@"insert into reply (r_id,record_id,u_id,content) values (%d,%d,%d,'%@');",[dict[@"r_id"] intValue],[dict[@"record_id"] intValue],[dict[@"u_id"] intValue],dict[@"reply"]];
            NSLog(@"%@",sql1);
            [DataBaseTool dml:sql1];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

-(void)logOut{
    //退出登录
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"ID"];
    [defaults setObject:@"" forKey:@"name"];
    [defaults setObject:@"" forKey:@"password"];
    [self viewDidAppear:YES];
}
@end
