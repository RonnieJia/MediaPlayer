//
//  LiveModel.h
//  RJPlayer
//
//  Created by jia on 2017/3/3.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveModel : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *desc;

+ (instancetype)modelWithJSONDict:(NSDictionary *)dict;
+ (NSArray *)liveListWithJSONArr:(NSArray *)arr;
@end
