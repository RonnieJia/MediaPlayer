//
//  UILabel+Custom.m
//  APPFormwork
//
//  Created by 辉贾 on 2016/10/31.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "UILabel+Custom.h"

@implementation UILabel (Custom)

+(UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font text:(NSString *)text {
    return [self labelWithFrame:frame textColor:textColor font:font textAlignment:NSTextAlignmentLeft text:text];
}
+ (UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font textAlignment:(NSTextAlignment)alignment text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (textColor) {
        label.textColor = textColor;
    } else {
        label.textColor = [UIColor blackColor];
    }
    if (font) {
        label.font = font;
    } else {
        label.font = [UIFont systemFontOfSize:16];
    }
    label.textAlignment = alignment;
    if (text && text.length > 0) {
        label.text = text;
    }
    return label;
}
@end
