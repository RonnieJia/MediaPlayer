//
//  LiveTableView.m
//  RJPlayer
//
//  Created by jia on 2017/3/3.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "LiveTableView.h"
#import "LiveModel.h"

@interface LiveTableView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSArray *dataArray;
@end

@implementation LiveTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.tableFooterView = [UIView new];
    }
    return self;
}

#pragma mark - tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"liveCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    LiveModel *live = self.dataArray[indexPath.row];
    cell.textLabel.text = live.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectBlock(self.dataArray[indexPath.row]);
}

#pragma mark - Lazy
- (NSArray *)dataArray {
    if (!_dataArray) {
        NSArray *plistArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LiveList.plist" ofType:nil]];
        _dataArray = [LiveModel liveListWithJSONArr:plistArr];
    }
    return _dataArray;
}

@end
