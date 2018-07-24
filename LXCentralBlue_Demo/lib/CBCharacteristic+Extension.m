//
//  CBCharacteristic+Extension.m
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "CBCharacteristic+Extension.h"

@implementation CBCharacteristic (Extension)

- (BOOL)readAble {
    return (self.properties & CBCharacteristicPropertyRead) == CBCharacteristicPropertyRead ? YES : NO;
}

- (BOOL)writeAble {
    return (self.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite ? YES : NO;
}

- (BOOL)notifyAble {
    return ((self.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify || (self.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyIndicate) ? YES : NO;
}

@end
