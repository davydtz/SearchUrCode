//
//  NavigationController.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/23.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "NavigationController.h"
#import "UIImage+Resize.h"

@implementation NavigationController

+(void)initialize{
    
    [self setupNavBarTheme];
}

+(void)setupNavBarTheme{
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setBackgroundImage:[UIImage resizedImageWithName:@"navigation"] forBarMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor blueColor];
    textAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:19];
    
    [navBar setTitleTextAttributes:textAttrs];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}
@end
