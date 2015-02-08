//
//  ViewController.h
//  Drone Buddy
//
//  Created by Jose Bethancourt on 2/7/15.
//  Copyright (c) 2015 Jose Bethancourt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>


@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@interface CellData : NSObject

@property (nonatomic, strong) ARService* service;
@property (nonatomic, strong) NSString* name;

@end

