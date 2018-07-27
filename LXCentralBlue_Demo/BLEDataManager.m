//
//  BLEDataManager.m
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "BLEDataManager.h"
#import "CBPeripheral+Extension.h"
#import "DTBLEManager.h"

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


- (BOOL)selectPeripheralAtIndex:(NSInteger)index {
    if (self.peripherals.count > index) {
        _currentPeripheral = self.peripherals[index];
        return YES;
    }
   
    return NO;
}


- (CBCharacteristic *)characteristicOfUUIDString:(NSString *)UUIDString {
    if (!_currentPeripheral.isConnected || UUIDString.length == 0) {
        return nil;
    }
    __block CBCharacteristic *ch = nil;
    [_currentPeripheral.discoveredService.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.UUID.UUIDString isEqualToString:UUIDString]) {
            ch = obj;
            *stop = YES;
        }
    }];
    
    return ch;
}

- (void)connectPeriperal:(CBPeripheral *)peripheral block:(void(^)(CBPeripheral *peripheral,NSError *error))block {
    if (![self.peripherals containsObject:peripheral]) {
        NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_parameterError userInfo:@{@"mag":@"错误的外设"}];
        block(nil,error);
        return;
    }
    else {
        _currentPeripheral = peripheral;
    }
    weakSelf(weakSelf)
    [[DTBLEManager shareManager] connectPeripheral:peripheral option:nil block:^(CBPeripheral *peripheral, NSError *error) {
        if (error || peripheral == nil) {
            if (block) {
                block(peripheral,error);
            }
            return ;
        }
        CBUUID *uuid = [CBUUID UUIDWithString:@"FFF0"];
        [weakSelf discoverServices:@[uuid] block:^(CBPeripheral *peripheral, NSError *error) {
            if (error) {
                if (block) {
                    block(peripheral,error);
                }
                return ;
            }
            __block CBService *service = nil;
            [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.UUID isEqual:uuid]) {
                    service = obj;
                    *stop = YES;
                }
            }];
            
            if (service == nil) {
                NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_parameterError userInfo:@{@"mag":@"没有发现服务"}];
                block(nil,error);
                return;
            }
            peripheral.discoveredService = service;
            [weakSelf.currentPeripheral discoverCharacteristics:nil forService:service block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
                if (block) {
                    block(peripheral,error);
                }
            }];
        }];
    }];
}

- (void)connectPeriperalAtIndex:(NSInteger)index block:(void(^)(CBPeripheral *peripheral,NSError *error))block {
    if (self.peripherals.count > index) {
        CBPeripheral *peripheral = self.peripherals[index];
        [self connectPeriperal:peripheral block:block];
    }
    else {
        if (block) {
            NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_parameterError userInfo:@{@"mag":@"index超出范围"}];
            block(nil,error);
        }
    }
}


- (void)discoverServices:(NSArray <CBUUID *>*)serviceUUIDs block:(void(^)(CBPeripheral *peripheral,NSError *error))block {
    if (_currentPeripheral == nil) {
        NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_parameterError userInfo:@{@"mag":@"没有当前的外设"}];
        if (block) {
            block(nil,error);
        }
        return;
    }
    [_currentPeripheral discoverServices:serviceUUIDs block:block];
}



@end
