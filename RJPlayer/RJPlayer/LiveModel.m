//
//  LiveModel.m
//  RJPlayer
//
//  Created by jia on 2017/3/3.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "LiveModel.h"

@implementation LiveModel
+ (instancetype)modelWithJSONDict:(NSDictionary *)dict {
    LiveModel *model = [[LiveModel alloc] init];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        model.title = StringForKeyInUnserializedJSONDic(dict, @"title");
        model.videoUrl = StringForKeyInUnserializedJSONDic(dict, @"url");
        model.icon = StringForKeyInUnserializedJSONDic(dict, @"icon");
        model.desc = StringForKeyInUnserializedJSONDic(dict, @"desc");
    }
    return model;
}

+ (NSArray *)liveListWithJSONArr:(NSArray *)arr {
    NSMutableArray *mArr = [NSMutableArray array];
    if (arr && [arr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in arr) {
            [mArr addObject:[LiveModel modelWithJSONDict:dict]];
        }
    }
    return mArr;
}

@end
