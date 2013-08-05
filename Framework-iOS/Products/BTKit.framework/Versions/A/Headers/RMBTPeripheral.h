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
- (void)foo;
@optional
- (void)bar;
@end

@interface RMBTPeripheral : NSObject<CBPeripheralManagerDelegate>

@property (nonatomic, strong) id<RMBTPeripheralDelegate> delegate;
@property (nonatomic, strong) CBPeripheralManager *pManager;
@property (nonatomic, strong) CBMutableService *service_01;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic_01;

- (id) initWithDelegate:(id<RMBTPeripheralDelegate>)delegate;
- (void) notifyData:(NSData*)data;

@end
