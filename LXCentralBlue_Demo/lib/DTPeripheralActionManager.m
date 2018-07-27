//
//  DTPeripheralNotifyActionManager.m
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DTPeripheralActionManager.h"
#import "CBCharacteristic+Extension.h"


@implementation DTPeripheralActionModel

@end

@interface DTPeripheralActionManager()
@property (nonatomic, strong) NSMutableDictionary *dic;
@end

@implementation DTPeripheralActionManager

- (NSMutableDictionary *)dic {
    if (!_dic) {
        _dic = [[NSMutableDictionary alloc] init];
    }
    
    return _dic;
}

//是否对某个特征进行过监听
- (BOOL)hasObserveForCharatcteristic:(CBCharacteristic *)ch forPeripheral:(CBPeripheral *)peripheral{
    NSString *key = [self keyOfCharacteristic:ch forPeripheral:peripheral];
    if (key.length == 0) {
        return NO;
    }
    
    NSArray *array = [self.dic objectForKey:key];
    return array.count > 0;
}

- (NSString *)keyOfCharacteristic:(CBCharacteristic *)ch forPeripheral:(CBPeripheral *)peripheral {
    if (ch == nil) {
        return @"";
    }
    
    NSString *key = ch.UUID.UUIDString;
    if (peripheral) {
        key = [NSString stringWithFormat:@"%@_%@",key,peripheral.identifier.UUIDString];
    }
    
    return key;
}


- (void)addObserver:(NSObject *)observer forPeripheral:(CBPeripheral *)peripheral forCharacteristic:(CBCharacteristic *)ch type:(DTPeripheralActionType)type block:(DTObserveCharacteristicValueBlock)block {
    if (observer == nil || ch == nil) { //写入时可以没有事件
        return;
    }
    
    NSString *key = [self keyOfCharacteristic:ch forPeripheral:peripheral];;
    if (key.length == 0) {
        return;
    }
    
    NSArray *array = [self.dic objectForKey:key];
    
    BOOL flag = NO;
    for (DTPeripheralActionModel *model in array) { //检查是否已经添加过
        if ([model.observer isEqual:observer]
            && [model.ch isEqual:ch]
            && [model.block isEqual:block]
            && model.type == type) {
            if (peripheral && [model.peripheral.identifier isEqual:peripheral.identifier]) {
                flag = YES;
            }
        }
    }
    
    if (!flag) { //如果没有添加过，就添加事件回调
        DTPeripheralActionModel *model = [[DTPeripheralActionModel alloc] init];
        model.observer =observer;
        model.ch = ch;
        model.block = block;
        model.type = type;
        model.peripheral = peripheral;
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
        [mutableArray addObject:model];
        [self.dic setObject:[mutableArray copy] forKey:key];
    }
}

- (void)cancelObserveForCharacteristic:(CBCharacteristic *)ch forPeripheral:(CBPeripheral *)peripheral{
    if (ch == nil) {
        return;
    }
    NSString *key = [self keyOfCharacteristic:ch forPeripheral:peripheral];
    if (key.length == 0) {
        return;
    }
    
    [self.dic removeObjectForKey:key];
}
//收到数据的处理
- (void)receiveDataWithType:(DTPeripheralRecvType)type characteristic:(CBCharacteristic *)ch forPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (ch == nil) {
        return;
    }
    NSString *key = [self keyOfCharacteristic:ch forPeripheral:peripheral];
    if (key.length == 0) {
        return;
    }
    
    NSArray *array = [self.dic objectForKey:key];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    DTLog(@"----------------------------%ld",array.count);
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DTPeripheralActionModel *model = (DTPeripheralActionModel *)obj;
        DTLog(@"########接收到数据回调时的事件:ch:%@== observer:%@,actionType:%d",model.ch,model.observer,model.type);
        if (!model.observer) {
            DTLog(@"xxxx有观察者销毁了");
            [indexSet addIndex:idx];
        }
        
//        BOOL check = peripheral == nil ? YES : [peripheral.identifier isEqual:model.peripheral.identifier];
        
        if (ch.notifyAble && model.type == DTPeripheralActionType_notify  && [ch isEqual:model.ch] && type == DTPeripheralRecvType_notifyValue) {
            model.block(self.peripheral, ch, error);
        }
        else if (ch.readAble && [ch isEqual:model.ch]
                 && (model.type == DTPeripheralActionType_read) && type == DTPeripheralRecvType_notifyValue ) { //如果是可读数据
            if (model.type == DTPeripheralActionType_read && !ch.readAble) {
                DTLog(@"XXXX读取事件的特征不能读取");
                [indexSet addIndex:idx];
                return ;
            }
            
            model.block(self.peripheral, ch, error);
            model.block = nil;
            model.ch = nil;
            model.peripheral = nil;
            [indexSet addIndex:idx];
        }
        else if (ch.writeAble && [ch isEqual:model.ch] && (model.type == DTPeripheralActionType_write) && type == DTPeripheralRecvType_writeValue) { //写入后的respnonse事件
            model.block(self.peripheral, ch, error);
            model.block = nil;
            model.ch = nil;
            model.peripheral = nil;
            [indexSet addIndex:idx];
        }
        else if (ch.notifyAble && [ch isEqual:model.ch] && type == DTPeripheralRecvType_notifyState) {
            model.block(self.peripheral, ch, error);
            model.block = nil;
            model.ch = nil;
            model.peripheral = nil;
            [indexSet addIndex:idx];
        }
    }];
    
    if (indexSet.count) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
        [mutableArray removeObjectsAtIndexes:indexSet];
        [self.dic setObject:[mutableArray copy] forKey:key];
    }
}





//清除监听的事件
- (void)clearObserveActions {
    [self.dic removeAllObjects];
}

@end
