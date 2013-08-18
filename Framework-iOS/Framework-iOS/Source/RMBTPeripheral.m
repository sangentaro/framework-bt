//
//  BTPeripheral.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/05.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "RMBTPeripheral.h"
#import "RMLog.h"
#import "NSString+Split.h"

#define SERVICE_UUID1        @"4C4EAD56-3AA2-43A3-B864-4C635573AEB8"
#define CHARACTERISTIC_UUID1 @"892757EF-D943-43C2-B079-F66442CF069C"
#define CHARACTERISTIC_UUID2 @"8F455344-490F-4693-A53B-923F2C0EC2E4"

#define NOTIFY_END_TAG       @"::ned"

@implementation RMBTPeripheral
{
    int packetIndex;
    NSData *mainData;
    NSString *range;
}

@synthesize idPeripheral;

#pragma mark life cycle
- (void) dealloc
{
    self.delegate = nil;
    
    [_pManager release];
    [_service_01 release];
    [_characteristic_01 release];
    [idPeripheral release];
    
    [super dealloc];
}

#pragma mark public methods
- (id) initWithDelegate:(id<RMBTPeripheralDelegate>)delegate peripheralId:(NSString*)peripheralId
{
    
    self = [super init];
    if(self){
        // TODO: queue = nill means it runs on main thread. specify any thread if required
        self.pManager = [[[CBPeripheralManager alloc]initWithDelegate:self queue:nil]autorelease];
        self.delegate = delegate;
        self.idPeripheral = peripheralId;
    }
    
    return self;
}

- (void) notifyData:(NSData*)data
{
    NSString *str= [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
    
    int index = 0;
    NSString *result = @"";
    NSArray *strArray = [str splitCharacterEvery:17];
    for (NSString *splitedString in strArray) {
        result = [NSString stringWithFormat:@"%@%@%@",result, [NSString stringWithFormat:@"%02d:", index], splitedString];
        index ++;
    }
    
    mainData = [result dataUsingEncoding:NSUTF8StringEncoding];
    [self notifyingData];
}

# pragma mark helper for notifyData
- (void) notifyingData
{
    
    while ([self hasData]) {
        if([self.pManager updateValue:[self getNextData] forCharacteristic:self.characteristic_01 onSubscribedCentrals:nil]){
            [self ridData];
        }else{
            [self logCat:@"No Data to send"];
            return;
        }
    }
    [self updateValueFromString:NOTIFY_END_TAG];
}

- (void) peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    [self notifyingData];
}

- (BOOL)hasData
{
    if ([mainData length]>0) {        
        return YES;
    }else{
        range = nil;
        return NO;
    }
}

- (void) updateValueFromString:(NSString*)value
{
    NSString *stra = value;
    NSData *dataa = [stra dataUsingEncoding:NSUTF8StringEncoding];
    [self.pManager updateValue:dataa forCharacteristic:self.characteristic_01 onSubscribedCentrals:nil];
}

- (void)ridData{
    if ([mainData length]>19) {
        mainData = [[mainData subdataWithRange:NSRangeFromString(range)]retain];
    }else{
        mainData = nil;
    }
}

- (NSData *)getNextData
{
    NSData *data;
    if ([mainData length]>19) {
        int datarest = [mainData length]-20;
        data = [mainData subdataWithRange:NSRangeFromString(@"{0,20}")];
        range = [NSString stringWithFormat:@"{20,%i}",datarest];
    }else{
        int datarest = [mainData length];
        range = [NSString stringWithFormat:@"{0,%i}",datarest];
        data = [mainData subdataWithRange:NSRangeFromString(range)];
    }
    return data;
}

- (void) initManager
{
    // Create service
    CBUUID *service_uuid1 = [CBUUID UUIDWithString:SERVICE_UUID1];
    self.service_01 = [[[CBMutableService alloc]initWithType:service_uuid1 primary:YES]autorelease];
    
    // Create characteristic implemented in the service
    CBUUID *characteristic_uuid1 = [CBUUID UUIDWithString:CHARACTERISTIC_UUID1];
    self.characteristic_01 = [[[CBMutableCharacteristic alloc]initWithType:characteristic_uuid1
                                                               properties:CBCharacteristicPropertyNotify
                                                                    value:nil
                                                              permissions:CBAttributePermissionsReadable]autorelease];
    
    // Create characteristic implemented in the service
    CBUUID *characteristic_uuid2 = [CBUUID UUIDWithString:CHARACTERISTIC_UUID2];
    self.characteristic_02 = [[[CBMutableCharacteristic alloc]initWithType:characteristic_uuid2
                                                                properties:CBCharacteristicPropertyWrite
                                                                     value:nil
                                                               permissions:CBAttributePermissionsWriteable]autorelease];
    
    // Set characteristic to service
    [self.service_01 setCharacteristics:@[self.characteristic_01, self.characteristic_02]];
    
    // Add service to peripheral
    [self.pManager addService:self.service_01];
}

- (void) startAdvertize
{
    [self initManager];
    
    // Create data to be advertized
    NSArray *serviceUUIDs = @[[CBUUID UUIDWithString:SERVICE_UUID1]];
    NSDictionary *advertiseDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   serviceUUIDs, CBAdvertisementDataServiceUUIDsKey,
                                   self.idPeripheral, CBAdvertisementDataLocalNameKey,
                                   nil];
    
    // Start advertizement
    [self.pManager startAdvertising:advertiseDict];
    NSString *log = [[[NSString alloc]initWithFormat:@"PERIPHERAL: start advertize:%@", advertiseDict]autorelease];
    [self logCat:log];
}

# pragma mark peripheral manager delegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self startAdvertize];
            break;
        default:
            [self logCat:@"Central Manager not ready"];
            break;
    }
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    [self logCat:@"did recieve write data"];
    for (CBATTRequest *aReq in requests){
        [self logCat:[[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]];
        [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
    }
}

#pragma mark for development
- (void) logCat:(NSString*)logText
{
    [RMLog log:self message:logText];
    [self.delegate logPeripheral:logText];
}

@end
