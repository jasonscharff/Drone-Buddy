//
//  BTManager.h
//  Drone Buddy
//
//  Created by Jose Bethancourt on 2/7/15.
//  Copyright (c) 2015 Jose Bethancourt. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;
@interface BTManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, readonly) CBCentralManager *mBTCentralManager;

@end
