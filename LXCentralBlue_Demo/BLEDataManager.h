//
//  BLEDataManager.h
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEDataManager : NSObject
+ (instancetype)shareManager;

@property (nonatomic, strong) NSArray *peripherals;
@property (readonly) CBPeripheral *currentPeripheral;

////选中某个外设
//- (BOOL)selectPeripheralAtIndex:(NSInteger)index;

//连接，发现服务，特征等操作
- (void)connectPeriperal:(CBPeripheral *)peripheral block:(void(^)(CBPeripheral *peripheral,NSError *error))block;
//连接，发现服务，特征等操作
- (void)connectPeriperalAtIndex:(NSInteger)index block:(void(^)(CBPeripheral *peripheral,NSError *error))block;

//通过UUIDString字符串获取对应的特征
- (CBCharacteristic *)characteristicOfUUIDString:(NSString *)UUIDString;

@end
