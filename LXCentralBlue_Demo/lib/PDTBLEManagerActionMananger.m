//
//  PDTBLEManagerActionMananger.m
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/25.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "PDTBLEManagerActionMananger.h"
#pragma mark - PDTBLEManagerActionModel  事件模型
@interface PDTBLEManagerActionModel : NSObject
@property (nonatomic, weak) id observer;
@property (nonatomic, copy) DTCentralStateUpdateBlock callBack;
@end

@implementation PDTBLEManagerActionModel

@end

#pragma mark - PDTBLEManagerActionMananger  事件管理类
@interface PDTBLEManagerActionMananger()
@property (nonatomic, strong) NSMutableArray *actions;
@end

@implementation PDTBLEManagerActionMananger
- (void)addObserver:(id)observer callBack:(DTCentralStateUpdateBlock)callBack {
    if (observer == nil || callBack == nil) {
        return;
    }
    BOOL flag = YES;
    for (PDTBLEManagerActionModel *model in self.actions) {
        if (model.observer == observer && [model.callBack isEqual:callBack]) {
            flag = NO;
            break;
        }
    }
    if (flag) {
        PDTBLEManagerActionModel *model = [[PDTBLEManagerActionModel alloc] init];
        model.observer = observer;
        model.callBack = callBack;
        [self.actions addObject:model];
    }
}

- (void)centralManagerStateUpdate:(CBCentralManager *)centralManager {
    if (centralManager == nil) {
        return;
    }
    NSMutableArray *removeArr = [[NSMutableArray alloc] init];
    for (PDTBLEManagerActionModel *model in self.actions) {
        if (model.observer) {
            model.callBack(centralManager);
        }
        else {
            [removeArr addObject:model];
        }
    }
    
    if (removeArr.count) {
        [self.actions removeObjectsInArray:removeArr];
    }
}


#pragma mark - private method

- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _actions;
}

@end
