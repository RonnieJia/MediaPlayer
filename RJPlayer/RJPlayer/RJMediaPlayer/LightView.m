//
//  LightView.m
//  ableSkyLinYangXie
//
//  Created by 辉贾 on 2016/11/1.
//  Copyright © 2016年 ablesky. All rights reserved.
//

#import "LightView.h"

@interface LightView ()
@property (nonatomic, strong)NSMutableArray *lightViewArray;
@end

@implementation LightView
+ (instancetype)sharedInstance {
    static LightView *sharedInsatance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInsatance = [[self alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
    });
    return sharedInsatance;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.center = CGPointMake(KSCREEN_W/2.0, KSCREEN_H/2.0);
    
    UIImageView *lightImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    lightImgView.image = [UIImage imageNamed:@"bright_bg"];
    [self addSubview:lightImgView];
    
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(10, self.height - 20, self.width-20, 6)];
    progressView.backgroundColor = [UIColor blackColor];
    [self addSubview:progressView];
    
    CGFloat whiteViewWidth = (progressView.width - 16)/16.0;
    for (int i = 0; i<16; i++) {
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0.5+(whiteViewWidth + 1)*i, 0.5, whiteViewWidth, progressView.height-1)];
        [self.lightViewArray addObject:whiteView];
        whiteView.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:0.85];
        [progressView addSubview:whiteView];
    }
    self.hidden = YES;
    [self lightChange:[UIScreen mainScreen].brightness];
    [KKEYWINDOW addSubview:self];
}

- (void)lightChange:(CGFloat)num {
    [self lightShow];
    int value = (int)(num * 16.0);
    if (num < 0.05) {
        value = 0;
    }
    [self.lightViewArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *lightView = obj;
        if (value == 0) {
            lightView.hidden = YES;
        } else {
            if (idx <= value) {
                lightView.hidden = NO;
            } else {
                lightView.hidden = YES;
            }
        }
    }];
    
}

- (void)lightShow {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiden) object:nil];
    self.hidden = NO;
}

- (void)autoHiden {
    [self performSelector:@selector(hiden) withObject:nil afterDelay:1.0];
}

- (void)hiden {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
}


- (NSMutableArray *)lightViewArray {
    if (!_lightViewArray) {
        _lightViewArray = [NSMutableArray array];
    }
    return _lightViewArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
