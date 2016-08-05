//
//  SYQRCodeViewController.h
//  SYQRCodeDemo
//
//  Created by ree.sun on 15-1-9.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <UIKit/UIKit.h>

@interface SYQRCodeViewController : UIViewController

/**SYQRCodeCancleBlock */
@property (nonatomic, copy) void (^SYQRCodeCancleBlock) (SYQRCodeViewController *);

/**SYQRCodeSuncessBlock */
@property (nonatomic, copy) void (^SYQRCodeSuncessBlock) (SYQRCodeViewController *, NSString *);

/**SYQRCodeFailBlock */
@property (nonatomic, copy) void (^SYQRCodeFailBlock) (SYQRCodeViewController *);

@end
