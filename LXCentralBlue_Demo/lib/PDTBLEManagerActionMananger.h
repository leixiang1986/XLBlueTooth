//
//  PDTBLEManagerActionMananger.h
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>


//内部私有类，管理添加的监听centralMananger状态的回调(多次)
@interface PDTBLEManagerActionMananger : NSObject
- (void)addObserver:(id)observer callBack:(DTCentralStateUpdateBlock)callBack;
- (void)centralManagerStateUpdate:(CBCentralManager *)centralManager;
@end
