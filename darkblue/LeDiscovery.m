/*

 File: LeDiscovery.m
 
 Abstract: Scan for and discover nearby LE peripherals with the 
 matching service UUID.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */



#import "LeDiscovery.h"
static NSString *str = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";

@interface LeDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate> {
	CBCentralManager    *centralManager;
    LeService	*service;
	BOOL				pendingInit;
}
@end

@implementation LeDiscovery

@synthesize foundPeripherals;
@synthesize connectedServices;
@synthesize discoveryDelegate;
@synthesize peripheralDelegate;
#pragma mark -
#pragma mark Init
/****************************************************************************/
/*									Init									*/
/****************************************************************************/
+ (id) sharedInstance
{
	static LeDiscovery	*this	= nil;

	if (!this)
		this = [[LeDiscovery alloc] init];

	return this;
}


- (id) init
{
    self = [super init];
    if (self) {
		pendingInit = YES;
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

		foundPeripherals = [[NSMutableArray alloc] init];
		connectedServices = [[NSMutableArray alloc] init];
	}
    return self;
}


- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
    [super dealloc];
}



#pragma mark -
#pragma mark Restoring
/****************************************************************************/
/*								Settings									*/
/****************************************************************************/
/* Reload from file. */
- (void) loadSavedDevices
{
//	NSArray	*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
//
//	if (![storedDevices isKindOfClass:[NSArray class]]) {
//        NSLog(@"No stored array to load");
//        return;
//    }
//     
//    for (id deviceUUIDString in storedDevices) {
//        
//        if (![deviceUUIDString isKindOfClass:[NSString class]])
//            continue;
//        
//        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)deviceUUIDString);
//        if (!uuid)
//            continue;
//        
//        [centralManager retrievePeripherals:[NSArray arrayWithObject:(id)uuid]];
//        CFRelease(uuid);
//    }

}


- (void) addSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"Can't find/create an array to store the uuid");
        return;
    }

    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    uuidString = CFUUIDCreateString(NULL, uuid);
    if (uuidString) {
        [newDevices addObject:(NSString*)uuidString];
        CFRelease(uuidString);
    }
    /* Store */
    [S_USER_DEFAULTS setObject:newDevices forKey:U_STORED_DEVICES];
    [S_USER_DEFAULTS synchronize];
}

- (void) addSavedDev:(NSString *) uuid
{
    NSArray			*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
    NSMutableArray	*newDevices		= nil;
    
    if (![storedDevices isKindOfClass:[NSArray class]]) {
        storedDevices = [NSArray arrayWithObject:uuid];
        /* Store */
        [S_USER_DEFAULTS setObject:storedDevices forKey:U_STORED_DEVICES];
        [S_USER_DEFAULTS synchronize];
        return;
    }
    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    if (![newDevices containsObject:uuid]) {
        [newDevices addObject:uuid];
        [S_USER_DEFAULTS setObject:(NSArray *)newDevices forKey:U_STORED_DEVICES];
        [S_USER_DEFAULTS synchronize];
    }
}


- (void) removeSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];

		uuidString = CFUUIDCreateString(NULL, uuid);
		if (uuidString) {
			[newDevices removeObject:(NSString*)uuidString];
            CFRelease(uuidString);
        }
		/* Store */
        [S_USER_DEFAULTS setObject:newDevices forKey:U_STORED_DEVICES];
		[S_USER_DEFAULTS synchronize];
	}
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
	CBPeripheral	*peripheral;
	
	/* Add to list. */
	for (peripheral in peripherals) {
		[central connectPeripheral:peripheral options:nil];
	}
	[discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
	[central connectPeripheral:peripheral options:nil];
	[discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
	/* Nuke from plist. */
	[self removeSavedDevice:UUID];
}

#pragma mark -
#pragma mark Discovery
/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (void) startScanningForUUIDString:(NSString *)uuidString
{

//    NSString *str1 = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
//    NSString *str2 = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
    
    NSArray  *uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:str], nil];
    //消除之前已经发现过的蓝牙
    [foundPeripherals removeAllObjects];
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    [centralManager scanForPeripheralsWithServices:uuidArray options:options];
    
    
}


- (void) stopScanning
{
	[centralManager stopScan];
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	if (![foundPeripherals containsObject:peripheral]) {
		[foundPeripherals addObject:peripheral];
	}
    [discoveryDelegate discoveryDidRefresh];

    if ([self isExistDevice:peripheral]&&service.peripheral.state!=CBPeripheralStateConnected) {
        [self connectPeripheral:peripheral];
        return;
    }
}

//是否存储过蓝牙
- (BOOL) isExistDevice:(CBPeripheral *)peripheral
{
    NSArray	*storedDevices	= [S_USER_DEFAULTS arrayForKey:U_STORED_DEVICES];
    
    if (![storedDevices isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    BOOL result = [storedDevices containsObject:peripheral.identifier.UUIDString];
    return result;
}

#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/
- (void) connectPeripheral:(CBPeripheral*)peripheral
{

    if ([service.peripheral state]==CBPeripheralStateConnected) {
        [centralManager cancelPeripheralConnection:service.peripheral];
    }
    
    if ([service.peripheral state]==CBPeripheralStateDisconnected) {
        [centralManager connectPeripheral:peripheral options:nil];
    }
    [discoveryDelegate discoveryDidRefresh];
//    else{
//        // 检测已连接Peripherals
//        float version = [[[UIDevice currentDevice] systemVersion]floatValue];
//        if (version >= 6.0){
//            [centralManager retrieveConnectedPeripherals];
//        }
//    }
}


- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    if (peripheral) {
        [centralManager cancelPeripheralConnection:peripheral];
    } else {
        if (service&&service.peripheral.state==CBPeripheralStateConnected) {
            [centralManager cancelPeripheralConnection:service.peripheral];
        }
    }
    [discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    /* Create a service instance. */
    service = [[LeService alloc] initWithPeripheral:peripheral controller:peripheralDelegate];
    [service start];

	if (![connectedServices containsObject:service])
		[connectedServices addObject:service];

//	if ([foundPeripherals containsObject:peripheral])
//		[foundPeripherals removeObject:peripheral];

    if ([peripheralDelegate respondsToSelector:@selector(alarmServiceDidChangeStatus:)]) {
        [peripheralDelegate alarmServiceDidChangeStatus:service];
    }
    
	[discoveryDelegate discoveryDidRefresh];
    //发现服务
   [peripheral discoverServices:@[[CBUUID UUIDWithString:str]]];
    
    //连接成功后pop
     NSLog(@"连接成功\nperipheral是%@\nconnectedServices是%@",peripheral,connectedServices);
    
    [discoveryDelegate connectedSuccess];
    
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
    [discoveryDelegate connectedFailure];
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	LeService	*service	= nil;

	for (service in connectedServices) {
		if ([service peripheral] == peripheral) {
			[connectedServices removeObject:service];
            [peripheralDelegate alarmServiceDidChangeStatus:service];
			break;
		}
	}
    if (![foundPeripherals containsObject:peripheral]) {
        [foundPeripherals insertObject:peripheral atIndex:0];
    }

	[discoveryDelegate discoveryDidRefresh];
}


- (void) clearDevices
{
    LeService	*service;
    [foundPeripherals removeAllObjects];
    
    for (service in connectedServices) {
        [service reset];
    }
    [connectedServices removeAllObjects];
}


- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{

            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLUE_CLOSED object:nil];
			/* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            if (previousState != -1) {
                [discoveryDelegate discoveryStatePoweredOff];
            }
			break;
		}
            
		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
			pendingInit = NO;
//			[self loadSavedDevices];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_BLUE_OPEN object:nil];
			[centralManager retrieveConnectedPeripherals];
            [self startScanningForUUIDString:nil];
//			[discoveryDelegate discoveryDidRefresh];
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
			[self clearDevices];
            [self startScanningForUUIDString:nil];
//            [discoveryDelegate discoveryDidRefresh];
            [peripheralDelegate alarmServiceDidReset];
            
			pendingInit = YES;
			break;
		}
	}
    
    previousState = [centralManager state];
}
@end
