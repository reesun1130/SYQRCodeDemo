//
//  SYQRCodeViewController.m
//  SYQRCodeDemo
//
//  Created by sunbb on 15-1-9.
//  Copyright (c) 2015年 SY. All rights reserved.
//

#import "SYQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

//设备宽/高/坐标
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
    
    //摄像头判断
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error){
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        return;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出的代理
    //使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    //拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // 读取质量，质量越高，可读取小尺寸的二维码
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]){
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
        
    }else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]){
        
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }else{
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    
    //设置输出的格式
    //一定要先设置会话的输出为output之后，再指定输出的元数据类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置预览图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //设置preview图层的属性
    //preview.borderColor = [UIColor redColor].CGColor;
    //preview.borderWidth = 1.5;
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置preview图层的大小
    preview.frame = self.view.layer.bounds;
    //[preview setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    //将图层添加到视图的图层
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
    
    //底部view
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

- (void)initImagePickerController{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
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
    
    //Album
    if (sender.tag == BTN_TAG) {
        
        [self initImagePickerController];
        
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
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    NSLog(@"%@", image);
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


#pragma mark -
#pragma mark 交互事件

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

//取消扫描
- (void)cancleSYQRCodeReading
{
    [self stopSYQRCodeReading];
    
    if (self.SYQRCodeCancleBlock)
    {
        self.SYQRCodeCancleBlock(self);
    }
    NSLog(@"cancle reading");
}


#pragma mark -
#pragma mark 上下滚动交互线

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
