
#import "RJMediaForwardView.h"

@interface RJMediaForwardView()
{
    UILabel *timeLabel;
    UIProgressView *progressView;
}
@end

@implementation RJMediaForwardView
+ (instancetype)sharedInstance {
    static RJMediaForwardView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RJMediaForwardView alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
        
        CGFloat height = KSCREEN_H > 450 ? KSCREEN_H : KSCREEN_W;
        CGFloat width = KSCREEN_W < 450 ? KSCREEN_W : KSCREEN_H;
        sharedInstance.center = CGPointMake(height/2.0, width/2.0);
        sharedInstance.hidden = YES;
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.layer.cornerRadius = 4.0f;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    timeLabel = [UILabel labelWithFrame:CGRectMake(5, 5, self.width-10, 30) textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentCenter text:nil];
    [self addSubview:timeLabel];
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(5, 40, self.width-10, 1)];
    [self addSubview:progressView];
    progressView.progressTintColor = [UIColor whiteColor];
    progressView.trackTintColor = [UIColor darkGrayColor];
    progressView.progress = 0.8;
}

- (void)showTime:(NSTimeInterval)forwardTime totalDuration:(NSTimeInterval)duration {
    self.hidden = NO;
    long long time = (long long)forwardTime;
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)(time / 3600),(int)((time % 3600) / 60), (int)(time % 60)];
    progressView.progress = forwardTime/duration;
}

@end
