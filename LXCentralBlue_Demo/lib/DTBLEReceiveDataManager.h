//
//  DTBLEReceiveDataManager.h
//  powercontrol
//
//  Created by fuzzy@fdore.com on 2018/6/20.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


////接收到通用类型的block,result,成功0，失败1，密码错误2，未登录3
//typedef void(^DTRecvUniversalDataBlock)(DTDataReturnUniversalType type,NSInteger result) ;
////密码结果的block,result,成功1，失败0
//typedef void(^DTRecvModifyPwdDataBlock)(DTPasswordType type, BOOL result);
////定时器设置指令的返回
//typedef void(^DTRecvSetupTimerDataBlock)(data_timing_return_t timing_return);
////定时器使能返回
//typedef void(^DTRecvTimerAbleDataBlock)(DTDataReturnTimerAbleType type,data_timerable_return_t timerable_return, NSArray *timingModels);


#define kRecvPWDReulstSuccess      1
#define kRecvUniversalSuccess      0

//事件的model
@interface DTBLEReceiveDataActionModel : NSObject
@property (nonatomic, weak) id observer;
@property (nonatomic, copy) id block;
//@property (nonatomic, assign) DTDataReturnType type;
@property (nonatomic, weak) CBPeripheral *peripheral;
//@property (nonatomic, copy) NSString *perUUID;  //添加监听时的外设
@end


@interface DTBLEReceiveDataManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, assign) BOOL ispasting; //是否正在组包
//@property (nonatomic, assign) DTDataReturnType pastingType; //正在组包的类型

//解析通用类型的返回数据
//- (void)receiveUniversalData:(NSData *)data forPeripheral:(CBPeripheral *)per;
//为通用回调添加观察者及事件
//- (void)addObserver:(id)observer forUniversalDataBlock:(DTRecvUniversalDataBlock)block;

//解析查询延迟数据
//- (void)receiveQuerySetupDelayData:(NSData *)data forPeripheral:(CBPeripheral *)per;
//
////接收到查询循环数据
//- (void)receiveQuerySetupCircleData:(NSData *)data forPeripheral:(CBPeripheral *)per;
//
////接受到删除了延迟或者循环的数据
//- (void)receiveDeleteDelayData:(NSData *)data forPeripheral:(CBPeripheral *)per;
//
////接收到密码写入密码返回的数据(这里只处理了修改密码，登录密码的处理在列表控制器直接处理了)
//- (void)receivePwdData:(NSData *)data forPeripheral:(CBPeripheral *)per;
////修改密码添加观察者及回调事件,(登录密码的处理在控制器中直接处理了)
//- (void)addObserver:(id)observer forPeripheral:(CBPeripheral *)per forPWDDataBlock:(DTRecvModifyPwdDataBlock)block;
//
////接返回的数据
//- (void)receiveSetupTimerData:(NSData *)data forPeripheral:(CBPeripheral *)per;
////添加设置定时器的结果的观察者及事件回调
//- (void)addObserver:(id)observer forPeripheral:(CBPeripheral *)per forSetupTimerDataBlock:(DTRecvSetupTimerDataBlock)block;
//
////接收到的定时器使能数据
//- (void)receiveTimerAbleData:(NSData *)data  forPeripheral:(CBPeripheral *)per;
////为接收到定时器添加回调
//- (void)addObserver:(id)observer forPeripheral:(CBPeripheral *)per forTimerAbleDataBlock:(DTRecvTimerAbleDataBlock)block;

//移除观察者，这里没有区分事件，移除的是该观察者的所有事件
- (void)removeObserver:(NSObject *)observer forPeripheral:(CBPeripheral *)per;

//切换外设时，清除之前监听的事件
- (void)clearAcionModels;

//移除某种返回数据类型的监听
//- (void)removeObserver:(id)observer forType:(DTDataReturnType)type;

//清除监听者已经销毁事件,监听者是弱引用，在销毁后，依然保存了该事件，此方法就是为了清除这种没有监听者的无效事件模型
- (void)clearNoObserverActionModels;


@end
