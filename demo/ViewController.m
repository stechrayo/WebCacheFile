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


- (void)buttonClicked{
  
  NSString *str = @"https://test.ss-clouddoctor.com/user/app/home?selectedTab=1&userNo=us2016571938588510&userHead=https%3A%2F%2Fstatic.ss-clouddoctor.com%2Fdata%2F20200331%2Fd5ad0d7b6b124213a3e35c9f7c0d3281.jpg&userName=213123213&nickName=189****4937&userSex=0&rongToken=6xfZVY468coswXSR6mqAuOwe36MbP6npFAfgERPRK8n5Hs7bJQ41cg%3D%3D%40ui05.cn.rongnav.com%3Bui05.cn.rongcfg.com&sysToken=6xfZVY468coswXSR6mqAuOwe36MbP6npFA&permissions=1&pmsName=%E6%82%A3%E8%80%85&platformType=wechat&phoneNo=18980914937&certification=1&appVersion=8.8.8";
  
  
    WkViewController *webVC = [WkViewController new];
    webVC.urlStr = str;
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
