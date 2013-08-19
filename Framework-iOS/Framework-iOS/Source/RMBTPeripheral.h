//
//  BTPeripheral.h
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/05.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol RMBTPeripheralDelegate
@required
- (void)ackNotReceived;
@optional
- (void)logPeripheral:(NSString*)logText;
@end

@interface RMBTPeripheral : NSObject<CBPeripheralManagerDelegate>

@property (nonatomic, strong) id<RMBTPeripheralDelegate> delegate;
@property (nonatomic, strong) CBPeripheralManager *pManager;
@property (nonatomic, strong) CBMutableService *service_01;
@property (nonatomic, strong) CBMutableService *service_02;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic_01;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic_02;
@property (nonatomic, strong) NSString *idPeripheral;
@property (nonatomic, strong) NSMutableArray *centrals;

- (id) initWithDelegate:(id<RMBTPeripheralDelegate>)delegate peripheralId:(NSString*)peripheralId;
- (void) notifyData:(NSData*)data;

@end
