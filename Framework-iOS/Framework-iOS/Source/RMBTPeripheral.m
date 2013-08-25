//
//  BTPeripheral.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/05.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "RMBTPeripheral.h"
#import "RMLog.h"
#import "DefConst.h"
#import "NSString+Split.h"

@implementation RMBTPeripheral
{
    @protected
    int packetIndex;
    int ackTimeOut;
    bool notifying;
    NSData *mainData;
    NSString *range;
    NSTimer *aTimer;
}

#pragma mark life cycle
- (void) dealloc
{
    self.delegate = nil;
    
    [self stopTimer];
    
    [_pManager release];
    [_service_01 release];
    [_characteristic_01 release];
    [_centrals release];
    [_idPeripheral release];
    [_arrayTargetCentral release];
    [_notifyResult release];
    
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
        self.centrals = [NSMutableDictionary dictionary];
        self.notifyResult = [NSMutableDictionary dictionary];
        notifying = false;
        
        ackTimeOut = 5;
        
    }
    
    return self;
}

- (void) setTimeOutToAck:(int)timeout
{
    ackTimeOut = timeout;
}

- (void) sendMesasgeToAllCentral:(NSData*) data
{
    [self sendMessageTo:nil message:data];
}

- (void) sendMessageTo:(NSString*)centralId message:(NSData*) data;
{
    [self sendMessageTo:centralId message:data withTimer:true];
}

- (void) setAcknowledgeTimeout:(int) timeOut
{
    ackTimeOut = timeOut;
}

- (NSString *) getIdOfPeripheral
{
    return _idPeripheral;
}

- (NSArray *) getListOfCentrals
{
    if([_centrals count] > 0){
        NSMutableArray *array = [NSMutableArray array];
        for (NSString* key in _centrals) {
            [array addObject:key];
        }
        return (NSMutableArray*)array;
    }else{
        return nil;
    }
}

# pragma mark private method
- (void) sendMessageTo:(NSString*)centralId message:(NSData*) data withTimer:(BOOL)withTimer;
{
    
    // update notify result
    [_notifyResult removeAllObjects];
    
    // if sending message to all centrals, centralId should be nil
    if(centralId != nil){
        
        // Set target central to check acknowledgement
        [_notifyResult setObject:@"NO" forKey:centralId];
        CBCentral *targetCentral = [_centrals objectForKey:centralId];
        
        _arrayTargetCentral = [NSArray arrayWithObjects:targetCentral, nil];
        
    }else{
        
        // Set target centrals to check acknowledgement
        NSArray *centralIds = [self getListOfCentrals];
        if(centralIds != nil){
            for(NSString *centralId in centralIds){
                [_notifyResult setObject:@"NO" forKey:centralId];
            }
        }
        _arrayTargetCentral = nil;
    }
    
    if(!notifying){
        
        mainData = [self prepareDataForNotify:data];
        
        [self notifyingData];
        notifying = true;
        
        if(withTimer){
            [self startTimer];
        }
    }
}

# pragma mark helper for notifyData
- (NSData*) prepareDataForNotify:(NSData*)data
{
    
    NSString *str= [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
    
    int index = 0;
    NSString *result = @"";
    NSArray *strArray = [str splitCharacterEvery:17];
    for (NSString *splitedString in strArray) {
        result = [NSString stringWithFormat:@"%@%@%@",result, [NSString stringWithFormat:@"%02d:", index], splitedString];
        if(index < 100){
            index ++;
        }else{
            index = 0;
        }
    }
    
    return [result dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) notifyingData
{
    
    while ([self hasData]) {
        if([self.pManager updateValue:[self getNextData] forCharacteristic:self.characteristic_01 onSubscribedCentrals:_arrayTargetCentral]){
            [self ridData];
        }else{
            [self logCat:@"sending data"];
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

- (NSData *) getNextData
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

- (BOOL) isReceivedAckFromAll
{
    BOOL ackStatus = YES;
    for (NSString* key in _notifyResult) {
        NSString *ackResult = [_notifyResult objectForKey:key];
        if([ackResult isEqualToString:@"NO"]){
            ackStatus =NO;
        }
    }
    return ackStatus;
}

- (NSArray*) centralsWithoutAck
{
    NSMutableArray *centralsWithoutAck = [NSMutableArray array];
    for (NSString* key in _notifyResult) {
        NSString *ackResult = [_notifyResult objectForKey:key];
        if([ackResult isEqualToString:@"NO"]){
            [centralsWithoutAck addObject:key];
        }
    }
    return centralsWithoutAck;
}

# pragma mark CBPeripheral manager initialize
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
    NSString *receivedString = @"";
    for (CBATTRequest *aReq in requests){
        NSString *stringInRequest = [[[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]autorelease];
        receivedString = [[NSString stringWithFormat:@"%@%@", receivedString, stringInRequest]retain];
        [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
    }
    
    [self logCat:receivedString];
    
    NSString *prefix = [receivedString substringToIndex:3];
    NSString *idString = [receivedString substringFromIndex:3];
    CBATTRequest *request = requests[0];
    CBCentral *central = request.central;
    
    // Case for Acknowledgement recieve
    if([prefix isEqualToString:AK]){
        if(notifying){
            
            [self logCat:[NSString stringWithFormat:@"notify from %@ acknowledged", idString]];
            
            //check if key with idString wxists
            if ([[_notifyResult allKeys] containsObject:idString]) {
                [_notifyResult setObject:@"YES" forKey:idString];
            }else{
                // target central id is not in the target list
                [self stopTimer];
                notifying = false;
                [self logCat:@"targe key not found on the list"];
            }
            
            //Received acks from all of target device
            if([self isReceivedAckFromAll]){
                [self stopTimer];
                notifying = false;
                [self logCat:@"acks from all of the devices are received"];
            }
            
        }
        
    // Case for to connected to central
    }else if([prefix isEqualToString:ID]){
    
        [_centrals setObject:central forKey:idString];
        [_delegate peripheralIsConnected:idString];
        [self logCat:[NSString stringWithFormat:@"%@ is Added", idString]];
    
    }else if([prefix isEqualToString:AN]){
        
    }
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
    
    if([[self getListOfCentrals]count] == 0){
        [self logCat:@"no centrals to send data"];
    }else if([self isReceivedAckFromAll]){
        [self logCat:@"acks from all of the devices are received"];
    }else{
        for(NSString *centralWithoutAck in [self centralsWithoutAck]){
            
            //Send disconnect message
            [self sendMessageTo:centralWithoutAck message:[NSString stringWithFormat:@"%@", DC] withTimer:NO];
            
            //Remove central from list
            [_centrals removeObjectForKey:centralWithoutAck];
            
            [self logCat:[NSString stringWithFormat:@"%@ is disconnected", centralWithoutAck]];
            
        }
    }
    notifying = false;
    [self stopTimer];
}


#pragma mark for development
- (void) logCat:(NSString*)logText
{
    [RMLog log:self message:logText];
    [self.delegate logPeripheral:logText];
}

@end
