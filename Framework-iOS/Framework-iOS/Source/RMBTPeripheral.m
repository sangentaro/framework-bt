//
//  BTPeripheral.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/05.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "RMBTPeripheral.h"

#define SERVICE_UUID1 @"4C4EAD56-3AA2-43A3-B864-4C635573AEB8"
#define CHARACTERISTIC_UUID1 @"892757EF-D943-43C2-B079-F66442CF069C"

@implementation RMBTPeripheral

@synthesize idPeripheral;

- (void) dealloc
{
    self.delegate = nil;
    
    [_pManager release];
    [_service_01 release];
    [_characteristic_01 release];
    [idPeripheral release];
    
    [super dealloc];
}

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

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self startAdvertize];
            break;
        default:
            NSLog(@"Peripheral Manager did change state");
            break;
    }
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
    
    // Set characteristic to service
    [self.service_01 setCharacteristics:@[self.characteristic_01]];
    
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
    NSLog(@"start advertize, %@", advertiseDict);
}

/////////////*
//Public method
////////////*/
- (void) notifyData:(NSData*)data
{
    // Send data to central
    BOOL result = [self.pManager updateValue:data
                           forCharacteristic:self.characteristic_01
                        onSubscribedCentrals:nil];
    NSLog(@"notify data:%@, result:%d", data, result);
}

@end
