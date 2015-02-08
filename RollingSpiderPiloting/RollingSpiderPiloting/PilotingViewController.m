/*
    Copyright (C) 2014 Parrot SA

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the 
      distribution.
    * Neither the name of Parrot nor the names
      of its contributors may be used to endorse or promote products
      derived from this software without specific prior written
      permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
*/
//
//  PilotingViewController.m
//  RollingSpiderPiloting
//
//  Created on 19/01/2015.
//  Copyright (c) 2015 Parrot. All rights reserved.
//

#import "PilotingViewController.h"
#import "DeviceController.h"
 #import <MyoKit/MyoKit.h>
@import CoreMotion;

@interface PilotingViewController () <DeviceControllerDelegate>
@property (nonatomic, strong) DeviceController* deviceController;
@property (nonatomic, strong) UIAlertView *alertView;
@property(strong, nonatomic) CMMotionManager *motion;
@property BOOL individualJump;
@end

@implementation PilotingViewController

@synthesize service = _service;
@synthesize batteryLabel = _batteryLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad ...");
    
    [_batteryLabel setText:@"?%"];
    
    _alertView = [[UIAlertView alloc] initWithTitle:[_service name] message:@"Connecting ..."
                                           delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    
    [[TLMHub sharedHub] setLockingPolicy:TLMLockingPolicyNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];

    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_alertView show];
    
     self.individualJump = true;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _deviceController = [[DeviceController alloc]initWithARService:_service];
        [_deviceController setDelegate:self];
        BOOL connectError = [_deviceController start];
        
        NSLog(@"connectError = %d", connectError);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView dismissWithClickedButtonIndex:0 animated:TRUE];
            
        });
        
        if (connectError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    });
    
    [self measureAccelerometerData];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark events

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

//events for gaz:
- (IBAction)gazUpTouchDown:(id)sender
{
    [_deviceController setGaz:50];
}
- (IBAction)gazDownTouchDown:(id)sender
{
    [_deviceController setGaz:-50];
}
- (IBAction)takePicture:(id)sender {
    [_deviceController sendPhoto];
    
}

- (IBAction)gazUpTouchUp:(id)sender
{
    [_deviceController setGaz:0];
}
- (IBAction)gazDownTouchUp:(id)sender
{
    [_deviceController setGaz:0];
}

//events for yaw:
- (IBAction)yawLeftTouchDown:(id)sender
{
    [_deviceController setYaw:-50];

}
- (IBAction)yawRightTouchDown:(id)sender
{
    [_deviceController setYaw:50];
    
}

- (IBAction)yawLeftTouchUp:(id)sender
{
    [_deviceController setYaw:0];
}

- (IBAction)yawRightTouchUp:(id)sender
{
    [_deviceController setYaw:0];
}

//events for yaw:
- (IBAction)rollLeftTouchDown:(id)sender
{
    [_deviceController setFlag:1];
    [_deviceController setRoll:-50];
}
- (IBAction)rollRightTouchDown:(id)sender
{
    [_deviceController setFlag:1];
    [_deviceController setRoll:50];
}

- (IBAction)rollLeftTouchUp:(id)sender
{
    [_deviceController setFlag:0];
    [_deviceController setRoll:0];
}
- (IBAction)rollRightTouchUp:(id)sender
{
    [_deviceController setFlag:0];
    [_deviceController setRoll:0];
}

//events for pitch:
- (IBAction)pitchForwardTouchDown:(id)sender
{
    [_deviceController setFlag:1];
    [_deviceController setPitch:50];
}
- (IBAction)pitchBackTouchDown:(id)sender
{
    [_deviceController setFlag:1];
    [_deviceController setPitch:-50];
}

- (IBAction)pitchForwardTouchUp:(id)sender
{
    [_deviceController setFlag:0];
    [_deviceController setPitch:0];
}
- (IBAction)pitchBackTouchUp:(id)sender
{
    [_deviceController setFlag:0];
    [_deviceController setPitch:0];
}

#pragma mark DeviceControllerDelegate

- (void)onDisconnectNetwork:(DeviceController *)deviceController
{
    NSLog(@"onDisconnect ...");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)onUpdateBattery:(DeviceController *)deviceController batteryLevel:(uint8_t)percent;
{
    NSLog(@"onUpdateBattery");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = [[NSString alloc] initWithFormat:@"%d%%", percent];
        [_batteryLabel setText:text];
    });
}


@end
