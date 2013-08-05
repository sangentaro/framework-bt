//
//  RMBTCentral.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/05.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "RMBTCentral.h"

#define SERVICE_UUID1 @"4C4EAD56-3AA2-43A3-B864-4C635573AEB8"
#define CHARACTERISTIC_UUID1 @"892757EF-D943-43C2-B079-F66442CF069C"

@implementation RMBTCentral

@synthesize idCentral;

- (void) dealloc
{
    _delegate = nil;
    [_cManager release];
    [_peripheral release];
    [idCentral release];
    
    [super dealloc];
}

- (id) initWithDelegate:(id<RMBTCentralDelegate>)delegate centralId:(NSString*)centralId
{
    self = [super init];
    if(self){
        //TODO: queus = nil means this runs on main thread. specify other if needed
        self.cManager = [[[CBCentralManager alloc]initWithDelegate:self queue:nil]autorelease];
        self.delegate = delegate;
        self.idCentral = centralId;
    }
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
            [self startScan];
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

- (void) startScan
{
    
#ifdef CBScannerAllowDuplicates
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
#else
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
#endif
    [self.cManager scanForPeripheralsWithServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:SERVICE_UUID1], nil] options:options];
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSArray *services = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    if([services containsObject:[CBUUID UUIDWithString:SERVICE_UUID1]]){
        /* Peripheral is in foreground */
        // serviceUUIDs has UUID that service advertizes
        NSLog(@"iOS in foreground discovered:%@, peripheral.UUID:%@, localName:%@", advertisementData, peripheral.UUID, localName);
        
        // stop scan
        //[self.cManager stopScan];
        
        self.peripheral = peripheral;
        
        // CBConnectPeripheralOptionNotifiyOnDisconnectionKey can be set as option and yes shows alert when BT is disconnected when in background operation
        [self.cManager connectPeripheral:self.peripheral options:nil];
        
    }else{
        NSLog(@"unknown service found %@", advertisementData);
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:SERVICE_UUID1]]];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = peripheral.services;
    NSLog(@"services count:%d, %@", [services count], error);
    for (CBService *service in services){
        NSLog(@"Service found with UUID: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Set Notify
    for(CBCharacteristic *characteristic in service.characteristics){
        if(characteristic.properties &(CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicateEncryptionRequired)){
            NSLog(@"subscribe to service:%@, characteristic:%@", service.UUID, characteristic.UUID);
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }else{
            NSLog(@"characteristics Discovered.Service:%@, Characteristic:%@", service.UUID, characteristic.UUID);
        }
    }
}

// Operation when recieving notification
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *receivedString = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]autorelease];
    NSLog(@"UpdateValue.Service:%@, Characteristic:%@, request value%@",
          characteristic.service.UUID,
          characteristic.UUID,
          receivedString);
}

@end