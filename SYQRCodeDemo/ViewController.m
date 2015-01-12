//
//  ViewController.m
//  SYQRCodeDemo
//
//  Created by sunbb on 15-1-6.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import "ViewController.h"
#import "SYQRCodeViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//打开摄像头并扫描
- (IBAction)saomiaoAction:(id)sender
{
    //扫描二维码
    SYQRCodeViewController *aaa = [[SYQRCodeViewController alloc] init];
    aaa.SYQRCodeSuncessBlock = ^(NSString *qrString){
        
        self.saomiaoLabel.text = qrString;
    
    };
    
    aaa.SYQRCodeCancleBlock = ^(SYQRCodeViewController *are){
    
        self.saomiaoLabel.text = @"扫描取消~";
        [are dismissViewControllerAnimated:YES completion:nil];
    
    };
    [self presentViewController:aaa animated:YES completion:nil];
}

@end
