
#import "RJMediaPlayerControl.h"
#import <MediaPlayer/MediaPlayer.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "RJMediaForwardView.h"
//#import "Utilities.h"
#import "LightView.h"

#define LOGO_W  60 // logo宽度

CGFloat const gestureMinimumTranslation = 20.0 ;

typedef enum : NSInteger {
    kCameraMoveDirectionNone,
    kCameraMoveDirectionUp,
    kCameraMoveDirectionDown,
    kCameraMoveDirectionRight,
    kCameraMoveDirectionLeft
} CameraMoveDirection ;

@interface RJMediaPlayerControl() {
    CameraMoveDirection direction;// panGesture方向
    CGPoint location; // 记录panGesture的开始位置
    UILabel *vedioTitleLabel;
    UIProgressView *cacheProgressView;// 视频缓冲进度
    UISlider *vedioProgressSlider;// 视频进度条
    UIButton *playBtn;// 播放、暂停button
    RJMediaForwardView *forwardView;//快进、快退View
    UIButton *backBtn; //
    UILabel *currentPlayTime; // 当前播放时间label
    UILabel *totalPlayTime;// 总时长lable
    UISlider *volumeSlider;// 音量进度
    UIButton *volumeBtn;// 音量button
    CGFloat volum;//当前音量
    CGFloat brightness;//当前屏幕亮度
    
    UIView *indicatorView;
    UIActivityIndicatorView *activityIndicatorView;
    
    BOOL isVedioSliderBeginDragged;// 视频进度条是否在拖动
    
}
@end

@implementation RJMediaPlayerControl
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.overlayPanel = [[UIControl alloc] initWithFrame:self.bounds];
    self.overlayPanel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.overlayPanel];
    self.overlayPanel.hidden = YES;
    [self setupTopPanel];
    [self setupBottomPanel];
    [self setupIndicatorView];
    [self setupForwardShowView];
    
    UITapGestureRecognizer *showTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAndFade)];
    [self addGestureRecognizer:showTap];
    UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.overlayPanel addGestureRecognizer:hideTap];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void)showAndFade {
    [self show];
    [self performSelector:@selector(hide) withObject:nil afterDelay:6];
}

- (void)show {
    self.overlayPanel.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self cancelDelayedHide];
    [self refreshVedioControl];
}

- (void)hide {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.overlayPanel.hidden = YES;
    [self cancelDelayedHide];
}

- (void)updateVolume:(CGFloat)changeVolume {
    volumeSlider.value = changeVolume;
    if (changeVolume == 0) {
        volumeBtn.selected = YES;
    } else {
        volumeBtn.selected = NO;
    }
}

- (void)cancelDelayedHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
}
- (void)cancelRefresh {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
}

- (void)startActivity {
    if (indicatorView.hidden) {
        indicatorView.hidden = NO;
        [activityIndicatorView startAnimating];
    }
}

- (void)stopActivity {
    if (!indicatorView.hidden) {
        indicatorView.hidden = YES;
        [activityIndicatorView stopAnimating];
    }
}

/** 滑动手势Action （调节亮度、音量，快进、快退）*/
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        direction = kCameraMoveDirectionNone;
        location = [gesture locationInView:self];
        volum = [MPMusicPlayerController applicationMusicPlayer].volume;
        brightness = [UIScreen mainScreen].brightness;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (direction == kCameraMoveDirectionNone) {
            direction = [self determineCameraDirectionIfNeeded:translation];
        }
        switch (direction) {
            case kCameraMoveDirectionUp:
            case kCameraMoveDirectionDown://音量，屏幕亮度调节
                if (location.x > self.frame.size.width/2.0) {
                    NSInteger num = translation.y/40;
                    CGFloat downVolum = num/10.0f;
                    CGFloat nowVolum = volum-downVolum > 0 ? volum-downVolum : 0;
                    [MPMusicPlayerController applicationMusicPlayer].volume = nowVolum;
                    volumeBtn.selected = NO;
                } else {
                    NSInteger num = translation.y/40;
                    CGFloat downVolum = num/10.0f;
                    float value = brightness-downVolum;
                    [[LightView sharedInstance] lightChange:value];
                    [[UIScreen mainScreen] setBrightness:value];
                }
                break ;
            case kCameraMoveDirectionRight:// 快进
            case kCameraMoveDirectionLeft: {
                isVedioSliderBeginDragged = YES;
                
                CGFloat forwardSeconds = translation.x/self.frame.size.width * 30.0f;
                NSTimeInterval curPlayTime = self.delegatePlayer.currentPlaybackTime;
                [forwardView showTime:curPlayTime + forwardSeconds totalDuration:self.delegatePlayer.duration];
                
            }
                break ;
            default :
                break ;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [[LightView sharedInstance] autoHiden];
        // now tell the camera to stop
        if (isVedioSliderBeginDragged) {
            isVedioSliderBeginDragged = NO;
            CGFloat forwardSeconds = translation.x/self.frame.size.width * 30.0f;// 快进时间
            vedioProgressSlider.value += forwardSeconds;
            self.delegatePlayer.currentPlaybackTime = vedioProgressSlider.value;
            forwardView.hidden = YES;
            [self refreshVedioControl];
        }
    }
}
/** 判断滑动手势方向 */
- (CameraMoveDirection )determineCameraDirectionIfNeeded:(CGPoint)translation {
    if (direction != kCameraMoveDirectionNone)
        return direction;
    
    if (fabs(translation.x) > gestureMinimumTranslation) {
        BOOL gestureHorizontal = NO;
        if (translation.y == 0.0 )
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0 );
        if (gestureHorizontal) {
            if (translation.x > 0.0 )
                return kCameraMoveDirectionRight;
            else
                return kCameraMoveDirectionLeft;
        }
    }
    else if (fabs(translation.y) > gestureMinimumTranslation) {
        BOOL gestureVertical = NO;
        if (translation.x == 0.0 )
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0 );
        if (gestureVertical) {
            if (translation.y > 0.0 )
                return kCameraMoveDirectionDown;
            else
                return kCameraMoveDirectionUp;
        }
    }
    return direction;
}

/** navigationControl */
- (void)setupTopPanel {
    self.topPanel = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
    self.topPanel.userInteractionEnabled = YES;
    self.topPanel.image = [UIImage imageNamed:@"fj_play_navbg"];
    [self.overlayPanel addSubview:self.topPanel];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 24, 80, 35);
    [backBtn setImage:[UIImage imageNamed:@"fj_back"] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.topPanel addSubview:backBtn];
    
    vedioTitleLabel = [UILabel labelWithFrame:CGRectMake(90, 20, self.frame.size.width - 180, 44) textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16] textAlignment:NSTextAlignmentCenter text:self.vedioTitle];
    [self.topPanel addSubview:vedioTitleLabel];
    
}

- (void)back:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(popViewController)]) {
        [self.delegate popViewController];
    }
}

/** 下部的控制视图 */
- (void)setupBottomPanel {
    self.bottomPanel = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-80, self.frame.size.width, 80)];
    self.bottomPanel.userInteractionEnabled = YES;
    self.bottomPanel.image = [UIImage imageNamed:@"fj_play_bottombg"];
    [self.overlayPanel addSubview:self.bottomPanel];
    [self.bottomPanel addGestureRecognizer:[[UITapGestureRecognizer alloc] init]];
    
    cacheProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    cacheProgressView.frame = CGRectMake(12, 14.6, self.frame.size.width-22, 1.0);
    cacheProgressView.transform = CGAffineTransformMakeScale(1.0, 0.8);
    cacheProgressView.trackTintColor = [UIColor blackColor];//[UIColor colorWithRed:87/255.0f green:89/255.0f blue:90/255.0f alpha:1.0f];
    cacheProgressView.progressTintColor = [UIColor colorWithRed:57/255.0f green:57/255.0f blue:57/255.0f alpha:1.0f];
    [self.bottomPanel addSubview:cacheProgressView];
    
    vedioProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width-20, 10)];
    vedioProgressSlider.backgroundColor = [UIColor clearColor];
    [vedioProgressSlider setMinimumTrackImage:[UIImage imageNamed:@"fj_play_progress_min"] forState:UIControlStateNormal];
    [vedioProgressSlider setMaximumTrackImage:[UIImage imageNamed:@"fj_play_null"] forState:UIControlStateNormal];
    [vedioProgressSlider setThumbImage:[UIImage imageNamed:@"fj_play_progress_thumb"] forState:UIControlStateNormal];
    [vedioProgressSlider setThumbImage:[UIImage imageNamed:@"fj_play_progress_thumb"] forState:UIControlStateHighlighted];
    [self.bottomPanel addSubview:vedioProgressSlider];
    [vedioProgressSlider setValue:0.0];
    UITapGestureRecognizer *vedioProgressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vedioProgressSliderTapped:)];
    [vedioProgressSlider addGestureRecognizer:vedioProgressTap];
    [vedioProgressSlider addTarget:self action:@selector(changePlayerProgress:) forControlEvents:UIControlEventValueChanged];
    [vedioProgressSlider addTarget:self action:@selector(progressSliderDownAction:) forControlEvents:UIControlEventTouchDown];
    [vedioProgressSlider addTarget:self action:@selector(progressSliderUpInSideAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [vedioProgressSlider addTarget:self action:@selector(progressSliderUpCancelAction:) forControlEvents:UIControlEventTouchCancel];
    
    playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(30, 30, 50, 50);
    [playBtn setBackgroundImage:[UIImage imageNamed:@"fj_play_playbtn"] forState:UIControlStateNormal];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"fj_play_pausebtn"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomPanel addSubview:playBtn];
    
    currentPlayTime = [UILabel labelWithFrame:CGRectMake(100, 34, 53, 40) textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:13] textAlignment:NSTextAlignmentCenter text:@"--:--:--"];
    currentPlayTime.backgroundColor = [UIColor clearColor];
    currentPlayTime.adjustsFontSizeToFitWidth = YES;
    [self.bottomPanel addSubview:currentPlayTime];
    
    UIView *tmpLine = [[UIView alloc] initWithFrame:CGRectMake(156, 47, 1, 13)];
    tmpLine.backgroundColor = [UIColor grayColor];
    [self.bottomPanel addSubview:tmpLine];
    
    totalPlayTime = [UILabel labelWithFrame:CGRectMake(160, 34, 53, 40) textColor:[UIColor lightGrayColor] font:[UIFont systemFontOfSize:13] textAlignment:NSTextAlignmentCenter text:@"--:--:--"];
    totalPlayTime.adjustsFontSizeToFitWidth = YES;
    [self.bottomPanel addSubview:totalPlayTime];
    
    volumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeBtn.frame = CGRectMake(self.frame.size.width - 200, 38, 30, 30);
    [volumeBtn setImage:[UIImage imageNamed:@"fj_play_volume"] forState:UIControlStateNormal];
    [volumeBtn setImage:[UIImage imageNamed:@"fj_play_volume_none"] forState:UIControlStateSelected];
    [volumeBtn addTarget:self action:@selector(clickVolumeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomPanel addSubview:volumeBtn];
    
    volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(self.frame.size.width - 180, 37, 160, 30)];
    [volumeSlider setMinimumTrackTintColor:[UIColor orangeColor]];
    [volumeSlider setMaximumTrackTintColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.7]];
    [volumeSlider setValue:[MPMusicPlayerController applicationMusicPlayer].volume];
    [volumeSlider setMinimumTrackImage:[[UIImage imageNamed:@"fj_play_volume_min"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:[[UIImage imageNamed:@"fj_play_volume_max"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    CGAffineTransform transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    volumeSlider.transform = transform;
    [volumeSlider addTarget:self action:@selector(changePlayerVolume:) forControlEvents:UIControlEventValueChanged];
    [self.bottomPanel addSubview:volumeSlider];
    
}

/**
 waitting
 */
- (void)setupIndicatorView {
    indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    indicatorView.center = CGPointMake(self.width/2.0f, self.height/2.f);
    [self addSubview:indicatorView];
    indicatorView.backgroundColor = [UIColor clearColor];
    indicatorView.layer.cornerRadius = 8.0f;
    indicatorView.hidden = YES;
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = CGPointMake(indicatorView.width/2.0, indicatorView.height/2.0-20);
    [indicatorView addSubview:activityIndicatorView];
    
    UILabel *flagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, indicatorView.width, 20)];
    flagLabel.centerY = indicatorView.height/2.0 + 20;
    [indicatorView addSubview:flagLabel];
    flagLabel.textAlignment = NSTextAlignmentCenter;
    flagLabel.textColor = [UIColor whiteColor];
    flagLabel.font = [UIFont systemFontOfSize:14];
    flagLabel.text = @"正在加载~";
}

/** 快进、快退展示的view */
- (void)setupForwardShowView {
    forwardView = [RJMediaForwardView sharedInstance];
    [self addSubview:forwardView];
}

/** 播放button action */
- (void)play:(UIButton *)button {
    button.selected = !button.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaControl:changePlayState:)]) {
        [self.delegate mediaControl:self changePlayState:button.selected];
    }
}


/**
 时间条设置播放时间

 */
- (void)vedioProgressSliderTapped:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:vedioProgressSlider];
    vedioProgressSlider.value = point.x/vedioProgressSlider.width * vedioProgressSlider.maximumValue;
    self.delegatePlayer.currentPlaybackTime = vedioProgressSlider.value;
    [self showAndFade];
}

- (void)changePlayerProgress:(UISlider *)slider {
    [self refreshVedioControl];
}

- (void)progressSliderDownAction:(UISlider *)slider {
    isVedioSliderBeginDragged = YES;
    [self show];
}

- (void)progressSliderUpInSideAction:(UISlider *)slider {
    isVedioSliderBeginDragged = NO;
    self.delegatePlayer.currentPlaybackTime = vedioProgressSlider.value;
    [self showAndFade];
}
- (void)progressSliderUpCancelAction:(UISlider *)slider {
    isVedioSliderBeginDragged = NO;
    self.delegatePlayer.currentPlaybackTime = vedioProgressSlider.value;
    [self showAndFade];
}


- (void)changePlayerVolume:(UISlider *)slider {
    [MPMusicPlayerController applicationMusicPlayer].volume = volumeSlider.value;
    volumeBtn.selected = NO;
    if (slider.value == 0) {
        volumeBtn.selected = YES;
    }
}

/**
 *  设置静音
 */
- (void)clickVolumeBtn:(UIButton *)button {
    button.selected = !button.selected;
    MPMusicPlayerController * mpc = [MPMusicPlayerController applicationMusicPlayer];
    if (button.selected) {
        volum = mpc.volume;
        mpc.volume = 0;
        volumeSlider.value = 0;
    } else {
        mpc.volume = volum;
        volumeSlider.value = volum;
    }
    
}

-(NSString *)timeIntervalToHumanString:(NSTimeInterval)timeInterval {
    unsigned long seconds, h, m, s;
    char buff[128] = { 0 };
    NSString *nsRet = nil;
    seconds = (unsigned long)timeInterval+0.5;
    h = seconds / 3600;
    m = (seconds - h * 3600) / 60;
    s = seconds - h * 3600 - m * 60;
    snprintf(buff, sizeof(buff), "%02ld:%02ld:%02ld", h, m, s);
    nsRet = [[NSString alloc] initWithCString:buff
                                      encoding:NSUTF8StringEncoding];
    
    return nsRet;
}

- (void)refreshVedioControl {
    NSTimeInterval vedioDuration = self.delegatePlayer.duration;
    long totalTime = vedioDuration;
    NSTimeInterval canPlayTime = self.delegatePlayer.playableDuration;
    if (totalTime > 0) {// 总时长
        vedioProgressSlider.maximumValue = totalTime;
        totalPlayTime.text = [self timeIntervalToHumanString:vedioDuration];
        cacheProgressView.progress = canPlayTime/vedioDuration;
        if (self.isOffline) {
            cacheProgressView.progress = 1.0f;
        }
        
    } else {
        vedioProgressSlider.maximumValue = 1;
        totalPlayTime.text = @"--:--:--";
        cacheProgressView.progress = 0;
    }
    
    // position
    NSTimeInterval position;
    if (isVedioSliderBeginDragged) {
        position = vedioProgressSlider.value;
    } else {
        position = self.delegatePlayer.currentPlaybackTime;
    }
    
    if (totalTime > 0) {
        vedioProgressSlider.value = position;
    } else {
        vedioProgressSlider.value = 0.0f;
    }
    currentPlayTime.text = [self timeIntervalToHumanString:position];//[NSString stringWithFormat:@"%02d:%02d:%02d", (int)(intPosition / 3600),(int)((intPosition % 3600) / 60), (int)(intPosition % 60)];
    
    
    // status
    BOOL isPlaying = [self.delegatePlayer isPlaying];
    playBtn.selected = isPlaying;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshVedioControl) object:nil];
    if (!self.overlayPanel.hidden) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshVedioControl];
        });
        //        [self performSelector:@selector(refreshVedioControl) withObject:nil afterDelay:0.8];
    }
}

#pragma mark setter
- (void)setVedioTitle:(NSString *)vedioTitle {
    _vedioTitle = vedioTitle;
    vedioTitleLabel.text = vedioTitle;
    
}

@end
