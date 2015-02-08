//
//  DroningViewController.h
//  Drone Buddy
//
//  Created by Jose Bethancourt on 2/7/15.
//  Copyright (c) 2015 Jose Bethancourt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>
#import <CoreLocation/CoreLocation.h>

@interface DroningViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) ARService* service;

- (IBAction)emergencyClick:(id)sender;
- (IBAction)takeoffClick:(id)sender;
- (IBAction)landingClick:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *myTextView;

@end
