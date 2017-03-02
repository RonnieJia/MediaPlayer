//
//  UILabel+Custom.h
//  APPFormwork
//
//  Created by 辉贾 on 2016/10/31.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Custom)
/** 默认NSTextAlignmentLeft */
+(UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font text:(NSString *)text;
/** 快速创建 */
+ (UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font textAlignment:(NSTextAlignment)alignment text:(NSString *)text;
@end
