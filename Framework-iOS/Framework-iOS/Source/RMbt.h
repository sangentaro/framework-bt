//
//  RMbt.h
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/07/14.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol BlueToothConnectionDelegate
- (void) btConnected:(NSString*)peerId;
- (void) btMsgReceived:(NSString*)msg;
@end

@interface RMbt : NSObject<GKSessionDelegate>

@property (assign, nonatomic) id<BlueToothConnectionDelegate> delegate;

- (void) initializeBluetooth;
- (void) sendData:(NSString*)strData peerId:(NSString*)peerId;

@end
