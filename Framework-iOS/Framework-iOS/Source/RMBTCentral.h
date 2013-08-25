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
- (void) centralError:(NSString*)errorMsg;
- (void) cannotFindServiceError;
- (void) peripheralFound;
- (void) receivedDataFromPeripheral:(NSString*)strSdata;
- (void) disconnectedFromPeripheral;
@optional
- (void) logCentral:(NSString*)logText;
@end

/**
 * Bluetooth central management class
 *
 */
@interface RMBTCentral : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

///@property delegate delegate to this class
@property (nonatomic, strong) id<RMBTCentralDelegate> delegate;

///@property idCentral id of this central
@property (nonatomic, strong) NSString *idCentral;

///@property cManager CBCentralManager 
@property (nonatomic, strong) CBCentralManager *cManager;
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

/**
 * Initialize RMBTCentral
 *
 * @param delegate Set delegate to receive call back
 * @param centralId Used to communicate with Peripheral
 * @return RMBTCentral class instance
 */
- (id) initWithDelegate:(id<RMBTCentralDelegate>)delegate centralId:(NSString*)centralId;

/**
 * setTimeOutAck
 *
 * @param timeout set time out to receive ack when notifying data in sec
 */
- (void) setTimeOutToAck:(int)timeout;

/**
 * Write data to peripheral
 *
 * @param data data to be sent to peripheral
 */
- (void) writeDataToPeriperal:(NSData*)data;

/**
 * connect to target peripheral
 *
 * @param index index of target peripheral to be connected. Index corresponds to NSArray returned by getListOfPeripheralsFound
 */
- (void) connectToPeripheral:(int)index;

/**
 * Disconnect from peripheral connected
 */
- (void) disconnectFromPeripheral;

/**
 * get list of peripherals found
 * 
 * @return Peripherals found
 */
- (NSArray*) getListOfPeripheralsFound;

/**
 * Disconnect from peripheral connected
 */
- (void) startScan;

/**
 * Stop scanning for peripheral
 */
- (void) stopScan;

@end
