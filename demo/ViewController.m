//
//  ViewController.m
//  demo
//
//  Created by leiyinchun on 2020/5/6.
//  Copyright © 2020 leiyinchun. All rights reserved.
//

#import "ViewController.h"
#import "WkViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  self.view.backgroundColor = [UIColor whiteColor];
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, 69, 30);
  [button setTitle:@"点击" forState:UIControlStateNormal];
  [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  button.center = self.view.center;
  [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
}


- (void)buttonClicked {
  NSString *str = @"https://www.163.com";
  WkViewController *webVC = [WkViewController new];
  webVC.urlStr = str;
  [self.navigationController pushViewController:webVC animated:YES];
}

@end
