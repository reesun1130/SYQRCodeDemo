//
//  AVCaptureVideoPreviewLayer+Helper.h
//  SYQRCodeDemo
//
//  Created by ree.sun on 16/8/5.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureVideoPreviewLayer (Helper)

+ (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayerWithFrame:(CGRect)frame
                                                   rectOfInterest:(CGRect)rectOfInterest
                                                    captureDevice:(AVCaptureDevice *)captureDevice
                                          metadataObjectsDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)metadataObjectsDelegate;

@end
