//
//  CBService+Extension.m
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "CBService+Extension.h"

@implementation CBService (Extension)
- (CBCharacteristic *)characteristicForUUIDString:(NSString *)string {
    CBCharacteristic *characteristic = nil;
    CBUUID *uuid = [CBUUID UUIDWithString:string];
    for (CBCharacteristic *ch in self.characteristics) {
        if ([ch.UUID isEqual:uuid]) {
            characteristic = ch;
            break;
        }
    }
    
    return characteristic;
}
@end
