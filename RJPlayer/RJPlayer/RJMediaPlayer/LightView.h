//
//  LightView.h
//  ableSkyLinYangXie
//
//  Created by 辉贾 on 2016/11/1.
//  Copyright © 2016年 ablesky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightView : UIView
+ (instancetype)sharedInstance;
- (void)lightChange:(CGFloat)num;
- (void)autoHiden;
@end
