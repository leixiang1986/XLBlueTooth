//
//  DTPeripheralNotifyActionManager.h
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/**
 DTPeripheralActionManager 数据回调的管理类
 
 */



typedef NS_ENUM(NSInteger, DTPeripheralActionType) {
    DTPeripheralActionType_none,
    DTPeripheralActionType_read,           //外设读取事件
    DTPeripheralActionType_write,          //外设写入事件
    DTPeripheralActionType_notify          //外设通知事件
};

typedef void(^DTObserveCharacteristicValueBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristc, NSError *error); //监听特征值

@interface DTPeripheralActionModel : NSObject
@property (nonatomic, weak) CBCharacteristic *ch;
@property (nonatomic, weak) id observer;                              //弱引用
@property (nonatomic, copy) DTObserveCharacteristicValueBlock block;
//读取和写入的事件在调用过后就移除;如果是监听，调用过后事件不移除
@property (nonatomic, assign) DTPeripheralActionType type;
@property (nonatomic , weak) CBPeripheral *peripheral;
@end


@interface DTPeripheralActionManager : NSObject

@property (nonatomic, assign) CBPeripheral *peripheral; //所属的外设

//是否对某个特征进行过监听
- (BOOL)hasObserveForCharatcteristic:(CBCharacteristic *)ch forPeripheral:(CBPeripheral *)peripheral;

//添加监听，保存监听者和回调事件,type表示是读取，写入还是监听通知
- (void)addObserver:(nonnull NSObject *)observer forPeripheral:(CBPeripheral *)peripheral forCharacteristic:(nonnull CBCharacteristic *)ch type:(DTPeripheralActionType)type block:(DTObserveCharacteristicValueBlock)block;

//取消监听，移除监听者和回调事件
- (void)cancelObserveForCharacteristic:(CBCharacteristic *)ch forPeripheral:(CBPeripheral *)peripheral;

//收到数据的处理
- (void)receiveDataFromCharacteristic:(CBCharacteristic *)ch forPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

//清除监听的事件
- (void)clearObserveActions;

@end
