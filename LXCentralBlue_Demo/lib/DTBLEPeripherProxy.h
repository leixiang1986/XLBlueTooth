//
//  DTBLEPeripherProxy.h
//  powercontrol
//
//  Created by leifayang on 2018/6/9.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

//外设代理类
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@interface DTBLEPeripherProxy : NSObject<CBPeripheralDelegate>
@property (nonatomic, strong, readonly) NSArray <CBPeripheral *>*delegatedPeripherals; //被代理的外设数组,强引用对象


+ (instancetype)shareManager;

//添加被代理的外设,代理对外设有强引用
- (void)delegateForPeripheral:(CBPeripheral *)peripheral;
//移除被代理的外设
- (void)removeDelegateForPeripheral:(CBPeripheral *)peripheral;





@end
