# SYQRCodeDemo

SYQRCode:IOS原生API，需要IOS7.0及以上系统支持。简单易用，使用block做回调处理。

用法：
    
    SYQRCodeViewController *syqrc = [[SYQRCodeViewController alloc] init];
    syqrc.SYQRCodeSuncessBlock = ^(NSString *qrString){
        
        self.saomiaoLabel.text = qrString;
    
    };
    
    syqrc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrc){
    
        self.saomiaoLabel.text = @"扫描取消~";
        [aqrc dismissViewControllerAnimated:YES completion:nil];
    
    };
    [self presentViewController:syqrc animated:YES completion:nil];

