//
//  DTBLEConstant.m
//  powercontrol
//
//  Created by fuzzy@fdore.com on 2018/6/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DTBLEConstant.h"

@implementation DTBLEConstant

NSString *const DTBLECentralPoweredOffNotification = @"DTBLECentralPoweredOffNotification";   //蓝牙关闭了
NSString *const DTBLECentralPoweredOnNotification = @"DTBLECentralPoweredOnNotification";     //蓝牙开启了
NSString *const DTBLEConnectedNotification = @"DTBLEConnectedNotification";                   //连接成功
NSString *const DTBLEAutoConnectedNotification = @"DTBLEAutoConnectedNotification";           //自动连接连接成功
NSString *const DTBLEDisconnectedNotification = @"DTBLEDisconnectedNotification";             //断开连接
NSString *const DTBLESwitchStateChangedNotification = @"DTBLESwitchStateChangedNotification"; //开关状态发生改变
NSString *const DTBLEDidDiscoverCharacteristicsNotification = @"DTBLEDidDiscoverCharacteristicsNotification";
NSString *const DTBLEDidWritePasswordNotification = @"DTBLEDidWritePasswordNotification";     //已经写入了密码

//返回数据的通知
NSString *const DTReceiveDataUniversalTypeNotification = @"DTReceiveDataUniversalTypeNotification";
NSString *const DTReceiveDataQueryDelayNotification = @"DTReceiveDataQueryDelayNotification";
NSString *const DTReceiveDataQueryCircleNotification = @"DTReceiveDataQueryCircleNotification";
NSString *const DTReceiveDataDeleteDelayNotification = @"DTReceiveDataDeleteDelayNotification";
NSString *const DTReceiveDataDeleteTimerNotification = @"DTReceiveDataDeleteTimerNotification";

NSString *const DTBlueToothErrorDomain = @"DTBlueToothErrorDomain";

@end
