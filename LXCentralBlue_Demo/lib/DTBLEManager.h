//
//  DTBLEManager.h
//  powercontrol
//
//  Created by leifayang on 2018/6/6.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+Extension.h"
#import "PDTBLEManagerActionMananger.h"

typedef void(^DTStateChangedBlock)(NSArray *discoveredPers);  //状态改变的block

@interface DTBLEManager : NSObject
@property (nonatomic, strong, readonly) CBCentralManager *centralManager;
@property (nonatomic, strong, readonly) NSArray *discoveredPers;    //发现的外设数组
@property (nonatomic, strong, readonly) NSArray *connectedPers;     //连接的外设
@property (nonatomic, strong, readonly) NSArray *autoReconnectPers; // 自动重连的外设数组

@property (nonatomic, copy) BOOL (^scanFilterBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData); //过滤数据
@property (nonatomic, copy) DTDisConnectBlock disconnectBlock; //断开连接的block,这里是监听所有的断开连接
@property (nonatomic, copy) DTStateChangedBlock stateChangedBlock; //状态改变后的block

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shareManager;

//在初始化蓝牙中心设备后状态为poweredOn后，搜索services。如果搜索的services为空那么用shareManager初始化
//block返回搜索到的外设
+ (instancetype)shareManagerScanPeripheralWithDefaultServices:(NSArray <CBUUID *>*)services block:(DTStateChangedBlock)block;
//block返回搜索到的外设
+ (instancetype)shareManagerWithIdentifier:(NSString *)identifier services:(NSArray <CBUUID *>*)services block:(DTStateChangedBlock)block;

//添加中心设备状态发生改变的监听
- (void)addObserver:(id)observer centralManagerUpdateBlock:(DTCentralStateUpdateBlock)centralManagerUpdateBlock;

//扫描外设,timeInterval自动停止时间
- (void)scanPeripheralWithServices:(NSArray <CBUUID *>*)services stopDelay:(NSTimeInterval)timeInterval block:(DTStateChangedBlock)block;

- (void)stopScan;

//清除发现的数据，刷新数据时
- (void)clearDiscoveredPersExceptConnectedPer:(BOOL)except;

//连接外设
- (void)connectPeripheral:(CBPeripheral *)peripheral option:(NSDictionary *)options block:(DTConnectBlock)block;

//断开连接
- (void)disconnectPeripheral:(CBPeripheral *)peripheral block:(DTDisConnectBlock)block;

//将外设添加到自动重连中
- (void)addPeripheralToReconnect:(CBPeripheral *)peripheral;

//将外设从重连数组中移除
- (void)removePeripheralFromReconnectPerArr:(CBPeripheral *)peripheral;

//从发现的数组
- (void)removeFromDiscovers:(CBPeripheral *)per;

- (BOOL)checkState;



@end
