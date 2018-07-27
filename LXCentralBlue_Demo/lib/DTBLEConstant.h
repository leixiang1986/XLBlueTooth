//
//  DTBLEConstant.h
//  powercontrol
//
//  Created by fuzzy@fdore.com on 2018/6/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DTBLEConstant : NSObject
extern NSString *const DTBLECentralPoweredOnNotification;
extern NSString *const DTBLECentralPoweredOffNotification;
extern NSString *const DTBLEConnectedNotification ;
extern NSString *const DTBLEDisconnectedNotification ;
extern NSString *const DTBLESwitchStateChangedNotification;
extern NSString *const DTBLEAutoConnectedNotification ;             //自动连接连接成功
extern NSString *const DTBLEDidDiscoverCharacteristicsNotification; //已经发现了特征
extern NSString *const DTBLEDidWritePasswordNotification;           //已经写入了密码



//返回数据的通知
extern NSString *const DTReceiveDataUniversalTypeNotification;   //通用类型的返回数据通知
extern NSString *const DTReceiveDataQueryDelayNotification;     //查询延迟开关的数据返回通知
extern NSString *const DTReceiveDataQueryCircleNotification;    //查询循环开关的通知
extern NSString *const DTReceiveDataDeleteDelayNotification;   //接收到删除延迟开关或循环开关的通知
extern NSString *const DTReceiveDataDeleteTimerNotification;   //删除定时器返回结果通知

extern NSString *const DTBlueToothErrorDomain;

typedef NS_ENUM(NSInteger, DTBlueToothErrorCode) {
    DTBlueToothErrorCode_powerOff,
    DTBlueToothErrorCode_notConnected,
    DTBlueToothErrorCode_parameterError,
    DTBlueToothErrorCode_other
};

typedef void(^DTCentralStateUpdateBlock)(CBCentralManager *manager);

#define kScreenSize   [UIScreen mainScreen].bounds.size
#define weakSelf(weakSelf) __weak typeof(self) (weakSelf) = self;


@end
