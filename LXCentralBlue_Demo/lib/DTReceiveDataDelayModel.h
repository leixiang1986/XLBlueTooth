//
//  DTReceiveDataDelayModel.h
//  powercontrol
//
//  Created by fuzzy@fdore.com on 2018/6/28.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTReceiveDataDelayModel : NSObject
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic, assign) BOOL on;  //延时是开还是关
@end
