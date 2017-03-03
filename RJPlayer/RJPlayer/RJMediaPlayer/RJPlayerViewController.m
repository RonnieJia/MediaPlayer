#import "RJPlayerViewController.h"
#import "RJMediaPlayerControl.h"

#define ALERT_TAG 10000
#define ALERT_WWAN_TAG 10001
#define ALERT_SETTING  10002

@interface RJPlayerViewController ()<RJMediaControlDelegate>
{
    CGRect frame;
    BOOL isHomeBack;
    int timeSlot;
    NSInteger paperId;       //保存课中测验的试卷id
    BOOL isFromExercise;
    NSTimer *mSyncSeekTimer;
    BOOL isPlayingWhenEnterBackground;// 进入后台的时候是否正在播放
    BOOL isLoad;//
    BOOL isPlaying;
    BOOL isPause;
    
    
    NSInteger studyTime;
}

@end

@implementation RJPlayerViewController
- (instancetype)initWithURL:(NSString *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

#define EXPECTED_IJKPLAYER_VERSION (1 << 16) & 0xFF) |
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    frame = self.view.bounds;
    if (frame.size.width < 480) {
        CGFloat width = frame.size.height;
        CGFloat height = frame.size.width;
        frame = CGRectMake(0, 0, width, height);
    }
//#ifdef DEBUG
//    [IJKFFMoviePlayerController setLogReport:YES];
//    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
//#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
//#endif
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:self.url withOptions:options];
    self.player.shouldAutoplay = YES;
    UIView *playerView = [self.player view];
    
    UIView *playerBackView = [[UIView alloc] initWithFrame:frame];
    playerBackView.backgroundColor = [UIColor blackColor];
    playerView.frame = playerBackView.bounds;
    [playerBackView insertSubview:playerView atIndex:1];
    [self.player setScalingMode:IJKMPMovieScalingModeAspectFit];
    
    self.mediaControl = [[RJMediaPlayerControl alloc] initWithFrame:frame isLiveShow:YES];
    self.mediaControl.delegatePlayer = self.player;
    self.mediaControl.delegate = self;
    self.mediaControl.isOffline = self.isOffline;
    self.mediaControl.vedioTitle = self.videoTitle;
    
    [self.mediaControl startActivity];
    [self.view addSubview:playerBackView];
    [self.view addSubview:self.mediaControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mediaControl showAndFade];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self installMovieNotificationObservers];
    if (![self.player isPreparedToPlay]) {
        [self.player prepareToPlay];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeMovieNotificationObservers];
}



#pragma mark - 控制旋转
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)playVideo:(BOOL)isStart {
    if (self.isOffline) {
        [self continueToPlay:isStart];
    } else {
        [self continueToPlay:isStart];
    }
}

- (void)continueToPlay:(BOOL)startPlaying {
    if (startPlaying) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

/**  从后台回到播放页 */
- (void)becomeActiviy:(NSNotification *)notify {
    if (isLoad) {
        if (isPlayingWhenEnterBackground) {
            isPlayingWhenEnterBackground = NO;
            
            if (self.isOffline) {// 离线播放
                [self continueToPlay:YES];
            } else {
                [self continueToPlay:YES];
            }
        }
    } else {
        isHomeBack = YES;
    }
}
- (void)enterBackground:(NSNotification *)notity {
    //暂停播放
    if (isLoad) {
        if ([self.player isPlaying]) {
            [self continueToPlay:NO];
            isPlayingWhenEnterBackground = YES;
        } else {
            isPlayingWhenEnterBackground = NO;
        }
    }
}


#pragma mark RJMediaControlDelegate
- (void)popViewController {
    if ([self.player isPlaying]) {
        [self.player pause];
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.mediaControl cancelRefresh];
    self.mediaControl = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }];
}

- (void)mediaControl:(RJMediaPlayerControl *)mediaControl changePlayState:(BOOL)isPlay {
    if (isPlay) {
        [self playVideo:YES];
    } else {
        [self continueToPlay:NO];
    }
}

- (void)playerPreparedToPlay {
    isLoad = YES;
    //    [self playVideo:YES];
    [self.mediaControl stopActivity];
    [self.mediaControl showAndFade];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    IJKMPMovieLoadState loadState = _player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        [self.mediaControl stopActivity];
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        [self.mediaControl startActivity];
    } else {
        //     NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:{
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            [self popViewController];
        }
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError: {
            if (self.isOffline) {
                UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                   message:@"视频组件初始化中,请重新播放!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                
                [alertView show];
                alertView.tag = ALERT_TAG;
            }else{
                UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                   message:@"视频正在准备中,请稍等!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
                alertView.tag = ALERT_TAG;
            }
            [self.mediaControl stopActivity];
        }
            break;
        default:
            //   NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    // 准备好去播放
    [self playerPreparedToPlay];
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped: {
           NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {// 开始播放之后更新时间进度
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark system volume change
- (void)updateVolume {
    [self.mediaControl updateVolume:[MPMusicPlayerController applicationMusicPlayer].volume];
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    
    [notiCenter addObserver:self
                   selector:@selector(networkStateChange:)
                       name:KNOTI_NETWORKSTATECHANGE
                     object:nil];
    
    [notiCenter addObserver:self
                   selector:@selector(becomeActiviy:)
                       name:UIApplicationDidBecomeActiveNotification
                     object:[UIApplication sharedApplication]];
    [notiCenter addObserver:self
                   selector:@selector(enterBackground:)
                       name:UIApplicationWillResignActiveNotification
                     object:[UIApplication sharedApplication]];
    [notiCenter addObserver:self
                   selector:@selector(updateVolume)
                       name:@"AVSystemController_SystemVolumeDidChangeNotification"
                     object:nil];
    [notiCenter addObserver:self
                   selector:@selector(loadStateDidChange:)
                       name:IJKMPMoviePlayerLoadStateDidChangeNotification
                     object:_player];
    
    [notiCenter addObserver:self
                   selector:@selector(moviePlayBackDidFinish:)
                       name:IJKMPMoviePlayerPlaybackDidFinishNotification
                     object:_player];
    
    [notiCenter addObserver:self
                   selector:@selector(mediaIsPreparedToPlayDidChange:)
                       name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                     object:_player];
    
    [notiCenter addObserver:self
                   selector:@selector(moviePlayBackStateDidChange:)
                       name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                     object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
