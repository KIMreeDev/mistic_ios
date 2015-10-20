/*

 File: LeService.m

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



#import "LeService.h"
#import "LeDiscovery.h"
#import "DateTimeHelper.h"
#import "UsersLocation.h"
NSString *kServiceUUIDString = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
NSString *kGetCharacteristicUUIDString = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
NSString *kWriteCharacteristicUUIDString = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

@interface LeService() <CBPeripheralDelegate, UsersLocationDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    
    CBService			*blueToothService;
    
    CBCharacteristic    *getCharacteristic;
    CBCharacteristic	*writeCharacteristic;
    
    CBUUID              *getDataUUID;
    CBUUID              *writeDataUUID;

    id<LeServiceProtocol>	peripheralDelegate;
}
@end



@implementation LeService


@synthesize peripheral = servicePeripheral;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeServiceProtocol>)controller
{
    self = [super init];
    if (self) {
        servicePeripheral = [peripheral retain];
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
        getDataUUID	= [[CBUUID UUIDWithString:kGetCharacteristicUUIDString] retain];
        writeDataUUID	= [[CBUUID UUIDWithString:kWriteCharacteristicUUIDString] retain];
	}
    return self;
}


- (void) dealloc {
	if (servicePeripheral) {
		[servicePeripheral setDelegate:[LeDiscovery sharedInstance]];
		[servicePeripheral release];
		servicePeripheral = nil;
        
        [getDataUUID release];
        [writeDataUUID release];
    }
    [super dealloc];
}


- (void) reset
{
	if (servicePeripheral) {
		[servicePeripheral release];
		servicePeripheral = nil;
	}
}




#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) start
{
	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kServiceUUIDString];
	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID,nil];
    [servicePeripheral discoverServices:serviceArray];

}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{

    NSArray		*services	= nil;
    NSArray		*uuids	= [NSArray arrayWithObjects:getDataUUID, // get
                           writeDataUUID, // write
                           nil];
    
    if (peripheral != servicePeripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        return ;
    }
    
    blueToothService = nil;
    
    for (CBService *service in services) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kServiceUUIDString]]) {
            blueToothService = service;
            break;
        }
    }
    
    if (blueToothService) {
        [peripheral discoverCharacteristics:uuids forService:blueToothService];
    }  
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    if (error) {
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUIDString]]) {

        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kGetCharacteristicUUIDString]]) {
                
                //储存蓝牙设备标识
                [[LeDiscovery sharedInstance]addSavedDev:peripheral.identifier.UUIDString];
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                [S_USER_DEFAULTS setBool:NO forKey:@"BlueToothIsFirstLaunch"];
                [S_USER_DEFAULTS setObject:peripheral.identifier.UUIDString forKey:BLUEIDENTIFY];
                [S_USER_DEFAULTS synchronize];
                
                //设置已连接(固件版本)
                [S_USER_DEFAULTS setObject:service.peripheral.name forKey:F_FIRMWARE_VERSION];
                [S_USER_DEFAULTS synchronize];
                
                //设置获取位置单例
                [[UsersLocation sharedInstance] setDelegate:(id)self];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BLUE_CONNECTED object:nil];
                
            }
            else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUIDString]]){

                writeCharacteristic = characteristic;
                //写数据
                NSData *willWrited = [DateTimeHelper stringToByte:[DateTimeHelper ToHex:[DateTimeHelper getTimeSp]]];
                [self writData:willWrited];

            }
        }
    }
}

#pragma mark - UsersLocationDelegate
- (void)didUpdateLocation:(NSMutableDictionary *)locationDic
{
    NSMutableArray *arr = S_ALL_SMOKING;
    [[[[arr objectAtIndex:_dateIndex]objectForKey:F_SCHEDULE]lastObject]setObject:locationDic forKey:F_PLACE];

}

- (void)didFailUpdateLocation:(NSError *)error
{
    
}

#pragma mark Characteristics interaction
/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/
- (void) writData:(NSData *)data;
{
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
		return ;
    }
    [servicePeripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
}



/** If we're connected, we don't want to be getting data change notifications while we're in the background.
 We will want alarm notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    NSLog(@"进入后台");
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kServiceUUIDString]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:kGetCharacteristicUUIDString]] ) {
                    
                    // And STOP getting notifications from it
                    [servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
}

/** Coming back from the background, we want to register for notifications again for the temperature changes */
- (void)enteredForeground
{
    NSLog(@"进入前台");
    //写数据
    NSData *willWrited = [DateTimeHelper stringToByte:[DateTimeHelper ToHex:[DateTimeHelper getTimeSp]]];
    [self writData:willWrited];
    // Find the fishtank service
//    for (CBService *service in [servicePeripheral services]) {
//        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kServiceUUIDString]]) {
//            
//            // Find the temperature characteristic
//            for (CBCharacteristic *characteristic in [service characteristics]) {
//                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:kGetCharacteristicUUIDString]] ) {
//                    
//                    // And START getting notifications from it
//                    [servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
//                }
//            }
//        }
//    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];

    } else { // Notification has stopped
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (peripheral != servicePeripheral) {
        NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    if ([error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    //NSData*转NSString* 
    NSString *hexStr = [self stringFromData:characteristic.value];
    //规避
    if ([hexStr hasPrefix:@"00"]||[hexStr hasPrefix:@"d3"]) {
        return;
    }
    //判断吸烟时间的起止
    if ([hexStr hasPrefix:@"85"]) {
        [S_USER_DEFAULTS setBool:NO forKey:@"BlueToothIsFirstLaunch"];
        [S_USER_DEFAULTS synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POWER_SHOW object:[DateTimeHelper subStringWith16Sys:hexStr]];
        if ([DateTimeHelper isNoLoad:hexStr]) {
            return;
        }
        //设置蓝牙第一次启动标识
        [S_USER_DEFAULTS setBool:YES forKey:@"BlueToothIsFirstLaunch"];
        [S_USER_DEFAULTS synchronize];
        //记录数据
        [[LocalStroge sharedInstance].dateArr removeAllObjects];
        [DateTimeHelper isNowTheTimeFrom16Sys:[DateTimeHelper stringByReversed:[hexStr substringWithRange:NSMakeRange(4, 10)]]];
    }
    if ([hexStr hasPrefix:@"8a"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LIGHT_SHOW object:[DateTimeHelper subStringWith16Sys:hexStr]];
        //消除掉一开始启动时就传了两次16进制的数值
        BOOL isFirstLaunch = [S_USER_DEFAULTS boolForKey:@"BlueToothIsFirstLaunch"];
        if (!isFirstLaunch) {
            return;
        }
        //排序入库
        [DateTimeHelper isNowTheTimeFrom16Sys:[DateTimeHelper stringByReversed:[hexStr substringWithRange:NSMakeRange(4, 10)]]];
        _dateIndex = [[LocalStroge sharedInstance] dataSorting];
        if (_dateIndex < 0) {
            _dateIndex = 0;
        }
        //定位(蓝牙信号是先传现在的，再传之前的信号。)
        NSMutableArray *arr = [[[[S_ALL_SMOKING objectAtIndex:_dateIndex]objectForKey:F_SCHEDULE]lastObject]objectForKey:F_PLACE];
        if (![arr count]) {
            [[UsersLocation sharedInstance] startPositioning];
        }
        //发送通知（更新界面）
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SCHEDULE_ADD object:nil];
    }
    NSLog(@"蓝牙发来讯号：%@", hexStr);
}

- (NSString *) stringFromData:(NSData *)data
{
    //NSData转NSString *
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
    /* write data */
 
}
@end


