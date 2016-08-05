//
//  AVCaptureVideoPreviewLayer+Helper.m
//  SYQRCodeDemo
//
//  Created by ree.sun on 16/8/5.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

#import "AVCaptureVideoPreviewLayer+Helper.h"

@implementation AVCaptureVideoPreviewLayer (Helper)

+ (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayerWithFrame:(CGRect)frame
                                                   rectOfInterest:(CGRect)rectOfInterest
                                                    captureDevice:(AVCaptureDevice *)captureDevice
                                          metadataObjectsDelegate:(id<AVCaptureMetadataOutputObjectsDelegate>)metadataObjectsDelegate {
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (error){
        NSLog(@"摄像头不可用-%@", error.localizedDescription);
        return nil;
    }
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    //设置检测质量，质量越高扫描越精确
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
        [session setSessionPreset:AVCaptureSessionPresetiFrame960x540];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    else {
        [session setSessionPreset:AVCaptureSessionPresetLow];
    }
    
    //添加输入设备
    if ([session canAddInput:input]){
        [session addInput:input];
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:metadataObjectsDelegate queue:dispatch_get_main_queue()];
    [output setRectOfInterest:rectOfInterest];
    
    //添加输出元
    if ([session canAddOutput:output]){
        [session addOutput:output];
    }
    
    //识别二维码
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //扫描图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    preview.frame = frame;
    
    return preview;
}

@end
