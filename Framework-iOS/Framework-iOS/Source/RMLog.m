//
//  RMLog.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/17.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "RMLog.h"

@implementation RMLog

bool isLog = true;

+ (void) log:(NSObject*)obj message:(NSString*)logStr
{
    if(isLog){
        NSLog(@"%@", [NSString stringWithFormat:@"%@:-> %@", NSStringFromClass([obj class]), logStr]);
    }
}

@end
