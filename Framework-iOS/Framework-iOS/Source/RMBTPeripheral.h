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
- (void) peripheralConnectedWithCentrals:(NSArray*)idCentrals;
- (void) peripheralIsDisconnected:(NSString*)idCentral;
@optional
- (void) logPeripheral:(NSString*)logText;
@end

/**
 * Bluetooth peripheral managemen t class
 *
 */
@interface RMBTPeripheral : NSObject<CBPeripheralManagerDelegate>

///@property delegate delegate to this class
@property (nonatomic, strong) id<RMBTPeripheralDelegate> delegate;

///@property idPeripheral ID of this peripheral in NSString
@property (nonatomic, strong) NSString *idPeripheral;

//@property pManager CBMutableManager
@property (nonatomic, strong) CBPeripheralManager *pManager;

//@property service_01 service
@property (nonatomic, strong) CBMutableService *service_01;

//@property characteristic_01 characteristic used for notify
@property (nonatomic, strong) CBMutableCharacteristic *characteristic_01;

//@property characteristic_01 characteristic used for write
@property (nonatomic, strong) CBMutableCharacteristic *characteristic_02;

//@property centrals Centrals connected to this peripheral manager
@property (nonatomic, strong) NSMutableDictionary *centrals;

//@property arrayTargetCentral targetCentrasls id
@property (nonatomic, strong) NSArray *arrayTargetCentral;

//@property notifyResult result of notification holding if ack is received to notifycation
@property (nonatomic, strong) NSMutableDictionary *notifyResult;

/**
 * Initialize RMBTPeripheral
 *
 * @param delegate Set delegate to receive call back
 * @param peripheralId Used to communicate with Central. Set User ID is one example.
 * @return RMBTPeripheral class instance
 */
- (id) initWithDelegate:(id<RMBTPeripheralDelegate>)delegate peripheralId:(NSString*)peripheralId;

/**
 * setTimeOutAck
 *
 * @param timeout set time out to receive ack when notifying data in sec
 */
- (void) setTimeOutToAck:(int)timeout;

/**
 * Send notifycation to all centrals connected
 *
 * @param data data to be sent
 * @return void
 */
- (void) sendMesasgeToAllCentral:(NSData*) data;

/**
 * Send notifycation to all centrals connected
 *
 * @param centralId of target that data is to send
 * @param data data to be sent
 * @return void
 */
- (void) sendMessageTo:(NSString*)centralId message:(NSData*) data;

/**
 * Set timeout for acknowledge
 *
 * @param timeOut Defines time out to wait acknowledge to notify in sec
 * @return void
 */
- (void) setAcknowledgeTimeout:(int) timeOut;

/**
 * Returns id of this peripheral
 *
 * @param
 * @return NSString of id
 */
- (NSString *) getIdOfPeripheral;

/**
 * Returns list of centrals connected to this peripheral
 *
 * @param
 * @return NSArray of centrals id in NSString
 */
- (NSArray*) getListOfCentrals;

@end
