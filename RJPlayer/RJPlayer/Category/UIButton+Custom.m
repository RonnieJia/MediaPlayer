//
//  UIButton+Custom.m
//  APPFormwork
//
//  Created by 辉贾 on 2016/10/31.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)
+ (UIButton *)sureButtonWithTitle:(NSString *)title {
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(35, 0, KSCREEN_W-70, 45);
    sureBtn.layer.cornerRadius = 4.0f;
    sureBtn.layer.masksToBounds = YES;
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn setTitle:title forState:UIControlStateNormal];
    
    return sureBtn;
}


+ (UIButton *)buttonWithFrame:(CGRect)frame image:(UIImage *)image target:(id)target action:(SEL)action {
    UIButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    if (image) {
        [button setImage:image forState:UIControlStateNormal];
    }
    if (target) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

+ (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)color target:(id)target action:(SEL)action {
    UIButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
