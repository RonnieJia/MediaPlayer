//
//  LiveTableView.h
//  RJPlayer
//
//  Created by jia on 2017/3/3.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveModel;

typedef void(^SelectRow)(LiveModel *model);

@interface LiveTableView : UITableView
@property(nonatomic, copy)SelectRow selectBlock;
@end
