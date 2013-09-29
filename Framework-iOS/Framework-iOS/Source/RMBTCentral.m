//
//  RMBTCentral.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/05.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "RMBTCentral.h"
#import "RMLog.h"
#import "DefConst.h"

#define TIME_INTERVAL 10

@implementation RMBTCentral{
    NSString *notifyResult;
    NSTimer *aTimer;
    int notifyReceiveIndex;
    int ackTimeOut;
    bool isReceiveError;
    bool isWriting;
}

@synthesize idCentral;
@synthesize peripherals;

#pragma mark life cycle
- (void) dealloc
{
    _delegate = nil;
    [_cManager release];
    [_peripheral release];
    [peripherals release];
    [idCentral release];
    
    [super dealloc];
}

#pragma mark public methods
- (id) initWithDelegate:(id<RMBTCentralDelegate>)delegate centralId:(NSString*)centralId
{
    self = [super init];
    if(self){
        //TODO: queus = nil means this runs on main thread. specify other if needed
        self.cManager = [[[CBCentralManager alloc]initWithDelegate:self queue:nil]autorelease];
        self.delegate = delegate;
        self.idCentral = centralId;
        self.peripherals = [NSMutableArray array];
        
        isWriting = false;
        ackTimeOut = 5;
    }
    return self;
}

- (void) setTimeOutToAck:(int)timeout
{
    ackTimeOut = timeout;
}

- (void) writeDataToPeriperal:(NSData*)data
{
    [self writeDataToPeriperal:data withPrefixOf:AN withAck:YES];
}

- (void) connectToPeripheral:(int)index
{
    
    // Stop scan
    [self.cManager stopScan];
    
    self.peripheral = [peripherals objectAtIndex:index];
    
    // CBConnectPeripheralOptionNotifiyOnDisconnectionKey can be set as option and yes shows alert when BT is disconnected when in background operation
    [self.cManager connectPeripheral:self.peripheral options:nil];
}

- (void) disconnectFromPeripheral
{
    // Let peripheral know disconnection
    NSData *data = [idCentral dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataToPeriperal:data withPrefixOf:CD withAck:NO];
    
    if(self.peripheral != nil){
        [self.cManager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil;
    }
}

- (NSArray*) getListOfPeripheralsFound
{
    NSMutableArray *result = [NSMutableArray array];
    for (CBPeripheral *peripheral in peripherals){
        if (peripheral.name != nil){
            [result addObject:peripheral.name];
        }
    }
    return result;
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

- (void) stopScan
{
    [self.cManager stopScan];
}

#pragma mark internal methods
- (void) writeDataToPeriperal:(NSData*)data withPrefixOf:(NSString*)prefix withAck:(BOOL)withAck
{
    if(self.characteristic != NULL){
        
        if(!isWriting){
        
            NSString *str= [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
            NSString *result = [NSString stringWithFormat:@"%@>%@&%@", prefix, str, idCentral];
            NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
            
            [self.peripheral writeValue:resultData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
            [self logCat:@"Write value to peripheral"];
         
            isWriting = false;
            
            if(withAck){
                [self startTimer];
            }
            
        }
        
    }
}

- (void) sendAckToNotify
{
    NSData *data = [idCentral dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataToPeriperal:data withPrefixOf:AK withAck:NO];
}

- (void) sendIdToPeripheral
{
    NSData *data = [idCentral dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataToPeriperal:data withPrefixOf:ID withAck:YES];
}

- (void) receivedNotification:(NSString*)strReceived
{
    if([strReceived hasPrefix:DC]){
        
        [self disconnectFromPeripheral];
        [_delegate centralDisconnectedFromPeripheral];
        
    }else if([strReceived hasPrefix:WA]){
        
        [_delegate centralReceivedDataFromPeripheral:strReceived];
        
        [self logCat:@"ackReceived"];
        [self stopTimer];
        isWriting = false;
        [self sendAckToNotify];
        
    }else {
        
        [_delegate centralReceivedDataFromPeripheral:strReceived];
        [self sendAckToNotify];
    
    }

}

#pragma mark CBCentralManager delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: start cnetral"]autorelease];
    [self logCat:log];
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self logCat:@"Central Manager is ready"];
            [self startScan];
            break;
        default:
            [self logCat:@"Central Manager not ready"];
            break;
    }
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
        
        if(![peripherals containsObject:peripheral]){
            [peripherals addObject:peripheral];
             [_delegate centralFoundPeripheral];
        }
        
    }else{
        NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: unknown service found %@", advertisementData]autorelease];
        [self logCat:log];
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self logCat:@"did connect peripheral"];
    [peripheral setDelegate:self];
    [peripheral discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:SERVICE_UUID1]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if(error != NULL){
        [_delegate centralError:[NSString stringWithFormat:@"%@", error]];
    }
}

#pragma mark CBPeripheral delegate
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    if(error != NULL){
        [_delegate centralError:[NSString stringWithFormat:@"%@", error]];
    }
    
    NSArray *services = peripheral.services;
    NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: services count:%d", [services count]]autorelease];
    [self logCat:log];
    
    for (CBService *service in services){
        NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: Service found with UUID: %@", service.UUID]autorelease];
        [self logCat:log];
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if(error != NULL){
        [_delegate centralError:[NSString stringWithFormat:@"%@", error]];
    }
    
    // Set Notify
    for(CBCharacteristic *characteristic in service.characteristics){
        if(characteristic.properties &(CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicateEncryptionRequired)){
            NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: subscribe to service:%@, characteristic:%@", service.UUID, characteristic.UUID]autorelease];
            [self logCat:log];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }else{
            NSString *log = [[[NSString alloc]initWithFormat:@"CENTRAL: characteristics Discovered.Service:%@, Characteristic:%@", service.UUID, characteristic.UUID]autorelease];
            [self logCat:log];
            
            self.characteristic = characteristic;
            
            [self sendIdToPeripheral];
                        
        }
    }
        
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if(error != NULL){
        [_delegate centralError:[NSString stringWithFormat:@"%@", error]];
    }
    
    NSString *receivedString = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]autorelease];
    
    if ([receivedString hasPrefix:@"00:"]){
        notifyReceiveIndex = 1;
        isReceiveError = false;
        notifyResult = [[receivedString substringFromIndex:3]retain];
    }else if([receivedString hasPrefix:[NSString stringWithFormat:@"%02d:", notifyReceiveIndex]]){
        notifyResult = [[NSString stringWithFormat:@"%@%@", notifyResult, [receivedString substringFromIndex:3]]retain];
        if(notifyReceiveIndex < 100){
            notifyReceiveIndex ++;
        }else{
            notifyReceiveIndex = 0;
        }
    }else if([receivedString isEqualToString:NOTIFY_END_TAG]){
        if(isReceiveError){
            [self logCat:@"error while receiving notifycation"];
        }else{
            [self logCat:notifyResult];
            [self receivedNotification:notifyResult];
        }
        notifyResult = nil;
        notifyReceiveIndex = 0;
    }else{                                  //Error case
        notifyResult = nil;
        notifyReceiveIndex = 0;
        isReceiveError = true;
    }

}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error != NULL){
        [_delegate centralError:[NSString stringWithFormat:@"%@", error]];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    [_delegate centralDisconnectedFromPeripheral];
    
}

#pragma mark timer
-(void)startTimer
{
    if (aTimer) {
        [self stopTimer];
    }
    aTimer = [NSTimer scheduledTimerWithTimeInterval:ackTimeOut
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:NO];
}

-(void)stopTimer
{
    [aTimer invalidate];
    aTimer = nil;
}

-(void)tick:(NSTimer*)theTimer
{
    [self disconnectFromPeripheral];
    [self logCat:@"ack not received. disconnect from peripheral"];
    isWriting = false;
}


#pragma mark for development
- (void) logCat:(NSString*)logText
{
    [RMLog log:self message:logText];
    [self.delegate logCentral:logText];
}


@end
