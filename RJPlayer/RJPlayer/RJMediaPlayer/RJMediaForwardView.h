/**
 *  快进、快退时展示的view
 */
#import <UIKit/UIKit.h>

@interface RJMediaForwardView : UIView
+ (instancetype)sharedInstance;
/** 显示快进进度
 *  @param forwardTime 快进到的播放时间
 *  @param duration    总时长 */
- (void)showTime:(NSTimeInterval)forwardTime totalDuration:(NSTimeInterval)duration;
@end
