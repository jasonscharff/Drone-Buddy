//
//  ViewController.m
//  Drone Buddy
//
//  Created by Jose Bethancourt on 2/7/15.
//  Copyright (c) 2015 Jose Bethancourt. All rights reserved.
//


#import "ViewController.h"
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>
#import "BTManager.h"
//#import "PilotingViewController.h"
#import "DroningViewController.h"

@interface CellData ()
@end

@implementation CellData
@end

@interface ViewController ()

@property (strong) BTManager *bluetoothManager;
@property (nonatomic, strong) ARService *serviceSelected;

@end

@implementation ViewController
{
    NSArray *tableData;
    //ARService *serviceSelected;
}

@synthesize tableView = _tableView;
@synthesize serviceSelected = _serviceSelected;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableData = [NSArray array];
    _serviceSelected = nil;
    
    self.bluetoothManager = [[BTManager alloc] init];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear ... ");
    [super viewDidAppear:animated];
    
    [self registerApplicationNotifications];
    [[ARDiscovery sharedInstance] start];
}

- (void) viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear ... ");
    [super viewDidDisappear:animated];
    
    [self unregisterApplicationNotifications];
    [[ARDiscovery sharedInstance] stop];
}

- (void)registerApplicationNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground:) name: UIApplicationDidEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name: UIApplicationWillEnterForegroundNotification object: nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoveryDidUpdateServices:) name:kARDiscoveryNotificationServicesDevicesListUpdated object:nil];
}

- (void)unregisterApplicationNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIApplicationDidEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIApplicationWillEnterForegroundNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kARDiscoveryNotificationServicesDevicesListUpdated object:nil];
}

#pragma mark - application notifications
- (void)enteredBackground:(NSNotification*)notification
{
    NSLog(@"enteredBackground ... ");
}

- (void)enterForeground:(NSNotification*)notification
{
    NSLog(@"enterForeground ... ");
}

#pragma mark ARDiscovery notification
- (void)discoveryDidUpdateServices:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateServicesList:[[notification userInfo] objectForKey:kARDiscoveryServicesList]];
    });
}

- (void)updateServicesList:(NSArray *)services
{
    NSMutableArray *serviceArray = [NSMutableArray array];
    
    for (ARService *service in services)
    {
        if ([service.service isKindOfClass:[ARBLEService class]])
        {
            CellData *cellData = [[CellData alloc]init];
            
            [cellData setService:service];
            [cellData setName:service.name];
            [serviceArray addObject:cellData];
        }
    }
    
    tableData = serviceArray;
    [_tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [(CellData *)[tableData objectAtIndex:indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _serviceSelected = [(CellData *)[tableData objectAtIndex:indexPath.row] service];
    NSLog(@"%@", _serviceSelected);
    [self performSegueWithIdentifier:@"droningSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(([segue.identifier isEqualToString:@"droningSegue"]) && (_serviceSelected != nil))
    {
        DroningViewController *droningViewController = (DroningViewController *)[segue destinationViewController];
         NSLog(@"%@", _serviceSelected);
        [droningViewController setService: _serviceSelected];
    }
}

@end
