# SYQRCodeDemo

SYQRCode:IOS原生API，需要IOS7.0及以上系统支持。简单易用，使用block做回调处理。

用法：
    
    SYQRCodeViewController *aaa = [[SYQRCodeViewController alloc] init];
    aaa.SYQRCodeSuncessBlock = ^(NSString *qrString){
        
        self.saomiaoLabel.text = qrString;
    
    };
    
    aaa.SYQRCodeCancleBlock = ^(SYQRCodeViewController *are){
    
        self.saomiaoLabel.text = @"扫描取消~";
        [are dismissViewControllerAnimated:YES completion:nil];
    
    };
    [self presentViewController:aaa animated:YES completion:nil];

