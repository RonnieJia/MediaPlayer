/**
 *  视频播放的控制器（播放进度、音量等）
 */
#import <UIKit/UIKit.h>

@protocol RJMediaControlDelegate;
@protocol IJKMediaPlayback;

@interface RJMediaPlayerControl : UIControl
@property(nonatomic,strong) UIControl *overlayPanel;
@property(nonatomic,strong) UIImageView *topPanel;
@property(nonatomic,strong) UIImageView *bottomPanel;

@property(nonatomic,weak) id<IJKMediaPlayback> delegatePlayer;
@property (nonatomic, assign) id<RJMediaControlDelegate> delegate;

@property (nonatomic, strong) NSString *vedioTitle;// 视频名称
@property (nonatomic, assign) BOOL isOffline; // 是否离线视频

/**  刷新播放进度，以及缓冲进度等 */
- (void)refreshVedioControl;
/**  展示nav和bottom工具条，并自动隐藏 */
- (void)showAndFade;
/**  按键修改系统声音，修改自定义音量进度 */
- (void)updateVolume:(CGFloat)changeVolume;
/**  展示等待View*/
- (void)startActivity;
/**  隐藏等待View*/
- (void)stopActivity;
/**  停止刷新 */
- (void)cancelRefresh;
@end

/***control 协议***/
@protocol RJMediaControlDelegate <NSObject>
/**
 *  popViewController
 */
- (void)popViewController;
- (void)mediaControl:(RJMediaPlayerControl *)mediaControl changePlayState:(BOOL)isPlay;
@end
