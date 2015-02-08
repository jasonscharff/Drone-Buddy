//
//  DroningViewController.m
//  Drone Buddy
//
//  Created by Jose Bethancourt on 2/7/15.
//  Copyright (c) 2015 Jose Bethancourt. All rights reserved.
//

#import "DroningViewController.h"
#import "DeviceController.h"
#import <MyoKit/MyoKit.h>
@import CoreMotion;

@interface DroningViewController () <DeviceControllerDelegate>
@property (nonatomic, strong) DeviceController* deviceController;
@property(strong, nonatomic) CMMotionManager *motion;
@property BOOL individualJump;
@property double MULTIPLIER;
@end

@implementation DroningViewController

@synthesize service = _service;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [[TLMHub sharedHub] setLockingPolicy:TLMLockingPolicyNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.individualJump = true;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _deviceController = [[DeviceController alloc]initWithARService:_service];
        [_deviceController setDelegate:self];
        BOOL connectError = [_deviceController start];
        
        NSLog(@"connectError = %d", connectError);
        

        
        if (connectError)
        {
            NSLog(@"something went wrong, kill me.");
        }
    });
    [self measureAccelerometerData];
    [self measureGyroData];
}

- (IBAction)connectToMyo:(id)sender {
    
    UINavigationController *settings = [TLMSettingsViewController settingsInNavigationController];
    
    [self presentViewController:settings animated:YES completion:nil];
    
    
}
- (void)didReceivePoseChange:(NSNotification*)notification {
    
    NSLog(@"YOU MOVED");
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    
    if(pose.type == TLMPoseTypeDoubleTap)
    {
        [_deviceController sendPhoto];
    }
    
    
    
}

-(void)measureAccelerometerData
{
    float threshold = 0.6;
    self.motion = [[CMMotionManager alloc]init];
    [self.motion startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        if(accelerometerData.acceleration.z > threshold)
        {
            if(self.individualJump == true)
            {
                NSLog(@"jump!");
                [_deviceController doFlip];
                self.individualJump = false;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.individualJump = true;
                });
            }
            
        }
    }];
}

-(void) measureGyroData
{
    double threshold = 0.05;
    [self.motion setDeviceMotionUpdateInterval:0.1];
    [self.motion startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motionData, NSError *error) {
        if(motionData.rotationRate.x > threshold || motionData.rotationRate.x < threshold * -1)
        {
            [_deviceController setFlag:1];
            [_deviceController setYaw:motionData.rotationRate.x * self.MULTIPLIER];
        }
        else
        {
            [_deviceController setFlag:0];
            [_deviceController setYaw:0];
        }
        
        NSLog(@"%f", motionData.rotationRate.x);
    }];
}
/*
- (void) viewDidDisappear:(BOOL)animated
{
    _alertView = [[UIAlertView alloc] initWithTitle:[_service name] message:@"Disconnecting ..."
                                           delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_alertView show];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_deviceController stop];
        [_alertView dismissWithClickedButtonIndex:0 animated:TRUE];
    });
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark DeviceControllerDelegate

- (void)onDisconnectNetwork:(DeviceController *)deviceController
{
    NSLog(@"onDisconnect ...");
    
   
}

- (void)onUpdateBattery:(DeviceController *)deviceController batteryLevel:(uint8_t)percent;
{
    NSLog(@"onUpdateBattery");
    
}

- (IBAction)emergencyClick:(id)sender
{
    [_deviceController sendEmergency];
}

- (IBAction)takeoffClick:(id)sender
{
    [_deviceController sendTakeoff];
}

- (IBAction)landingClick:(id)sender
{
    [_deviceController sendLanding];
}






@end
