//
//  UIImage+Resize.h
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/23.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)
+ (UIImage *)resizedImageWithName:(NSString *)name;

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;
@end
