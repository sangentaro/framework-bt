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
    NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: start cnetral"]autorelease];
    [self logCat:log];
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
        NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: iOS in foreground discovered:%@, peripheral.UUID:%@, localName:%@", advertisementData, peripheral.UUID, localName]autorelease];
        [self logCat:log];
        
        // stop scan
        //[self.cManager stopScan];
        
        self.peripheral = peripheral;
        
        // CBConnectPeripheralOptionNotifiyOnDisconnectionKey can be set as option and yes shows alert when BT is disconnected when in background operation
        [self.cManager connectPeripheral:self.peripheral options:nil];
        
    }else{
        NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: unknown service found %@", advertisementData]autorelease];
        [self logCat:log];
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
    NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: services count:%d, %@", [services count], error]autorelease];
    [self logCat:log];
    
    for (CBService *service in services){
        NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: Service found with UUID: %@", service.UUID]autorelease];
        [self logCat:log];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Set Notify
    for(CBCharacteristic *characteristic in service.characteristics){
        if(characteristic.properties &(CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicateEncryptionRequired)){
            NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: subscribe to service:%@, characteristic:%@", service.UUID, characteristic.UUID]autorelease];
            [self logCat:log];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }else{
            NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: characteristics Discovered.Service:%@, Characteristic:%@", service.UUID, characteristic.UUID]autorelease];
            [self logCat:log];
        }
    }
}

// Operation when recieving notification
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *receivedString = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]autorelease];
    NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: UpdateValue.Service:%@, Characteristic:%@, request value%@",
                      characteristic.service.UUID,
                      characteristic.UUID,
                      receivedString]autorelease];
    [self logCat:log];
}

#pragma mark for development
- (void) logCat:(NSString*)logText
{
    NSLog(@"%@", logText);
    [self.delegate logCentral:logText];
}


@end
