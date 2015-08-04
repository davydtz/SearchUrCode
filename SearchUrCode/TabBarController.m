//
//  TabBarController.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/13.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "TabBarController.h"
#import "TabBarButton.h"
#import "TabBar.h"


@interface TabBarController ()
@property (nonatomic, strong) TabBarButton *buttonSel;
@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.tabBar.subviews removeFromSuperview];
    // 删除系统自动生成的UITabBarButton


    TabBar *tabBar = [[TabBar alloc] init];
    tabBar.frame = self.tabBar.bounds;
    
    [self.tabBar addSubview:tabBar];
    
    
    for (int i=0; i<3; i++) {
        //添加3个button
        TabBarButton *button = [[TabBarButton alloc] init];
        //设置按钮的图片
        NSString *name = [NSString stringWithFormat:@"%d.png",i+1];
        [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        
        CGFloat h = tabBar.frame.size.height-15;
        CGFloat w = h;
        CGFloat margin = (tabBar.frame.size.width - 3*h)/4;
        CGFloat x = margin + i*(h + margin);
        CGFloat y = 5;
        
        //设置按钮的大小
        button.frame = CGRectMake(x, y, w, h);
        [tabBar addSubview:button];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}
-(void)buttonClick:(TabBarButton *)button{
    self.selectedIndex = button.tag;
}

@end
