//
//  BTManager.m
//  Drone Buddy
//
//  Created by Jose Bethancourt on 2/7/15.
//  Copyright (c) 2015 Jose Bethancourt. All rights reserved.
//

#import "BTManager.h"
@implementation BTManager

- (instancetype)init {
    self = [super init];
    NSLog(@"initializing BluetoothLEManager");
    _mBTCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return self;
}


#pragma mark - CBCentralManagerDelegate

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
}

int pastRSSI;
int i=0;
// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    //NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if ([peripheral.name isEqualToString:@"RS_W185666"]) {
        
        int RSSIabs = abs(RSSI.intValue);
        //NSLog(@"Curent: %d", RSSIabs);
        
        
        if (pastRSSI == 0){
            pastRSSI = RSSIabs;
            //NSLog(@"HERE");
        }else{
            int delta = (RSSIabs - pastRSSI);
            //NSLog(@"D: %d", delta);
            pastRSSI = RSSIabs;
        }

    }

}




-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"Start scan");
    
    if(central.state == CBCentralManagerStatePoweredOn){
        NSLog(@"Scanning for BTLE device");
        [central scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
}

+(NSNumber *)absoluteValue:(NSNumber *)input {
    return [NSNumber numberWithDouble:fabs([input doubleValue])];
}
@end
