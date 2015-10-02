//
//  SYQRCodeViewController.m
//  SYQRCodeDemo
//
//  Created by sunbb on 15-1-9.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import "SYQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ZXingObjC/ZXingObjC.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_FRAME [UIScreen mainScreen].bounds

static const float kLineMinY = 185;
static const float kLineMaxY = 385;
static const float kReaderViewWidth = 200;
static const float kReaderViewHeight = 200;
static const float BTN_TAG = 100000;

@interface SYQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *qrSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) NSTimer *lineTimer;

@end

@implementation SYQRCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (![_captureDevice hasTorch]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备没有闪光灯" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
    self.title = @"Scan";
    [self initUI];
    [self setOverlayPickerView];
    [self startSYQRCodeReading];
}



- (void)initUI
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error){
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        return;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]){
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
        
    }else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]){
        
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }else{
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input]){
        [session addInput:input];
    }
    
    if ([session canAddOutput:output]){
        [session addOutput:output];
    }
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:preview atIndex:0];
    self.qrVideoPreviewLayer = preview;
    self.qrSession = session;
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    return CGRectMake(kLineMinY / SCREEN_HEIGHT, ((SCREEN_WIDTH - asize.width) / 2.0) / SCREEN_WIDTH, asize.height / SCREEN_HEIGHT, asize.width / SCREEN_WIDTH);
}

- (void)setOverlayPickerView
{
    //画中间的基准线
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 300) / 2.0, kLineMinY, 300, 12 * 300 / 320.0)];
    [_line setImage:[UIImage imageNamed:@"QRCodeLine"]];
    [self.view addSubview:_line];
    
    //最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kLineMinY)];//80
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMinY, (SCREEN_WIDTH - kReaderViewWidth) / 2.0, kReaderViewHeight)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - CGRectGetMaxX(leftView.frame), kLineMinY, CGRectGetMaxX(leftView.frame), kReaderViewHeight)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    CGFloat space_h = SCREEN_HEIGHT - kLineMaxY;
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMaxY, SCREEN_WIDTH, space_h)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    //四个边角
    UIImage *cornerImage = [UIImage imageNamed:@"QRCodeTopLeft"];
    
    //左侧的view
    UIImageView *leftView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    leftView_image.image = cornerImage;
    [self.view addSubview:leftView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodeTopRight"];
    
    //右侧的view
    UIImageView *rightView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    rightView_image.image = cornerImage;
    [self.view addSubview:rightView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomLeft"];
    
    UIImageView *downView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downView_image.image = cornerImage;
    //downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomRight"];
    
    UIImageView *downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downViewRight_image.image = cornerImage;
    //downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downViewRight_image];
    
    UILabel *labIntroudction = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    CGFloat padding = (SCREEN_WIDTH - kReaderViewWidth)/2;
    labIntroudction.frame = CGRectMake(padding, CGRectGetMinY(downView.frame) + 25, kReaderViewWidth, 20);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont boldSystemFontOfSize:13.0];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"将二维码置于框内,即可自动扫描";
    [self.view addSubview:labIntroudction];
    
    CGFloat btnWidth = (CGRectGetWidth(labIntroudction.frame) - 40)/2;
    CGFloat btnHeight = 35.0;
    NSArray *btnTitle =@[@"Album", @"Open"];
    for (NSInteger i = 0; i < btnTitle.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn.frame = CGRectMake((btnWidth + 40) * i + padding, CGRectGetMaxY(labIntroudction.frame) + 2, btnWidth, btnHeight);
        [btn setTitle:btnTitle[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = i + BTN_TAG;
        if (btn.tag == BTN_TAG + 1) {
            [btn setTitle:@"Closed" forState:UIControlStateSelected];
            btn.selected = NO;
        }
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    UIView *scanCropView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - 1,kLineMinY,self.view.frame.size.width - 2 * CGRectGetMaxX(leftView.frame) + 2, kReaderViewHeight + 2)];
    scanCropView.layer.borderColor = [UIColor greenColor].CGColor;
    scanCropView.layer.borderWidth = 2.0;
    [self.view addSubview:scanCropView];
}

- (void)gotoImagePickerController{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];

}

- (void)turnOnTorch:(BOOL)on
{
    [_captureDevice lockForConfiguration:nil];
    if (on) {
        
        [_captureDevice setTorchMode:AVCaptureTorchModeOn];
    }else {
        
        [_captureDevice setTorchMode: AVCaptureTorchModeOff];
    }
    
    [_captureDevice unlockForConfiguration];
}


#pragma mark - Button Event
- (void)btnClick:(UIButton *)sender{
    
    //Album 读取
    if (sender.tag == BTN_TAG) {
        
        [self gotoImagePickerController];
    }else if(sender.tag == BTN_TAG + 1){
        //Touch
        if (sender.selected) {
            [self turnOnTorch:NO];
        }else{
            [self turnOnTorch:YES];
        }
        
        sender.selected = !sender.selected;
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    viewController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    UIImage *loadImage= [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"%@", loadImage);
    
    NSString *des;
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0){
        // if you only iOS >= 8.0 you can use system(this) method
        CIContext *context = [CIContext contextWithOptions:nil];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        CIImage *image = [CIImage imageWithCGImage:loadImage.CGImage];
        NSArray *features = [detector featuresInImage:image];
        CIQRCodeFeature *feature = [features firstObject];
        
        des = feature.messageString;

    }else{
#warning 一些网站:http://sauchye.com 无法识别 bug
        CGImageRef imageToDecode = loadImage.CGImage;
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
        
        NSError *error = nil;
        
        ZXDecodeHints *hints = [ZXDecodeHints hints];
        
        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
        
                                    error:&error];
        
        des = result.text;
    }
    
    
    if (des) {
        NSLog(@"contents =%@",des);
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:nil message:des delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alter show];
    } else {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"解析失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alter show];
    }


}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描结果
    if (metadataObjects.count > 0)
    {
        [self stopSYQRCodeReading];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0)
        {
            NSLog(@"---------%@",obj.stringValue);
            
            if ([obj.stringValue containsString:@"http"])
            {
                if (self.SYQRCodeSuncessBlock) {
                    self.SYQRCodeSuncessBlock(self,obj.stringValue);
                }
            }
            else
            {
                if (self.SYQRCodeFailBlock) {
                    self.SYQRCodeFailBlock(self);
                }
            }
        }
        else
        {
            if (self.SYQRCodeFailBlock) {
                self.SYQRCodeFailBlock(self);
            }
        }
    }
    else
    {
        if (self.SYQRCodeFailBlock) {
            self.SYQRCodeFailBlock(self);
        }
    }
}


#pragma mark - startSYQRCodeReading
- (void)startSYQRCodeReading
{
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    
    [self.qrSession startRunning];
    
    NSLog(@"start reading");
}

- (void)stopSYQRCodeReading
{
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    
    [self.qrSession stopRunning];
    
    NSLog(@"stop reading");
}


- (void)cancleSYQRCodeReading
{
    [self stopSYQRCodeReading];
    
    if (self.SYQRCodeCancleBlock)
    {
        self.SYQRCodeCancleBlock(self);
    }
    NSLog(@"cancle reading");
}


#pragma mark - animationLine
- (void)animationLine
{
    __block CGRect frame = _line.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = kLineMinY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 5;
            _line.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (_line.frame.origin.y >= kLineMinY)
        {
            if (_line.frame.origin.y >= kLineMaxY - 12)
            {
                frame.origin.y = kLineMinY;
                _line.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    
                    frame.origin.y += 5;
                    _line.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
    
    //NSLog(@"_line.frame.origin.y==%f",_line.frame.origin.y);
}


- (void)dealloc
{
    if (_qrSession) {
        [_qrSession stopRunning];
        _qrSession = nil;
    }
    
    if (_qrVideoPreviewLayer) {
        _qrVideoPreviewLayer = nil;
    }
    
    if (_line) {
        _line = nil;
    }
    
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
}

@end
