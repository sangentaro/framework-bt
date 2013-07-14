//
//  RMbt.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/07/14.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "RMbt.h"

@implementation RMbt{
    GKSession *mySession;
    int numberConnections;
}

#define kSessionID @"rmbt"
#define RM_BT_APP_ID @"rm_application_identification"

- (void) initializeBluetooth
{
    
    mySession = [[GKSession alloc] initWithSessionID:kSessionID displayName:nil sessionMode:GKSessionModePeer];
	mySession.delegate = self;
	[mySession setDataReceiveHandler:self withContext:nil];
	mySession.available = YES;
    
}

#pragma mark -
#pragma mark GKSessionDelegate

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"Not possible to connetc");
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"something wrong with network");
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	NSLog(@"%@ wants to connect to you", peerID);
    
	NSError *error;
	if(![mySession acceptConnectionFromPeer:peerID error:&error]) {
		NSLog(@"Could yno connect with %@", peerID);
	} else {
		NSLog(@"Connected with %@", peerID);
        
	}
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	switch (state) {
		case GKPeerStateAvailable:
			NSLog(@"Found '%@' and try to connect", peerID);
			[mySession connectToPeer:peerID withTimeout:10.0f];
            [_delegate btConnected:peerID];
			break;
		case GKPeerStateUnavailable:
			NSLog(@"%@ is gone", peerID);
			break;
		case GKPeerStateConnected:
			NSLog(@"Connected with %@", peerID);
            [self sendData:RM_BT_APP_ID peerId:peerID];
			break;
		case GKPeerStateDisconnected:
			NSLog(@"Disconnected with %@", peerID);
			break;
		case GKPeerStateConnecting:
			NSLog(@"Connecting with %@", peerID);
			break;
		default:
			break;
	}
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_delegate btMsgReceived:msg];
}

- (void)sendData:(NSString*)strData peerId:(NSString*)peerId
{
    NSData* data = [strData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error = nil;
    [mySession sendData:data
                toPeers:[NSArray arrayWithObject:peerId]
           withDataMode:GKSendDataReliable
                  error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

@end
