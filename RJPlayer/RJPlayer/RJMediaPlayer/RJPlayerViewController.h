/** 
 * 播放器
 */

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@class RJMediaPlayerControl;

@protocol RJMediaPlayerDelegate <NSObject>

- (void) autoPlayOffline;
@end

@interface RJPlayerViewController : UIViewController
@property(atomic,strong) NSURL *url;
@property (nonatomic, assign) id<RJMediaPlayerDelegate> delegate;
@property(atomic, retain) id<IJKMediaPlayback> player;
@property(nonatomic,strong) RJMediaPlayerControl *mediaControl;// 播放时的工具条
@property (nonatomic, copy) NSString *videoTitle;
@property (nonatomic,copy) NSString *type;
@property (nonatomic , assign) BOOL isBack;
@property (nonatomic , assign) BOOL isOffline;
@property (nonatomic , assign) BOOL isError;

- (id)initWithURL:(NSURL *)url;

@end
