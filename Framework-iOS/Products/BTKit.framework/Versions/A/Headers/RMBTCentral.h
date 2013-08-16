//
//  RMBTCentral.h
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/05.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol RMBTCentralDelegate
@required
- (void)centralError:(NSString*)errorMsg;
- (void)cannotFindServiceError;
@optional
- (void)logCentral:(NSString*)logText;
@end

@interface RMBTCentral : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id<RMBTCentralDelegate> delegate;
@property (nonatomic, strong) CBCentralManager *cManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) NSString *idCentral;

- (id) initWithDelegate:(id<RMBTCentralDelegate>)delegate centralId:(NSString*)centralId;
- (void) writeDataToPeriperal:(NSData*)data;

@end
