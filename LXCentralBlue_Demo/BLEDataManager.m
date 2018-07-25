//
//  BLEDataManager.m
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "BLEDataManager.h"

@implementation BLEDataManager

+ (instancetype)shareManager {
    static BLEDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BLEDataManager alloc] init];
    });
    return instance;
}

- (void)setPeripherals:(NSArray *)peripherals {
    _peripherals = peripherals;
    if (![peripherals containsObject:_currentPeripheral]) {
        _currentPeripheral = nil;
    }
}


- (BOOL)selectPeripheral:(CBPeripheral *)peripheral {
    if ([self.peripherals containsObject:peripheral]) {
        _currentPeripheral = peripheral;
        return YES;
    }
    return NO;
}


@end
