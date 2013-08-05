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
- (void)foo;
@optional
- (void)bar;
@end

@interface RMBTCentral : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id<RMBTCentralDelegate> delegate;
@property (nonatomic, strong) CBCentralManager *cManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

- (id) initWithDelegate:(id<RMBTCentralDelegate>)delegate;

@end
