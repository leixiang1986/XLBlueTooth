//
//  CBPeripheral+Extension.m
//  powercontrol
//
//  Created by leifayang on 2018/6/6.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "CBPeripheral+Extension.h"
#import <objc/message.h>
#import "DTBLEManager.h"

static NSString *const kRSSIKey = @"kRSSIKey";
static NSString *const kAdvertisementDataKey = @"kAdvertisementDataKey";
static NSString *const kConnectOptionsKey = @"kConnectOptionsKey";
static NSString *const kConnectedBlockKey = @"kConnectedBlockKey";
static NSString *const kDisConnectedBlockKey = @"kDisConnectedBlockKey";
static NSString *const kDiscoverServicesBlockKey = @"kDiscoverServicesBlockKey";
static NSString *const kReadRssiBlockKey = @"kReadRssiBlockKey";
static NSString *const kCharicteristicServiceKey = @"kCharicteristicServiceKey";
static NSString *const kDiscoverCharacteristicsBlockKey = @"kDiscoverCharacteristicsBlockKey";
//static NSString *const kReadCharacteristicBlockKey = @"kReadCharacteristicBlockKey";    //读取特征值时回调的block key
static NSString *const kReadDataCharacteristicKey = @"kReadDataCharacteristicKey";      //读取特征值时传入的特征key
//static NSString *const kNotifyDataCharacteristicKey = @"kNotifyDataCharacteristicKey";  //监听特征的传入特征key
static NSString *const kIsReconnectKey = @"kIsReconnectKey";
static NSString *const kDiscoveredServiceKey = @"kDiscoveredServiceKey";              //discover的服务
//static NSString *const kObserveAndCallbackKey = @"kObserveAndCallbackKey";              //监听回调字典
//static NSString *const kWriteDataBlockKey = @"kWriteDataBlockKey";                      //写数据的回调block
//static NSString *const kObserverBlockKey = @"kObserverBlockKey";                        //监听回调的block
static NSString *const kNofityActionManagerKey = @"kNofityActionManagerKey"; //监听的事件回调管理者的key
//static NSString *const kWriteActionManagerKey = @"kWriteActionManagerKey";  //写入数据的事件回调(在特征的propertys是withResponse时)
static NSString *const kStateChangedBlockKey = @"kStateChangedBlockKey";                //外设状态改变的key


@interface CBPeripheral ()
@property (nonatomic, strong, readwrite) DTPeripheralActionManager *notifyActionManager;
//@property (nonatomic, strong, readwrite) DTPeripheralActionManager *writeActionManager;
@end

@implementation CBPeripheral (Extension)

//型号强度
- (void)setRssi:(NSNumber *)rssi {
    if (self.rssi == rssi) {
        return;
    }
    objc_setAssociatedObject(self, &kRSSIKey, rssi, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)rssi {
    return objc_getAssociatedObject(self, &kRSSIKey);
}

//本地名字
//- (void)setLocalName:(NSString *)localName {
//    objc_setAssociatedObject(self, &localName, localName, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}



//广播的包数据
- (void)setAdvertisementData:(NSDictionary *)advertisementData {
    objc_setAssociatedObject(self, &kAdvertisementDataKey, advertisementData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)advertisementData {
    return objc_getAssociatedObject(self, &kAdvertisementDataKey);
}

//连接的选项
- (void)setConnectOptions:(NSDictionary *)connectOptions {
    objc_setAssociatedObject(self, &kConnectOptionsKey, connectOptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)connectOptions {
    return objc_getAssociatedObject(self, &kConnectOptionsKey);
}

//搜索特征时的服务
- (void)setCharicteristicService:(CBService *)charicteristicService {
    objc_setAssociatedObject(self, &kCharicteristicServiceKey, charicteristicService, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBService *)charicteristicService {
    return objc_getAssociatedObject(self, &kCharicteristicServiceKey);
}

//是否是自动重连的
- (void)setIsReconnect:(BOOL)isReconnect {
    objc_setAssociatedObject(self, &kIsReconnectKey, [NSNumber numberWithBool:isReconnect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isReconnect {
    return [objc_getAssociatedObject(self, &kIsReconnectKey) boolValue];
}






//发现的服务
- (void)setDiscoveredService:(CBService *)discoveredService {
    objc_setAssociatedObject(self, &kDiscoveredServiceKey, discoveredService, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBService *)discoveredService {
    return objc_getAssociatedObject(self, &kDiscoveredServiceKey);
}

//外设的状态改变的block
- (void)setStateChangedBlock:(void (^)(CBPeripheral*))stateChangedBlock {
    objc_setAssociatedObject(self, &kStateChangedBlockKey, stateChangedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(CBPeripheral*))stateChangedBlock {
    return objc_getAssociatedObject(self, &kStateChangedBlockKey);
}





//读取数据的特征
- (void)setReadDataCharacteristic:(CBCharacteristic *)readDataCharacteristic {
    objc_setAssociatedObject(self, &kReadDataCharacteristicKey, readDataCharacteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBCharacteristic *)readDataCharacteristic {
    return objc_getAssociatedObject(self, &kReadDataCharacteristicKey);
}



//
- (void)setNotifyActionManager:(DTPeripheralActionManager *)notifyActionManager {
    objc_setAssociatedObject(self, &kNofityActionManagerKey, notifyActionManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DTPeripheralActionManager *)notifyActionManager {
    DTPeripheralActionManager *manager = objc_getAssociatedObject(self, &kNofityActionManagerKey);
    if (!manager) {
        manager = [[DTPeripheralActionManager alloc] init];
        manager.peripheral = self;
        [self setNotifyActionManager:manager];
    }
    return manager;
}

- (BOOL)isConnected {
    return (self.state == CBPeripheralStateConnected);
}

- (void)setLocalName:(NSString *)localName {
    if (localName == nil) {
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:self.advertisementData];
    [dic setObject:localName forKey:@"kCBAdvDataLocalName"];
    self.advertisementData = [dic copy];
}

- (NSString *)localName {
    return self.advertisementData[@"kCBAdvDataLocalName"];
}




#pragma mark - 中心设备发起事件的回调block,中心设备对每个外设的操作，需要将回调绑定到具体的外设上
//连接的block事件
- (void)setConnectBlock:(DTConnectBlock)connectBlock {
    objc_setAssociatedObject(self, &kConnectedBlockKey, connectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DTConnectBlock)connectBlock {
    return objc_getAssociatedObject(self, &kConnectedBlockKey);
}

//断开连接的block事件
- (void)setDisconnectBlock:(DTDisConnectBlock)disconnectBlock {
    objc_setAssociatedObject(self, &kDisConnectedBlockKey, disconnectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DTDisConnectBlock)disconnectBlock {
    return objc_getAssociatedObject(self, &kDisConnectedBlockKey);
}
#pragma mark - 外设发起事件的回调block
//发现服务的block事件
- (void)setDiscoverServicesBlock:(DTDiscoverServiceBlock)discoverServicesBlock {
    objc_setAssociatedObject(self, &kDiscoverServicesBlockKey, discoverServicesBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DTDiscoverServiceBlock)discoverServicesBlock {
    return objc_getAssociatedObject(self, &kDiscoverServicesBlockKey);
}


//读取rssi信号强度的回调block
- (void)setReadRssiBlock:(DTReadRssiBlock)readRssiBlock {
    objc_setAssociatedObject(self, &kReadRssiBlockKey, readRssiBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DTReadRssiBlock)readRssiBlock {
    return objc_getAssociatedObject(self, &kReadRssiBlockKey);
}

//发现指定服务下的特征block
- (void)setDiscoverCharacteristicsBlock:(DTDiscoverCharacteriticsBlock)discoverCharacteristicsBlock {
    objc_setAssociatedObject(self, &kDiscoverCharacteristicsBlockKey, discoverCharacteristicsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DTDiscoverCharacteriticsBlock)discoverCharacteristicsBlock {
    return objc_getAssociatedObject(self, &kDiscoverCharacteristicsBlockKey);
}




#pragma mark - 外设发起事件及回调方法
- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs block:(DTDiscoverServiceBlock)block {
    if (!self.delegate) {
        DTLog(@"没有设置代理==发现服务");
    }
    if (![[DTBLEManager shareManager] checkState]) {
        return;
    }
    [self setDiscoverServicesBlock:block];
    [self discoverServices:serviceUUIDs];
    
}

//读取信号强度
- (void)readRSSIWithBlock:(DTReadRssiBlock)block {
    if (!self.delegate) {
        DTLog(@"没有设置代理==读取rssi");
    }
    if (![[DTBLEManager shareManager] checkState] && self.isConnected) {
        return;
    }
    [self setReadRssiBlock:block];
    [self readRSSI];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service block:(DTDiscoverCharacteriticsBlock)block {
    if (!self.delegate) {
        DTLog(@"没有设置代理==发现特征的");
    }
    if (![[DTBLEManager shareManager] checkState]) {
        return;
    }
    [self setDiscoverCharacteristicsBlock:block];
    self.charicteristicService = service;
    [self discoverCharacteristics:characteristicUUIDs forService:service];
}

//读取特征值
- (BOOL)readValueForCharacteristic:(CBCharacteristic *)characteristic observer:(id)observer block:(DTObserveCharacteristicValueBlock)block {
    if (characteristic == nil || (characteristic.properties & CBCharacteristicPropertyRead) != CBCharacteristicPropertyRead) {
        return NO;
    }
    
    [self.notifyActionManager addObserver:observer forPeripheral:self forCharacteristic:characteristic type:DTPeripheralActionType_read block:block];
    [self readValueForCharacteristic:characteristic];
    return YES;
}

//监听某个特征
- (BOOL)observeValueForCharacteristic:(CBCharacteristic *)characteristic observer:(id)observer block:(DTObserveCharacteristicValueBlock)block {
    if (characteristic == nil || (characteristic.properties & CBCharacteristicPropertyNotify) != CBCharacteristicPropertyNotify) {
        NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_parameterError userInfo:@{@"msg":@"parameter error"}];
        block(nil,nil,error);
        return NO;
    }
    
    
    if (![[DTBLEManager shareManager] checkState]) {
        NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_powerOff userInfo:@{@"msg":@"powered off"}];
        block(nil,nil,error);
        return NO;
    }
    [self.notifyActionManager addObserver:observer forPeripheral:self forCharacteristic:characteristic type:DTPeripheralActionType_notify block:block];
    [self setNotifyValue:YES forCharacteristic:characteristic];
    return YES;
}

//取消监听某个特征
- (BOOL)cancelObserveValueForCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic == nil || (characteristic.properties & CBCharacteristicPropertyNotify) != CBCharacteristicPropertyNotify) {
        return NO;
    }
    [self.notifyActionManager cancelObserveForCharacteristic:characteristic forPeripheral:self];
    if (![[DTBLEManager shareManager] checkState]) {
        return NO;
    }
    
    [self setNotifyValue:NO forCharacteristic:characteristic];
    return YES;
}

//写数据
- (BOOL)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic observer:(id)observer block:(DTWriteDataBlock)block {
    if (characteristic == nil || data == nil) {
        if (block) {
            NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_parameterError userInfo:@{@"msg":@"没有data或characteristic"}];
            block(nil,nil,error);
        }
        return NO;
    }
    
    if (![[DTBLEManager shareManager] checkState]) {
        NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_powerOff userInfo:@{@"msg":@"powered off"}];
        block(nil,nil,error);
        return NO;
    }
    
    if (self.state != CBPeripheralStateConnected) {
        NSError *error = [NSError errorWithDomain:DTBlueToothErrorDomain code:DTBlueToothErrorCode_notConnected userInfo:@{@"msg":@"not connected"}];
        block(nil,nil,error);
        return NO;
    }
    DTLog(@"写入了数据:%@===characteristic:%@",data,characteristic);
    if ((characteristic.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite) {
        [self writeValue:data forCharacteristic:characteristic type:(CBCharacteristicWriteWithResponse)];
        [self.notifyActionManager addObserver:observer forPeripheral:self forCharacteristic:characteristic type:(DTPeripheralActionType_write) block:block];
    }
    else if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse) {
        [self writeValue:data forCharacteristic:characteristic type:(CBCharacteristicWriteWithoutResponse)];
    }
    return YES;
}

//清除绑定的回调block,断开连接后需要清除回调的block
- (void)clearCallBackBlocks {
    self.readRssiBlock = nil;
    self.discoverServicesBlock = nil;
    self.discoverCharacteristicsBlock = nil;
    [self.notifyActionManager clearObserveActions];  //移除监听的读取数据和
}

//清除绑定的传入参数
- (void)clearBindParameters {
    self.charicteristicService = nil;
    self.readDataCharacteristic = nil;
    self.connectOptions = nil;
}

//清除绑定的block和入参参数
- (void)clearBindDatas {
    [self clearCallBackBlocks];
    [self clearBindParameters];
}

@end
