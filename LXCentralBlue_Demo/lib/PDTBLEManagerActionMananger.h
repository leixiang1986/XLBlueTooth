//
//  PDTBLEManagerActionMananger.h
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PDTBLEManagerActionMananger : NSObject
- (void)addObserver:(id)observer callBack:(DTCentralStateUpdateBlock)callBack;
- (void)centralManagerStateUpdate:(CBCentralManager *)centralManager;
@end
