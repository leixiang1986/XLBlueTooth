//
//  CBCharacteristic+Extension.h
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBCharacteristic (Extension)
@property (nonatomic, assign, readonly) BOOL readAble;
@property (nonatomic, assign, readonly) BOOL writeAble;
@property (nonatomic, assign, readonly) BOOL notifyAble;
@end
