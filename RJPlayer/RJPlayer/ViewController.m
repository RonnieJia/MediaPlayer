//
//  ViewController.m
//  RJPlayer
//
//  Created by jia on 2017/3/2.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "ViewController.h"
#import "RJPlayerViewController.h"
#import "LiveTableView.h"
#import "LiveModel.h"

@interface ViewController ()
@property(nonatomic, weak)UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self makeTitleView];
    [self createMinView];
    
}

- (void)createMinView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, KSCREEN_W, KSCREEN_H-64)];
    [self.view addSubview:scrollView];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView = scrollView;
    scrollView.contentSize = CGSizeMake(self.view.width * 2, 1);
    
    LiveTableView *liveView = [[LiveTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, scrollView.height)];
    [scrollView addSubview:liveView];
    __weak typeof(self)weakSelf = self;
    liveView.selectBlock = ^(LiveModel *model){
        [weakSelf presentToPlayer:YES live:model];
    };
}

- (void)makeTitleView {
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"直播",@"视频"]];
    segment.frame = CGRectMake(0, 0, 160, 30);
    segment.tintColor = [UIColor colorWithRed:0.19f green:0.45f blue:0.82f alpha:1.00f];
    self.navigationItem.titleView = segment;
    segment.selectedSegmentIndex = 0;
    NSDictionary *normal = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    [segment setTitleTextAttributes:normal forState:UIControlStateNormal];
    [segment addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventValueChanged];
}

- (void)changeList:(UISegmentedControl *)segment {
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (segment.selectedSegmentIndex == 0) {
        if (offsetX != 0) {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    } else {
        if (offsetX != self.view.width) {
            [self.scrollView setContentOffset:CGPointMake(self.view.width, 0) animated:YES];
        }
    }
}

- (void)presentToPlayer:(BOOL)isLive live:(LiveModel *)live {
    RJPlayerViewController *player = [[RJPlayerViewController alloc] initWithURL:live.videoUrl];
    player.videoTitle = live.title;
    
    [self presentViewController:player animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
