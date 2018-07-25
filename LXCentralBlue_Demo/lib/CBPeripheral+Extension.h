//
//  CBPeripheral+Extension.h
//  powercontrol
//
//  Created by leifayang on 2018/6/6.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "DTPeripheralActionManager.h"

//中心设备发起事件的回调事件，对某个外设的操作绑定到对应的外设上。
typedef void(^DTConnectBlock)(CBPeripheral *peripheral, NSError *error); //连接的回调block，成功error为nil
typedef void(^DTDisConnectBlock)(CBPeripheral *peripheral, NSError *error); //断开连接的回调block

//外设发起事件的回调block
typedef void(^DTDiscoverServiceBlock)(CBPeripheral *peripheral, NSError *error); //外设扫描服务的回调
typedef void(^DTReadRssiBlock)(CBPeripheral *peripheral,NSNumber *rssi,NSError *error); //读取信号强度的回调block
typedef void(^DTDiscoverCharacteriticsBlock)(CBPeripheral *peripheral,CBService *service,NSError *error); //外设扫描特征的回调

typedef void(^DTWriteDataBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic,NSError *error);  //写入数据的回调

@interface CBPeripheral (Extension)
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, copy) NSString *localName;
@property (nonatomic, strong) NSDictionary *advertisementData;  //广播数据

@property (nonatomic, assign) BOOL isReconnect;                 //是否是自动重连，如果是，在断开后不删除掉绑定的回调事件，否则在断开后删除掉之前绑定的回调事件
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) CBService *discoveredService;      //发现的服务
@property (nonatomic, copy) void(^stateChangedBlock)(CBPeripheral *peripheral); //连接状态名字改变的block


//执行方法时绑定的数据，在数据回调后会清除掉
@property (nonatomic, strong) CBService *charicteristicService;         //搜索特征时的服务
@property (nonatomic, strong) CBCharacteristic *readDataCharacteristic; //读取数据的特征
@property (nonatomic, strong) NSDictionary *connectOptions;             //连接时的options,绑定的传入参数，重连时需要
@property (nonatomic, strong, readonly) DTPeripheralActionManager *notifyActionManager; //管理监听回调事件管理者，非单例,保存读取或通知回来的数据

//中心设备发起事件的回调
@property (nonatomic, copy) DTConnectBlock connectBlock;        //连接的block
@property (nonatomic, copy) DTDisConnectBlock disconnectBlock;  //断开连接的block

//外设发起事件的回调
@property (nonatomic, copy) DTReadRssiBlock readRssiBlock;
@property (nonatomic, copy) DTDiscoverServiceBlock discoverServicesBlock;
@property (nonatomic, copy) DTDiscoverCharacteriticsBlock discoverCharacteristicsBlock;
//发现服务
- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs block:(DTDiscoverServiceBlock)block;
//读取信号强度
- (void)readRSSIWithBlock:(DTReadRssiBlock)block;
//发现特征
- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service block:(DTDiscoverCharacteriticsBlock)block;

//读取特征值
- (BOOL)readValueForCharacteristic:(CBCharacteristic *)characteristic observer:(id)observer block:(DTObserveCharacteristicValueBlock)block;

//当写入类型是CBCharacteristicWriteWithResponse时，block返回写入是否成功
//如果写入类型为不需要返回就用系统的，如果是数据上会以通知的形式返回，那么在通知的block中接收
- (BOOL)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic observer:(id)observer block:(DTWriteDataBlock)block;

//监听某个特征值的notify,对oberver是弱引用，如果observer 销毁，不会回调block给observer
- (BOOL)observeValueForCharacteristic:(CBCharacteristic *)characteristic observer:(id)observer block:(DTObserveCharacteristicValueBlock)block;

//取消监听某个特征
- (BOOL)cancelObserveValueForCharacteristic:(CBCharacteristic *)characteristic;

//清除绑定的回调block和传入参数
- (void)clearBindDatas;

@end

/**
 发现服务，发现特征，读取信号强度写事件都是通过一个block和peripheral绑定
 但是读写数据是通过DTPeripheralActionManager对象来处理的，因为读写数据可能有多个同时处理，需要根据特征获取其中的值。
 
 */


