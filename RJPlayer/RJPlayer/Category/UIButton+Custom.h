//
//  UIButton+Custom.h
//  APPFormwork
//
//  Created by 辉贾 on 2016/10/31.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Custom)
+ (UIButton *)sureButtonWithTitle:(NSString *)title;
+ (UIButton *)buttonWithFrame:(CGRect)frame image:(UIImage *)image target:(id)target action:(SEL)action;
+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action;
@end
