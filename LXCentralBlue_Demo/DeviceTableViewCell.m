//
//  DeviceTableViewCell.m
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/26.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DeviceTableViewCell.h"
#import "CBPeripheral+Extension.h"

@implementation DeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    NSString *state = @"未知";
    if (peripheral.state == CBPeripheralStateConnected) {
        state = @"连接";
    }
    else if (peripheral.state == CBPeripheralStateDisconnected) {
        state = @"未连接";
    }
    else if (peripheral.state == CBPeripheralStateConnecting) {
        state = @"正在连接";
    }
    else if (peripheral.state == CBPeripheralStateDisconnecting) {
        state = @"正在断开";
    }
    [self setTitle:peripheral.localName state:state];
}

- (void)setTitle:(NSString *)title state:(NSString *)state {
    self.label.text = title;
    [self.stateButton setTitle:state forState:(UIControlStateNormal)];
}

- (IBAction)stateClick:(id)sender {
    if (self.stateClickBlock) {
        self.stateClickBlock(self);
    }
}



@end
