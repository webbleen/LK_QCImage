//
//  CACameraSessionDelegate.h
//
//  Created by Christopher Cohen & Gabriel Alvarado on 1/23/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

#import "CameraSessionView.h"
#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

//Custom UI classes
#import "CameraToggleButton.h"
#import "CameraFlashButton.h"
#import "CameraFocalReticule.h"
#import "Constants.h"

@interface CameraSessionView () <CaptureSessionManagerDelegate>
{
    //Size of the UI elements variables
    CGSize itemButtonSize;
    CGSize sideBarSize;
    CGSize barButtonItemSize;
    
    //Variable vith the current camera being used (Rear/Front)
    CameraType cameraBeingUsed;
}

//Primative Properties
@property (readwrite) BOOL animationInProgress;

//Object References
@property (nonatomic, strong) CaptureSessionManager *captureManager;
@property (nonatomic, strong) UIButton *cameraShutter;
@property (nonatomic, strong) CameraToggleButton *cameraToggle;
@property (nonatomic, strong) CameraFlashButton *cameraFlash;
@property (nonatomic, strong) CameraFocalReticule *focalReticule;
@property (nonatomic, strong) UIView *sideBarView;

//Temporary/Diagnostic properties
@property (nonatomic, strong) UILabel *ISOLabel, *apertureLabel, *shutterSpeedLabel;

@end

@implementation CameraSessionView

-(void)drawRect:(CGRect)rect {
    if (self) {
        _animationInProgress = NO;
        [self setupCaptureManager:RearFacingCamera];
        cameraBeingUsed = RearFacingCamera;
        [self composeInterface];
        
        [[_captureManager captureSession] startRunning];
    }
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

#pragma mark - Setup

-(void)setupCaptureManager:(CameraType)camera {
    
    // remove existing input
    AVCaptureInput* currentCameraInput = [self.captureManager.captureSession.inputs objectAtIndex:0];
    [self.captureManager.captureSession removeInput:currentCameraInput];
    
    _captureManager = nil;
    
    //Create and configure 'CaptureSessionManager' object
    _captureManager = [CaptureSessionManager new];
    
    // indicate that some changes will be made to the session
    [self.captureManager.captureSession beginConfiguration];
    
    if (_captureManager) {
        
        //Configure
        [_captureManager setDelegate:self];
        [_captureManager initiateCaptureSessionForCamera:camera];
        [_captureManager addStillImageOutput];
        [_captureManager addVideoPreviewLayer];
        [self.captureManager.captureSession commitConfiguration];
        
        //Preview Layer setup
        CGRect layerRect = self.layer.bounds;
        [_captureManager.previewLayer setBounds:layerRect];
        [_captureManager.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
        
        //Apply animation effect to the camera's preview layer
        CATransition *applicationLoadViewIn =[CATransition animation];
        [applicationLoadViewIn setDuration:0.6];
        [applicationLoadViewIn setType:kCATransitionReveal];
        [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [_captureManager.previewLayer addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
        
        //Add to self.view's layer
        [self.layer addSublayer:_captureManager.previewLayer];
    }
}

-(void)composeInterface {
    
    //Adding notifier for orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    
    //Define adaptable sizing variables for UI elements to the right device family (iPhone or iPad)
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //Declare the sizing of the UI elements for iPad
        sideBarSize = CGSizeMake(self.frame.size.width*0.1, self.frame.size.height);
        itemButtonSize = CGSizeMake(self.bounds.size.height * 0.1, self.bounds.size.height * 0.1);
        barButtonItemSize = CGSizeMake(self.frame.size.height * 0.1, self.frame.size.height * 0.1);
    } else
    {
        //Declare the sizing of the UI elements for iPhone
        sideBarSize = CGSizeMake(self.frame.size.width*0.15, self.frame.size.height);
        itemButtonSize = CGSizeMake(self.frame.size.height * 0.21, self.frame.size.height * 0.21);
        barButtonItemSize = CGSizeMake(self.frame.size.height * 0.1, self.frame.size.height * 0.1);
    }
    
    //Create the broadSide and add the buttons to it
    _sideBarView = [UIView new];
    if (_sideBarView)
    {
        _sideBarView.frame = (CGRect){0,0, sideBarSize};
        _sideBarView.center = CGPointMake(self.frame.size.width-(sideBarSize.width/2), self.frame.size.height/2);
        _sideBarView.backgroundColor = [UIColor colorWithRed: 0.176 green: 0.478 blue: 0.529 alpha: 0.64];
        [self addSubview:_sideBarView];
        
        
        if (_captureManager) {
            //Create shutter button
            _cameraShutter = [UIButton buttonWithType:UIButtonTypeCustom];
            _cameraShutter.frame = (CGRect){0,0, itemButtonSize};
            _cameraShutter.center = CGPointMake(self.frame.size.width-sideBarSize.width/2, self.frame.size.height*(3.0/6.0f));
            [_cameraShutter setImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
            _cameraShutter.tag = ShutterButtonTag;
            [_cameraShutter addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_cameraShutter];
            
            UIButton *cameraDismiss = [UIButton buttonWithType:UIButtonTypeCustom];
            cameraDismiss.frame = (CGRect){0,0, itemButtonSize};
            cameraDismiss.center = CGPointMake(self.frame.size.width-sideBarSize.width/2, self.frame.size.height*(5.0/6.0f));
            [cameraDismiss setImage:[UIImage imageNamed:@"canclePhoto"] forState:UIControlStateNormal];
            cameraDismiss.tag = DismissButtonTag;
            [cameraDismiss addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cameraDismiss];
        }
        
    }
    
    //Add the camera toggle button
    _cameraToggle = [CameraToggleButton new];
    if (_cameraToggle) {
        _cameraToggle.frame = (CGRect){0,0, barButtonItemSize};
        _cameraToggle.center = CGPointMake(self.frame.size.height*0.15, self.frame.size.height*(1/6.0f));
        _cameraToggle.tag = ToggleButtonTag;
        
        //Button target
        [_cameraToggle addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraToggle];
    }
    
    //Add the flash button
    _cameraFlash = [CameraFlashButton new];
    if (_cameraFlash) {
        _cameraFlash.frame = (CGRect){0,0, barButtonItemSize};
        _cameraFlash.center = CGPointMake(self.frame.size.height*0.15, self.frame.size.height*(5/6.0f));
        _cameraFlash.tag = FlashButtonTag;
        if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        {
            //Button target
            [_cameraFlash addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_cameraFlash];
        }
    }
    
    //Create the focus reticule UIView
    _focalReticule = [CameraFocalReticule new];
    
    if (_focalReticule) {
        
        _focalReticule.frame = (CGRect){0,0, 60, 60};
        _focalReticule.backgroundColor = [UIColor clearColor];
        _focalReticule.hidden = YES;
        [self addSubview:_focalReticule];
    }
    
    //Create the gesture recognizer for the focus tap
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    if (singleTapGestureRecognizer) [self addGestureRecognizer:singleTapGestureRecognizer];
    
}

#pragma mark - User Interaction

-(void)inputManager:(id)sender {
    
    //If animation is in progress, ignore input
    if (_animationInProgress) return;
    
    //If sender does not inherit from 'UIButton', return
    if (![sender isKindOfClass:[UIButton class]]) return;
    
    //Input manager switch
    switch ([(UIButton *)sender tag]) {
        case ShutterButtonTag:  [self onTapShutterButton];  return;
        case ToggleButtonTag:   [self onTapToggleButton];   return;
        case FlashButtonTag:    [self onTapFlashButton];    return;
        case DismissButtonTag:  [self onTapDismissButton];  return;
    }
}

- (void)onTapShutterButton {
    
    //Animate shutter release
    [self animateShutterRelease];
    
    //Capture image from camera
    [_captureManager captureStillImage];
}

- (void)onTapFlashButton {
    BOOL enable = !self.captureManager.isTorchEnabled;
    self.captureManager.enableTorch = enable;
}

- (void)onTapToggleButton {
    if (cameraBeingUsed == RearFacingCamera) {
        [self setupCaptureManager:FrontFacingCamera];
        cameraBeingUsed = FrontFacingCamera;
        [self composeInterface];
        [[_captureManager captureSession] startRunning];
        _cameraFlash.hidden = YES;
    } else {
        [self setupCaptureManager:RearFacingCamera];
        cameraBeingUsed = RearFacingCamera;
        [self composeInterface];
        [[_captureManager captureSession] startRunning];
        _cameraFlash.hidden = NO;
    }
}

- (void)onTapDismissButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.center = CGPointMake(self.center.x, self.center.y*3);
    } completion:^(BOOL finished) {
        [_captureManager stop];
        [self removeFromSuperview];
    }];
}

- (void)focusGesture:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        if (tap.state == UIGestureRecognizerStateRecognized) {
            CGPoint location = [sender locationInView:self];
            
            [self focusAtPoint:location completionHandler:^{
                 [self animateFocusReticuleToPoint:location];
             }];
        }
    }
}

#pragma mark - Animation

- (void)animateShutterRelease {
    
    _animationInProgress = YES; //Disables input manager
    
    [UIView animateWithDuration:.1 animations:^{
        _cameraShutter.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 animations:^{
            _cameraShutter.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            
            _animationInProgress = NO; //Enables input manager
        }];
    }];
}

- (void)animateFocusReticuleToPoint:(CGPoint)targetPoint
{
    _animationInProgress = YES; //Disables input manager
    
    [self.focalReticule setCenter:targetPoint];
    self.focalReticule.alpha = 0.0;
    self.focalReticule.hidden = NO;
    
    [UIView animateWithDuration:0.4 animations:^{
         self.focalReticule.alpha = 1.0;
     } completion:^(BOOL finished) {
         [UIView animateWithDuration:0.4 animations:^{
              self.focalReticule.alpha = 0.0;
          }completion:^(BOOL finished) {
              
              _animationInProgress = NO; //Enables input manager
          }];
     }];
}

- (void)orientationChanged:(NSNotification *)notification{
    
}

#pragma mark - Camera Session Manager Delegate Methods

-(void)cameraSessionManagerDidCaptureImage
{
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(didCaptureImage:)])
            [self.delegate didCaptureImage:[[self captureManager] stillImage]];
        
        if ([self.delegate respondsToSelector:@selector(didCaptureImageWithData:)])
            [self.delegate didCaptureImageWithData:[[self captureManager] stillImageData]];
    }
}

-(void)cameraSessionManagerFailedToCaptureImage {
}

-(void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType {
}

-(void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics {
}

#pragma mark - Helper Methods

- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        //Lock camera for configuration if possible
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [device unlockForConfiguration];
            
            completionHandler();
        }
    }
    else
    {
        completionHandler();
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - API Functions
- (void)setSideBarColor:(UIColor *)sideBarColor
{
    
}

- (void)hideFlashButton
{
    _cameraFlash.hidden = YES;
}

- (void)hideCameraToggleButton
{
    _cameraToggle.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
