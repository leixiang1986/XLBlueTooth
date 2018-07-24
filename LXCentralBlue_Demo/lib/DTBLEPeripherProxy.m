//
//  DTBLEPeripherProxy.m
//  powercontrol
//
//  Created by leifayang on 2018/6/9.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DTBLEPeripherProxy.h"
#import "CBPeripheral+Extension.h"
#import "CBCharacteristic+Extension.h"


@interface DTBLEPeripherProxy()
@property (nonatomic, strong) NSMutableArray *delegatedPersArray;
//@property (nonatomic, strong) NSMutableDictionary *observerDic;  //特征的uuid string作为key，NSHashable作为value

@end

@implementation DTBLEPeripherProxy
+ (instancetype)shareManager {
    static DTBLEPeripherProxy *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DTBLEPeripherProxy alloc] init];
    });
    return instance;
}

- (void)delegateForPeripheral:(CBPeripheral *)peripheral {
    if (peripheral == nil) {
        return;
    }
    peripheral.delegate = self;
    BOOL flag = NO;
    for (CBPeripheral *per in self.delegatedPersArray) {
        if ([per.identifier isEqual:peripheral.identifier]) {
            flag = YES;
        }
    }
    if (!flag) {
        [self.delegatedPersArray addObject:peripheral];
    }
}

- (void)removeDelegateForPeripheral:(CBPeripheral *)peripheral {
    if (peripheral == nil) {
        return;
    }
    peripheral.delegate = nil;
    __block CBPeripheral *temp;
    for (CBPeripheral *per in self.delegatedPersArray) {
        if ([per.identifier isEqual:peripheral.identifier]) {
            temp = per;
        }
    }
    [self.delegatedPersArray removeObject:temp];
}


- (NSMutableArray *)delegatedPersArray {
    if (!_delegatedPersArray) {
        _delegatedPersArray = [[NSMutableArray alloc] init];
    }
    
    return _delegatedPersArray;
}


- (NSArray<CBPeripheral *> *)delegatedPeripherals {
    return [self.delegatedPersArray copy];
}




#pragma mark - CBPeripheralDelegate

//1,外设更新了名字
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    DTLog(@"==1,peripheralDidUpdateName");
    if (peripheral.stateChangedBlock) {
        peripheral.stateChangedBlock(peripheral);
    }
}

//2,外设修改了服务，返回了无效的服务
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    DTLog(@"==2,didModifyServices");
    
    
}

//3,读取了强度，调用readRSSI的回调
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error {
    DTLog(@"==3,didReadRSSI:%@===",RSSI);
    for (CBPeripheral *per in self.delegatedPeripherals) {
        if ([peripheral.identifier isEqual:per.identifier]) { //是代理的外设返回的数据
            if (per.readRssiBlock) {
                per.rssi = RSSI;
                per.readRssiBlock(peripheral, RSSI, error);
            }
        }
    }
}

//4,调用discoverServices:方法的回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    DTLog(@"==4,didDiscoverServices:%@==%@",peripheral.services,error);
    DTLog(@"delegatePeripherals==%@",self.delegatedPeripherals);
    for (CBPeripheral *per in self.delegatedPeripherals) {
        if ([peripheral.identifier isEqual:per.identifier]) { //是代理的外设返回的数据
//            NSLog(@"发现服务后的代理:%@==\n%@",per.services,peripheral.services);
            if (per.discoverServicesBlock) {
                per.discoverServicesBlock(peripheral, error);
                per.discoverServicesBlock = nil;
            }
        }
    }
}

//5,调用discoverIncludedServices:forService: 时的回调，返回指定service包含的service.includedServices
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error {
    //    service.includedServices
    DTLog(@"==5,didDiscoverIncludedServicesForService");
    
}

//6,调用discoverCharacteristics:forService: 时的回调，发现指定service包含的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    //    service.characteristics
    DTLog(@"==6,didDiscoverCharacteristicsForService:%@",service);
    for (CBPeripheral *per in self.delegatedPeripherals) {
        if ([peripheral.identifier isEqual:per.identifier]) { //是代理的外设返回的数据
            if ([per.charicteristicService.UUID isEqual:service.UUID]) {
                if (per.discoverCharacteristicsBlock) {
                    per.discoverCharacteristicsBlock(peripheral, service, error);
                    per.charicteristicService = nil;
                    per.discoverCharacteristicsBlock = nil;
                }
            }
            
            per.charicteristicService = nil; //回调后将服务置为nil
        }
    }
}


//7,调用readValueForCharacteristic:的回调
//或者setNotifyValue:forCharacteristic:置为YES时
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    DTLog(@"==7,didUpdateValueForCharacteristic:%@===%@====外设",characteristic,error);
    for (CBPeripheral *per in self.delegatedPeripherals) {
        if ([per.notifyActionManager hasObserveForCharatcteristic:characteristic forPeripheral:peripheral] && (characteristic.notifyAble || characteristic.readAble)) { //如果有监听
            [peripheral.notifyActionManager receiveDataFromCharacteristic:characteristic forPeripheral:peripheral error:error];
        }
        DTLog(@"接收到数据的通知:%@===%@",peripheral,per);
    }
}

//8,调用writeValue:forCharacteristic:type: 方法，type参数为 CBCharacteristicWriteWithResponse 时会调用
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    //    characteristic.value
    DTLog(@"==8,didWriteValueForCharacteristic:%@===%@",characteristic,error);
    if ([peripheral.notifyActionManager hasObserveForCharatcteristic:characteristic forPeripheral:peripheral]) {
        [peripheral.notifyActionManager receiveDataFromCharacteristic:characteristic forPeripheral:peripheral error:error];
    }
}

//9,当监听某个外设的通知开始或者关闭时调用
//通过调用setNotifyValue:forCharacteristic:
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    DTLog(@"==9,didUpdateNotificationStateForCharacteristic:%@==%@",characteristic,error);
}


//10,通过调用discoverDescriptorsForCharacteristic:获取指定特征的描述符
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    //    characteristic.descriptors
    DTLog(@"==10,didDiscoverDescriptorsForCharacteristic:%@",characteristic.descriptors);
}

//11,调用[peripheral readValueForDescriptor:];的回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    DTLog(@"==11,didUpdateValueForDescriptor:%@",descriptor.value);
    
}

//12, 调用writeValue:forDescriptor:的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    DTLog(@"==12,didWriteValueForDescriptor:%@",descriptor.value);
    
}



@end
