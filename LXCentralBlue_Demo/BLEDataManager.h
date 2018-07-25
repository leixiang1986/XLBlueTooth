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

//选中某个外设
- (BOOL)selectPeripheral:(CBPeripheral *)peripheral;

@end
