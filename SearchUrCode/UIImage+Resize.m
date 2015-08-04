//
//  UIImage+Resize.m
//  SearchUrCode
//
//  Created by 戴伟 on 15/7/23.
//  Copyright (c) 2015年 戴伟. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)
+ (UIImage *)resizedImageWithName:(NSString *)name
{
    return [self resizedImageWithName:name left:0.5 top:0.5];
}

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [self imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * left topCapHeight:image.size.height * top];
}
@end
