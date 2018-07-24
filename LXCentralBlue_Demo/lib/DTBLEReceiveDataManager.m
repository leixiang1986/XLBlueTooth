//
//  DTBLEReceiveDataManager.m
//  powercontrol
//
//  Created by fuzzy@fdore.com on 2018/6/20.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DTBLEReceiveDataManager.h"
#import "DTReceiveDataUniversalModel.h"
#import "DTReceiveDataDelayModel.h"
#import "DTReceiveDataCircleModel.h"



@implementation DTBLEReceiveDataActionModel

- (instancetype)init {
    if (self = [super init]) {
        DTLog(@"创建了接收事件:%@",self);
    }
    return self;
}

- (void)dealloc {
    DTLog(@"销毁了接收事件:%@",self);
}
@end

@interface DTBLEReceiveDataManager()
//@property (nonatomic, strong) NSMutableArray *actionModels;
//@property (nonatomic, strong) NSMutableData *mutableData;   //拼接数据包
//@property (nonatomic, assign) NSInteger totalLen;           //拼接数据包时的总长度
@end

@implementation DTBLEReceiveDataManager
//+ (instancetype)shareManager {
//    static DTBLEReceiveDataManager *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[DTBLEReceiveDataManager alloc] init];
//
//    });
//
//    return instance;
//}
//
//- (NSMutableData *)mutableData {
//    if (!_mutableData) {
//        _mutableData = [[NSMutableData alloc] init];
//    }
//
//    return _mutableData;
//}
//
//
//- (NSMutableArray *)actionModels {
//    if (!_actionModels) {
//        _actionModels = [[NSMutableArray alloc] init];
//        DTLog(@"接收事件的数据初始化了:%p==%@",_actionModels,_actionModels);
//    }
//
//    return _actionModels;
//}
//
//
////解析通用类型的返回数据
////result,成功0，失败1，密码错误2，未登录3
//- (void)receiveUniversalData:(NSData *)data forPeripheral:(CBPeripheral *)per{
//    if (data.length <= 8) {
//        return;
//    }
//    DTDataReturnUniversalType type = [DTBELCommand returnUniversalType:data];
//    unsigned char result ;
//    [data getBytes:&result range:NSMakeRange(8, 1)];
//
//    DTReceiveDataUniversalModel *model = [[DTReceiveDataUniversalModel alloc] init];
//    model.type = type;
//    model.result = (result == 0);
//    [[NSNotificationCenter defaultCenter] postNotificationName:DTReceiveDataUniversalTypeNotification object:model];
//}
//
//
//
//
//- (void)receiveQuerySetupDelayData:(NSData *)data forPeripheral:(CBPeripheral *)per{
//    if (data.length != 14) {
//        return;
//    }
//
//    data_query_delay_return_t delayRead;
//    [data getBytes:&delayRead length:sizeof(data_query_delay_return_t)];
//    DTDataReturnUniversalType type = delayRead.cmd;
//
//    if (type != DTDataReturnType_queryDelay) {
//        return;
//    }
//
//    DTReceiveDataDelayModel *model = [[DTReceiveDataDelayModel alloc] init];
//    model.on = delayRead.on;
//    model.seconds = delayRead.seconds;
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:DTReceiveDataQueryDelayNotification object:model];
//}
//
////接收到查询循环数据
//- (void)receiveQuerySetupCircleData:(NSData *)data forPeripheral:(CBPeripheral *)per{
//    DTLog(@"接收到的查询循环数据:%@",data);
//    if (data.length != 17) {
//        return;
//    }
//
//    data_query_circle_return_t circelRead = {0};
//    [data getBytes:&circelRead length:sizeof(data_query_circle_return_t)];
//    DTDataReturnUniversalType type = circelRead.cmd;
//
//    if (type != DTDataReturnType_queryCircle) {
//        return;
//    }
//
//    DTReceiveDataCircleModel *model = [[DTReceiveDataCircleModel alloc] init];
//    model.startInterval = circelRead.startInterval;
//    model.endInterval = circelRead.endInterval;
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:DTReceiveDataQueryCircleNotification object:model];
//}
//
////接受到删除了延迟或者循环的数据
//- (void)receiveDeleteDelayData:(NSData *)data forPeripheral:(CBPeripheral *)per{
//    if (data.length != 10) {
//        return;
//    }
//
//    data_delete_delay_return_t delete_delay;
//    [data getBytes:&delete_delay length:sizeof(data_delete_delay_return_t)];
//    [[NSNotificationCenter defaultCenter] postNotificationName:DTReceiveDataDeleteDelayNotification object:@(delete_delay.type)];
//}
//
//
////密码的处理
//- (void)receivePwdData:(NSData *)data forPeripheral:(CBPeripheral *)per{
//    data_inputpwd_return_t dataReturn;
//    BOOL result = [DTBELCommand pwdReturn:&dataReturn FormData:data];
//    if (!result) {
//        return;
//    }
//    DTLog(@"密码输入的事件:%@==%d",self.actionModels,self.actionModels.count);
//    for (DTBLEReceiveDataActionModel *model in self.actionModels ) {
//        //在监听事件模型数组中查找对应类型的数据进行回调
//        if (model.type == DTDataReturnType_pwd) {
//            BOOL check = per == nil ? YES : [model.peripheral.identifier isEqual:per.identifier];
//            if (model.observer && model.block && check) { //检查观察者是否销毁
//                DTRecvUniversalDataBlock block = model.block;
//                block(dataReturn.returnCmd,dataReturn.result == kRecvPWDReulstSuccess);
//                DTLog(@"回调了注册的事件:%@",model.observer);
//            }
//            else {
//                DTLog(@"观察者已经销毁了");
//            }
//        }
//    }
//}
//
//- (void)addObserver:(id)observer forPeripheral:(CBPeripheral *)per forPWDDataBlock:(DTRecvModifyPwdDataBlock)block {
//    [self addObserver:observer forPeripheral:per type:DTDataReturnType_pwd forBlock:block];
//}
//
//
//
////接返回的数据
//- (void)receiveSetupTimerData:(NSData *)data forPeripheral:(CBPeripheral *)per{
//    if (data.length != sizeof(data_timing_return_t)) {
//        return;
//    }
//
//    data_timing_return_t timing_return;
//    [data getBytes:&timing_return length:data.length];
//
//    for (DTBLEReceiveDataActionModel *model in self.actionModels ) {
//        //在监听事件模型数组中查找对应类型的数据进行回调
//        if (model.type == DTDataReturnType_setupTimer) {
//            BOOL check = per == nil ? YES : [model.peripheral.identifier isEqual:per.identifier];
//            if (model.observer && model.block && check) { //检查观察者是否销毁
//                DTRecvSetupTimerDataBlock block = model.block;
//                block(timing_return);
//                DTLog(@"回调了注册的事件:%@",model.observer);
//            }
//            else {
//                DTLog(@"观察者已经销毁了");
//            }
//        }
//    }
//}
//
////添加设置定时器的结果的观察者及事件回调
//- (void)addObserver:(id)observer forPeripheral:(CBPeripheral *)per forSetupTimerDataBlock:(DTRecvSetupTimerDataBlock)block {
//    [self addObserver:observer forPeripheral:per type:DTDataReturnType_setupTimer forBlock:block];
//}
//
//
//
//
//
////接收到的定时器数据
//- (void)receiveTimerAbleData:(NSData *)data forPeripheral:(CBPeripheral *)per{
//    if (data.length == 0) {
//        return;
//    }
//
//    NSData *pasteData = [self pastePacketData:data forCMD:DTDataReturnType_timerAble];
//    if (!pasteData) {
//        unsigned char c = 0;
//        [data getBytes:&c length:1];
//        if (c == 0x44) {
//            DTLog(@"定时器组包开始数据数据:%@",data);
//            DTLog(@"定时器组包开始数据组包后:%@",pasteData);
//        }
//        else {
//            DTLog(@"定时器组包过程数据:%@",data);
//            DTLog(@"定时器组包过程数据组包后:%@",pasteData);
//        }
//        return;
//    }
//    else {
//        DTLog(@"定时器组包成功数据:%@",pasteData);
//    }
//
//    //得到的是拼好包的数据
//    data_timerable_return_t timing_return;
//    [pasteData getBytes:&timing_return length:sizeof(data_timerable_return_t)];
//
//    NSArray *models = nil;
//    if (timing_return.timer_able.type == DTDataReturnTimerAbleType_query) { //如果是查询,解析返回的数据
//        if (timing_return.result > 0) {
//            DTLog(@"含有返回定时器的数据:%@",pasteData);
//            NSMutableArray *mutable = [NSMutableArray arrayWithCapacity:timing_return.result];
//            data_timingcontent_t timingcontent;
//            for (NSInteger i = 0; i < timing_return.result; i++) {
//                NSInteger location = sizeof(data_timerable_return_t) + sizeof(timingcontent) * i; //第i个的location
//                [pasteData getBytes:&timingcontent range:NSMakeRange(location, sizeof(timingcontent))];
//                DTTimingModel *model = [DTTimingModel timingModelFromStruct:timingcontent];
//                if (model) {
//                    [mutable addObject:model];
//                }
//            }
//            models = [mutable copy];
//            DTLog(@"返回的定时器个数为:%ld",models.count);
//        }
//    }
//    else if(timing_return.timer_able.type == DTDataReturnTimerAbleType_delete){ //删除
//        [[NSNotificationCenter defaultCenter] postNotificationName:DTReceiveDataDeleteTimerNotification object:@(timing_return.timer_able.order)];
//    }
//
//    for (DTBLEReceiveDataActionModel *model in self.actionModels ) {
//        //在监听事件模型数组中查找对应类型的数据进行回调
//        if (model.type == DTDataReturnType_timerAble) {
//            BOOL check = per == nil ? YES : [model.peripheral.identifier isEqual:per.identifier];
//            if (model.observer && model.block && check) { //检查观察者是否销毁
//                DTRecvTimerAbleDataBlock block = model.block;
//                block(timing_return.timer_able.type,timing_return,models);
//                DTLog(@"回调了注册的事件:%@",model.observer);
//            }
//            else {
//                DTLog(@"观察者已经销毁了");
//            }
//        }
//    }
//}
//
////为定时器使能命令注册回调事件
//- (void)addObserver:(id)observer forPeripheral:(CBPeripheral *)per forTimerAbleDataBlock:(DTRecvTimerAbleDataBlock)block {
//    [self addObserver:observer forPeripheral:per type:DTDataReturnType_timerAble forBlock:block];
//}
//
//
////移除观察者
//- (void)removeObserver:(NSObject *)observer forPeripheral:(CBPeripheral *)per//移除观察者，这里没有区分事件，移除的是该观察者的所有事件
//{
//    if (observer == nil) {
//        return;
//    }
//
//    NSMutableArray *removeModels = [NSMutableArray arrayWithCapacity:self.actionModels.count];
//    for (DTBLEReceiveDataActionModel *model in self.actionModels ) {
//        if ((per == nil && observer == model.observer) || ([model.peripheral.identifier isEqual:per.identifier] && observer == model.observer) ) {
//            [removeModels addObject:model];
//        }
//    }
//
//    if (removeModels.count) {
//        [self.actionModels removeObjectsInArray:removeModels];
//    }
//}
//
//
//
//
//
////清除监听者已经销毁事件,监听者是弱引用，在销毁后，依然保存了该事件，此方法就是为了清除这种没有监听者的无效事件模型
//- (void)clearNoObserverActionModels {
//    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
//    for (DTBLEReceiveDataActionModel *actionModel in self.actionModels ) {
//        if (actionModel.observer == nil) {  //没有外设或者没有观察者
//            DTLog(@"清除掉的的无效事件:%@",actionModel);
//            [indexSet addIndex:[self.actionModels indexOfObject:actionModel]];
//        }
//    }
//    if (indexSet.count) {
//        [self.actionModels removeObjectsAtIndexes:indexSet];
//    }
//}
//
//
////清除时间model
//- (void)clearAcionModels {
//    [self.actionModels removeAllObjects];
//}
//
//#pragma mark - private method
//- (void)addObserver:(id)observer forPeripheral:(CBPeripheral *)per type:(DTDataReturnType)type forBlock:(id)block {
//    if (observer == nil || block == nil) {
//        return;
//    }
//    DTBLEReceiveDataActionModel *model = [[DTBLEReceiveDataActionModel alloc] init];
//    model.observer = observer;
//    model.type = type;
//    model.block = block;
//    model.peripheral = per;
//
//    [self.actionModels addObject:model];
//}
//
////清除粘包数据
//- (void)clearPastePacketData {
//    _mutableData = nil;
//    _totalLen = 0;
//    _ispasting = NO;
//    _pastingType = DTDataReturnType_none;
//}
//
////得到读取数据的总长度
//- (NSInteger)totalLenOfReceiveData:(NSData *)data forCMD:(unsigned char)cmd{
//    NSInteger len = 0;
//    if (data.length > 5) {
//        unsigned char c = 0;
//        [data getBytes:&c length:1];
//        if (c != 0x44) {
//            len = -1;
//        }
//
//        [data getBytes:&c range:NSMakeRange(4, 1)];
//        if (c != cmd) {
//            len = -1;
//        }
//
//        unsigned short length = 0;
//        if (len != -1) { //说明是读取定时器返回的数据
//            [data getBytes:&length range:NSMakeRange(2, 2)];
//            len = length + 6;  //head 4 + end 2 = 6
//        }
//    }
//    else {
//        len = -1;
//    }
//
//    return len;
//}
//
////拼包
//- (NSData *)pastePacketData:(NSData *)data forCMD:(DTDataReturnType)cmd{
//    DTLog(@"定时器组包接收到的数据：%@",data);
//    if (data == nil) {
//        [self clearPastePacketData];
//        return nil;
//    }
//
//    if (_totalLen > 0) { //已经有数据加入
//        if (self.mutableData.length < _totalLen) {
//            [self.mutableData appendData:data];
//            DTLog(@"定时器组包拼接数据:%@",self.mutableData);
//        }
//
//        if (self.mutableData.length == _totalLen) {
//            unsigned char surfix;
//            [self.mutableData getBytes:&surfix range:NSMakeRange(_totalLen-1, 1)];
//            if (surfix == 0x54) {
//                DTLog(@"得到最后的粘包数据:%@",self.mutableData);
//                NSData *resultData = [self.mutableData copy];
//                [self clearPastePacketData];
//                return resultData;
//            }
//            [self clearPastePacketData];
//        }
//        else if (self.mutableData.length > _totalLen) {
//            [self clearPastePacketData];
//            return nil;
//        }
//    }
//    else {
//        _totalLen = [self totalLenOfReceiveData:data forCMD:cmd];
//        _ispasting = YES;
//        _pastingType = cmd;
//        if (_totalLen > 0) {
//            [self.mutableData appendData:data];
//            unsigned char surfix;
//            [self.mutableData getBytes:&surfix range:NSMakeRange(self.mutableData.length-1, 1)];
//            if (surfix == 0x54 && _totalLen == data.length) { //第一个包就是最后一个包
//                DTLog(@"得到最后的粘包数据:%@",self.mutableData);
//                NSData *resultData = [self.mutableData copy];
//                [self clearPastePacketData];
//                return resultData;
//            }
//        }
//        else {
//            [self clearPastePacketData];
//        }
//
//    }
//    return nil;
//}





@end
