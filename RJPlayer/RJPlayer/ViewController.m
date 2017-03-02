//
//  ViewController.m
//  RJPlayer
//
//  Created by jia on 2017/3/2.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "ViewController.h"
#import "RJPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    RJPlayerViewController *player = [RJPlayerViewController new];
    [self presentViewController:player animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
