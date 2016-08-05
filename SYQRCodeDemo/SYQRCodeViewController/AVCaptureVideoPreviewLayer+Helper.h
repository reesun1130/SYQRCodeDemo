//
//  AVCaptureVideoPreviewLayer+Helper.h
//  UserCarDealer
//
//  Created by autohome on 16/8/5.
//  Copyright © 2016年 autohome. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureVideoPreviewLayer (Helper)

+ (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayerWithFrame:(CGRect)frame
                                                   rectOfInterest:(CGRect)rectOfInterest
                                                    captureDevice:(AVCaptureDevice *)captureDevice
                                          metadataObjectsDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)metadataObjectsDelegate;

@end
