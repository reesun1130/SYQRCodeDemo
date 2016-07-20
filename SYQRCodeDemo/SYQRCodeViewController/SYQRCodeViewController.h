//
//  SYQRCodeViewController.h
//  SYQRCodeDemo
//
//  Created by sunbb on 15-1-9.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYQRCodeViewController : UIViewController

/**SYQRCodeCancleBlock */
@property (nonatomic, copy) void (^SYQRCodeCancleBlock) (SYQRCodeViewController *);

/**SYQRCodeSuncessBlock */
@property (nonatomic, copy) void (^SYQRCodeSuncessBlock) (SYQRCodeViewController *,NSString *);

/**SYQRCodeFailBlock */
@property (nonatomic, copy) void (^SYQRCodeFailBlock) (SYQRCodeViewController *);
@end
