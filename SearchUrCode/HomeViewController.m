//
//  HomeViewController.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/23.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "HomeViewController.h"
#import "Record.h"
#import "RecordFrame.h"
#import "RecordCell.h"
#import "DataBaseTool.h"
#import "RecordDetailViewController.h"
#import "AFNetworking.h"
#import "DetailViewController.h"
#import "UIImage+Resize.h"

@interface HomeViewController ()<UISearchBarDelegate,UIAlertViewDelegate>
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *recordsFrame;
@property (nonatomic,copy) NSString *keyword;
@property (nonatomic,copy) UIView *askView;
@end

@implementation HomeViewController

-(void)viewDidLoad{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //添加一个searchBar
    [self addSearchBar];
    NSArray *records = [DataBaseTool records];
    NSMutableArray *recordsFrame = [NSMutableArray array];
    for (Record *record in records) {
        RecordFrame *recordFrame = [[RecordFrame alloc] init];
        recordFrame.record = record;
        [recordsFrame addObject:recordFrame];
    }
    self.recordsFrame = recordsFrame;
    [self.tableView reloadData];
    _askView = nil;
    _askView = [[UIView alloc] initWithFrame:CGRectMake(320, 180, 100, 50)];
    _askView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_askView];
}


-(void)viewDidAppear:(BOOL)animated{
    NSArray *records = [DataBaseTool records];
    NSMutableArray *recordsFrame = [NSMutableArray array];
    for (Record *record in records) {
        RecordFrame *recordFrame = [[RecordFrame alloc] init];
        recordFrame.record = record;
        [recordsFrame addObject:recordFrame];
    }
    self.recordsFrame = recordsFrame;
    [self.tableView reloadData];
}

#pragma mark -添加一个searchBar
-(void)addSearchBar{
    self.title = @"haha";
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    _searchBar = searchBar;
    self.tableView.tableHeaderView = searchBar;
}

#pragma mark searchBar的代理方法
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    
    NSArray *records = [DataBaseTool recordsWithCondition:searchText];
    NSMutableArray *recordsFrame = [NSMutableArray array];
    for (Record *record in records) {
        RecordFrame *recordFrame = [[RecordFrame alloc] init];
        recordFrame.record = record;
        [recordsFrame addObject:recordFrame];
    }
    self.recordsFrame = recordsFrame;
    
    [self.tableView reloadData];
    if (self.recordsFrame.count == 0) {
        self.keyword = searchText;
        
        //从旁边弹出一个框框，询问要不要查别人的笔记
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 30)];
        lable.font = [UIFont systemFontOfSize:13];
        lable.numberOfLines = 0;
        lable.text = @"本地没有找到笔记！";
        [_askView addSubview:lable];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, 130, 30)];
        [button setTitle:@"搜索别人的笔记" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button addTarget:self action:@selector(searchRecordFromNet) forControlEvents:UIControlEventTouchUpInside];
        [_askView addSubview:button];
        
        
        [UIView animateWithDuration:0.5 animations:^{
            _askView.frame = CGRectMake(190, 180, 130, 60);
        }];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本地没有找到笔记！" message:@"要不要搜索别人的笔记？" delegate:self cancelButtonTitle:@"不要" otherButtonTitles:@"要", nil];
//        [alert show];
        
    }else {
//        _askView = nil;
        [UIView animateWithDuration:0.5 animations:^{
            _askView.frame = CGRectMake(320, 200, 0, 0);
        }];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}


#pragma mark -tableView的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _recordsFrame.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordCell *cell = [RecordCell cellWithTableView:tableView];
    cell.recordsFrame = self.recordsFrame[indexPath.row];
    return cell;
}
//页面跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordFrame *recordFrame = self.recordsFrame[indexPath.row];
    Record *record = recordFrame.record;
    NSLog(@"%d--%d--%d--%@--%@", record.ID,record.r_id,record.u_id,record.title,record.content);
    //根据id是否为0，判断是本地数据还是网络数据
    if (record.ID == 0) {
        RecordDetailViewController *vc = [[RecordDetailViewController alloc] init];
        vc.record = record;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        DetailViewController *vc = [[DetailViewController alloc] init];
        vc.record = record;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
//
//点击了查询按钮，开始从服务器查询相应的记录
-(void)searchRecordFromNet{
        NSLog(@"从服务器查询相应的笔记");
        AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
        mgr.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"keyword"] = self.keyword;
        [mgr POST:@"http://localhost/searchRecordsProcess.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSMutableArray *recordsFrameArray = [NSMutableArray array];
            for (NSDictionary *dict in responseObject) {
                Record *record = [[Record alloc] init];
                record.ID = [dict[@"id"] intValue];
                record.r_id = [dict[@"r_id"] intValue];
                record.title = dict[@"title"];
                record.content = dict[@"content"];
                record.good = [dict[@"good"] intValue];
                record.bad = [dict[@"bad"] intValue];
                RecordFrame *recordFrame = [[RecordFrame alloc] init];
                recordFrame.record = record;
                [recordsFrameArray addObject:recordFrame];
//                NSLog(@"%@--%@--%@--%@--",dict[@"id"],dict[@"r_id"],dict[@"title"],dict[@"content"]);
            }
            self.recordsFrame = nil;
            self.recordsFrame = recordsFrameArray;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
        }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecordFrame *recordFrame = self.recordsFrame[indexPath.row];
    return recordFrame.cellHeight;
}
@end
