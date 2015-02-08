//
//  DroningViewController.h
//  Drone Buddy
//
//  Created by Jose Bethancourt on 2/7/15.
//  Copyright (c) 2015 Jose Bethancourt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>

@interface DroningViewController : UIViewController

@property (nonatomic, strong) ARService* service;

- (IBAction)emergencyClick:(id)sender;
- (IBAction)takeoffClick:(id)sender;
- (IBAction)landingClick:(id)sender;


@end
