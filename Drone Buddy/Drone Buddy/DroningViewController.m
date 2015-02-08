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
#import <CoreLocation/CoreLocation.h>
@import CoreMotion;

@interface DroningViewController () <DeviceControllerDelegate>
@property (nonatomic, strong) DeviceController* deviceController;
@property(strong, nonatomic) CMMotionManager *motion;
@property BOOL individualJump;
@property double MULTIPLIER;

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) NSTimer *locTimer;


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
    self.myTextView.text = @"SAMPLE TEXT";
    
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.individualJump = true;
    self.MULTIPLIER = 100 / 2 * M_PI;
    
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
    
    self.locationManager = [[CLLocationManager alloc]init];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    
    
    [self measureAccelerometerData];
    [self measureGyroData];

}

- (void) updateLocation {
    double speed = [self.locationManager location].speed;
//    NSLog(@"Current Speed in M/S: %f", speed);
  //  NSLog(@"Accuracy: %f", [self.locationManager location].horizontalAccuracy);
    self.myTextView.text = [self.myTextView.text stringByAppendingString:[NSString stringWithFormat:@"Current Speed in M/S: %f", speed]];
    
     self.myTextView.text = [self.myTextView.text stringByAppendingString:[NSString stringWithFormat:@"Accuracy %f", [self.locationManager location].horizontalAccuracy]];
   // [self updateDroneToSpeed:speed];
}


-(void)updateDroneToSpeed : (double)speedMS
{
    float MS_KMH_Ratio = 3.6;
    float maxSpeedDrone = 18;
    
    
    double speedKMH = speedMS * MS_KMH_Ratio;
    double speedPercent = (speedKMH / maxSpeedDrone);
    if(speedPercent > 100)
    {
        speedPercent = 100;
    }
    [_deviceController setPitch:speedPercent];
    
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Accuracy: %f", newLocation.horizontalAccuracy);
    NSLog(@"LAT: %f", newLocation.coordinate.latitude);
    //Purposefully blank
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
        
        //NSLog(@"%f", motionData.rotationRate.x);
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



//GAZ
- (IBAction)gazUpTouchDown:(id)sender
{
    [_deviceController setGaz:50];
}
- (IBAction)gazDownTouchDown:(id)sender
{
    [_deviceController setGaz:-50];
}

- (IBAction)gazUpTouchUp:(id)sender
{
    [_deviceController setGaz:0];
}
- (IBAction)gazDownTouchUp:(id)sender
{
    [_deviceController setGaz:0];
}


@end
