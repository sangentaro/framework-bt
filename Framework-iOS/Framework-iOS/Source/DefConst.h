//
//  DefConst.h
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/20.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVICE_UUID1        @"4C4EAD56-3AA2-43A3-B864-4C635573AEB8"
#define CHARACTERISTIC_UUID1 @"892757EF-D943-43C2-B079-F66442CF069C"
#define CHARACTERISTIC_UUID2 @"8F455344-490F-4693-A53B-923F2C0EC2E4"

// prefix for data transfer from central to peripheral
#define AK @"AK:" //Ack to notify
#define ID @"ID:" //Send id to peripheral
#define AN @"AN:" //Any data
#define CD @"CD:" //Central disconnect

// prefix for data transfer from peripheral to central
#define DC @"DC:" //Ask disconnect to central
#define WA @"WA:" //Ack to write from central to peripheral

// notify data tag
#define NOTIFY_END_TAG       @"::ned"

@interface DefConst : NSObject

@end
