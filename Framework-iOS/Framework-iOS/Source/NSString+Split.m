//
//  NSString+Split.m
//  Framework-iOS
//
//  Created by 都筑 友昭 on 2013/08/19.
//  Copyright (c) 2013年 DB-Interactive. All rights reserved.
//

#import "NSString+Split.h"

@implementation NSString (Split)

- (NSArray *)splitCharacterEvery:(NSUInteger)number
{
    if ([self length] <= number) {
        return @[self];
    }
    
    NSMutableArray  *mArray = [NSMutableArray new];
    NSMutableString *mStr   = [NSMutableString stringWithString:self];
    
    NSRange range = NSMakeRange(0, number);
    
    while ([mStr length] > 0) {
        if ([mStr length] < number) {
            [mArray addObject:[NSString stringWithString:mStr]];
            [mStr deleteCharactersInRange:NSMakeRange(0, [mStr length])];
        }
        else {
            [mArray addObject:[mStr substringWithRange:range]];
            [mStr deleteCharactersInRange:range];
        }
    }
    
    return [NSArray arrayWithArray:mArray];
}

@end
