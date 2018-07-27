//
//  DeviceTableViewCell.h
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/26.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;

@property (nonatomic, copy) void(^stateClickBlock)(DeviceTableViewCell *cell);
@property (nonatomic, strong) CBPeripheral *peripheral;

@end
