//
//  UIColor+VNHex.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-12.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "UIColor+VNHex.h"
#import "Colours.h"

@implementation UIColor (VNHex)

+ (UIColor *)colorWithHex:(NSInteger)rgbHexValue {
  return [UIColor colorWithHex:rgbHexValue alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSInteger)rgbHexValue
                    alpha:(CGFloat)alpha {
  return [UIColor colorWithRed:((float)((rgbHexValue & 0xFF0000) >> 16))/255.0
                         green:((float)((rgbHexValue & 0xFF00) >> 8))/255.0
                          blue:((float)(rgbHexValue & 0xFF))/255.0
                         alpha:alpha];
}

+ (UIColor *)systemColor {
  return [UIColor colorFromHexString:@"#FE9129"];
}

+ (UIColor *)systemDarkColor {
  return [UIColor hollyGreenColor];
}

+ (UIColor *)grayBackgroudColor {
    //1 白色 0 黑色
//    return [UIColor colorWithRed:((arc4random() % 100))/255.0 green:((arc4random() % 100))/255.0 blue:((arc4random() % 100))/255.0 alpha:0.1];
    return [UIColor colorFromHexString:@"#FFB73F"];
}


@end
