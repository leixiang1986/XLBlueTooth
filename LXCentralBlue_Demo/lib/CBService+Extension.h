//
//  CBService+Extension.h
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBService (Extension)
//获取CBService中UUIDString对应的特征
- (CBCharacteristic *)characteristicForUUIDString:(NSString *)string;

@end
