//
//  DTBLEManager.m
//  powercontrol
//
//  Created by leifayang on 2018/6/6.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DTBLEManager.h"
#import "DTBLEPeripherProxy.h"



/**
 可能存在的问题，需要验证:
 1，断开后，自动重连，设置的监听block是否有效
 答：给外设绑定的回调的block和传入参数，在主动断开才会清除，自动断开是不会清除的。所以不会出现这个问题.
 
 
 */

@interface DTBLEManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, strong, readwrite) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableArray *reconnectPerArr;  //自动重连数组
@property (nonatomic, strong, readwrite) NSMutableArray *discoveredPerArr; //发现的外设数组
@property (nonatomic, strong, readwrite) NSMutableArray *connectedPerArr; //连接的外设
@property (nonatomic, copy) DTStateChangedBlock discoveredBlock; //发现的外设
@property (nonatomic, strong) NSArray <CBUUID *>*defaultServices;   //蓝牙初始化后扫描用的服务UUID数组
@property (nonatomic, strong) PDTBLEManagerActionMananger *actionManager;
@end

@implementation DTBLEManager

+ (instancetype)shareManager {
    return [self shareManagerScanPeripheralWithDefaultServices:nil block:nil];
}

+ (instancetype)shareManagerScanPeripheralWithDefaultServices:(NSArray <CBUUID *>*)services block:(DTStateChangedBlock)block{
    return [self shareManagerWithIdentifier:nil services:services block:block];
    
}

+ (instancetype)shareManagerWithIdentifier:(NSString *)identifier services:(NSArray <CBUUID *>*)services block:(DTStateChangedBlock)block{
    static DTBLEManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DTBLEManager alloc] initWithIdentifier:identifier services:services block:block];
    });
    
    return instance;
}

- (instancetype)initWithIdentifier:(NSString *)identifier services:(NSArray <CBUUID *>*)services block:(DTStateChangedBlock)block{
    self = [super init];
    if (self) {
        _defaultServices = services;
        _discoveredBlock = block;
#if  __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
        NSDictionary *options = nil;
        if (identifier.length) {
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     //蓝牙power没打开时alert提示框
                                     [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                                     //重设centralManager恢复的IdentifierKey
                                     identifier,CBCentralManagerOptionRestoreIdentifierKey,
                                     nil];
        }
        else {
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     //蓝牙power没打开时alert提示框
                       [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey, nil
                                    ];
        }
#else
        NSDictionary *options = nil;
#endif
      
        NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"bluetooth-central"]) {
            //后台模式
            _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
        }
        else {
            //非后台模式
            _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        }
    }
    return self;
}


- (NSMutableArray *)reconnectPerArr {
    if (!_reconnectPerArr) {
        _reconnectPerArr = [NSMutableArray array];
    }
    return _reconnectPerArr;
}

- (NSMutableArray *)connectedPerArr {
    if (!_connectedPerArr) {
        _connectedPerArr = [[NSMutableArray alloc] init];
    }
    return _connectedPerArr;
}

- (NSMutableArray *)discoveredPerArr {
    if (!_discoveredPerArr) {
        _discoveredPerArr = [[NSMutableArray alloc] init];
    }
    return _discoveredPerArr;
}


- (NSArray *)connectedPers {
    return [_connectedPerArr copy];
}

- (NSArray *)autoReconnectPers {
    return [_reconnectPerArr copy];
}

- (NSArray *)discoveredPers {
    return [_discoveredPerArr copy];
}

#pragma mark - public method
//添加中心设备状态发生改变的监听
- (void)addObserver:(id)observer centralManagerUpdateBlock:(DTCentralStateUpdateBlock)centralManagerUpdateBlock {
    [self.actionManager addObserver:observer callBack:centralManagerUpdateBlock];
}


//清除发现的数据，刷新数据时，重新扫描
- (void)clearDiscoveredPersExceptConnectedPer:(BOOL)except {
    for (CBPeripheral *peripheral in self.discoveredPers) {
        if (except) {
            if (peripheral.state != CBPeripheralStateConnected) {
                [self.centralManager cancelPeripheralConnection:peripheral];
                [self.discoveredPerArr removeObject:peripheral];
            }
        }
        else {
            if (peripheral.state == CBPeripheralStateConnected) {
                [self.centralManager cancelPeripheralConnection:peripheral];
            }
            [self.discoveredPerArr removeObject:peripheral];
        }
    }
}

- (void)scanPeripheralWithServices:(NSArray <CBUUID *>*)services stopDelay:(NSTimeInterval)timeInterval block:(DTStateChangedBlock)block {
    _discoveredBlock = block;
    [self scanServices:services autoStop:timeInterval];
}

//连接并自动停止扫描
- (BOOL)scanServices:(NSArray <CBUUID *>*)services autoStop:(NSTimeInterval)timeInterval{
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self retrieveConnectedPeripherals];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
        if (timeInterval <= 0) {
            timeInterval = 5;
        }
        [self performSelector:@selector(stopScan) withObject:nil afterDelay:timeInterval];
        return YES;
    }

    return NO;
}

- (void)retrievePeripherals {
//    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"hahhaha"];
//    NSMutableArray *mutable = [NSMutableArray arrayWithCapacity:array.count];
//    for (NSString *str in array) {
//        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:str];
//        [mutable addObject:uuid];
//    }
//    NSArray *peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:[mutable copy]];
//    for (CBPeripheral *per in peripherals) {
//        [self addPeripheralToDiscoverPers:per];
//    }
//    NSLog(@"已知的外设:%@",peripherals);
}

//获取已经连接的外设,如果app发现的外设数组没有包含手机已经连接的外设，那么就断开连接
- (void)retrieveConnectedPeripherals {
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFF0"];
    NSArray *peripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:@[uuid]];
    for (CBPeripheral *per in peripherals) {
        BOOL flag = NO;
        for (CBPeripheral *peripheral in self.discoveredPers) {
            if ([per.identifier isEqual:peripheral.identifier]) {
                flag = YES;
            }
        }
        if (!flag) {
            [self.centralManager cancelPeripheralConnection:per];
        }
        
    }
}

- (void)stopScan {
    [self.centralManager stopScan];
}

//连接外设
- (void)connectPeripheral:(CBPeripheral *)peripheral option:(NSDictionary *)options block:(DTConnectBlock)block {
    if (peripheral == nil) {
        return;
    }
    peripheral.connectBlock = block;
    peripheral.connectOptions = options;
    peripheral.isReconnect = NO;
    [self.centralManager connectPeripheral:peripheral options:options];
}

//断开连接 (主动断开，内部如果自动重连，将外设从重连数组中删除)
- (void)disconnectPeripheral:(CBPeripheral *)peripheral block:(DTDisConnectBlock)block {
    if (peripheral == nil) {
        return;
    }
    DTLog(@"断开连接的外设:%@",peripheral.name);
    peripheral.disconnectBlock = block;
    peripheral.isReconnect = NO;
    [self removePeripheralFromReconnectPerArr:peripheral];
    if (peripheral.state != CBPeripheralStateDisconnected) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    else {
        if (block) {
            block(peripheral,nil); //如果已经断开直接返回断开的block
        }
    }
}



//将外设添加到自动重连中
- (void)addPeripheralToReconnect:(CBPeripheral *)peripheral {
    if (!peripheral) {
        return;
    }
    
    BOOL flag = NO;
    for (CBPeripheral *per in self.reconnectPerArr) {
        if ([per.identifier isEqual:peripheral.identifier]) {
            flag = YES;
        }
    }
    
    if (!flag) {
        [self.reconnectPerArr addObject:peripheral];
    }
}

//将外设从重连数组中移除
- (void)removePeripheralFromReconnectPerArr:(CBPeripheral *)peripheral {
    if (!peripheral) {
        return;
    }
    
    __block NSInteger index = -1;
    [self.reconnectPerArr enumerateObjectsUsingBlock:^(CBPeripheral *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqual:peripheral.identifier]) {
            index = idx;
        }
    }];
    if (index != -1) {
        [self.reconnectPerArr removeObjectAtIndex:index];
    }
}

- (void)removeFromDiscovers:(CBPeripheral *)per {
    if ([self.discoveredPers containsObject:per]) {
        [self.discoveredPerArr removeObject:per];
    }
}

#pragma mark - privatge method  私有辅助方法
//添加外设到发现数组中
- (void)addPeripheralToDiscoverPers:(CBPeripheral *)peripheral {
    if (!peripheral) {
        return;
    }
    
    BOOL flag = NO;
    for (CBPeripheral *per in self.discoveredPers) {
        if ([per.identifier isEqual:peripheral.identifier]) {
            flag = YES;
        }
    }
    
    if (!flag) {
        [self.discoveredPerArr addObject:peripheral];

    }
}



#pragma mark -- CBCentralManagerDelegate

//1,中心设备的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        for (CBPeripheral *per in self.connectedPers) {
            [self connectPeripheral:per option:nil block:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DTBLECentralPoweredOnNotification object:nil];
    }
    else if (central.state == CBCentralManagerStatePoweredOff) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DTBLECentralPoweredOffNotification object:nil];
    }
    //回调监听的事件
    [self.actionManager centralManagerStateUpdate:central];

    [self scanServices:nil autoStop:MAXFLOAT];
}

//2,
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSLog(@"==2，将要恢复:%@",dict);
    
    
}


//3,发现外设的代理，有外设包含的数据和信号强度
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (self.scanFilterBlock) { //过滤数据
        if (!self.scanFilterBlock(peripheral, advertisementData)) {
            return;
        }
    }
    DTLog(@"==3，发现外设:%@--",peripheral);
    //搜索到的数据
    peripheral.advertisementData = advertisementData;
    peripheral.rssi = RSSI;
    [self addPeripheralToDiscoverPers:peripheral];

    if (self.discoveredBlock) {
        self.discoveredBlock(self.discoveredPers);
    }
    if (self.stateChangedBlock) {
        self.stateChangedBlock(self.discoveredPers);
    }
}

//4,中心设备已经连接上外设的代理
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    DTLog(@"-==4,didConnectPeripheral");
    [[DTBLEPeripherProxy shareManager] delegateForPeripheral:peripheral];
    __block BOOL testFlag = NO;
    for (CBPeripheral *per in self.discoveredPers) {
        if ([peripheral.identifier isEqual:per.identifier]) { //是连接的外设
            DTConnectBlock block = per.connectBlock;
            testFlag = YES;
            [self.connectedPerArr addObject:peripheral];
            if (block) {
                block(peripheral,nil);
                DTLog(@"连接成功:%@",peripheral.name);
            }
        }
    }
    
    //回调外设状态
    if (peripheral.stateChangedBlock) {
        peripheral.stateChangedBlock(peripheral);
    }
    
    
    if (self.stateChangedBlock) {
        self.stateChangedBlock(self.discoveredPers);
    }
    if (!testFlag) {
        DTLog(@"连接了错误的外设XXXXXXXXXX:%@",peripheral);
        [self.discoveredPerArr addObject:peripheral];
    }
    if (peripheral.isReconnect) { //自动重连成功
        [[NSNotificationCenter defaultCenter] postNotificationName:DTBLEAutoConnectedNotification object:peripheral];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DTBLEConnectedNotification object:peripheral];
}

//5,中心设备连接外设失败的代理
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    DTLog(@"-==5,didFailToConnectPeripheral");
    for (CBPeripheral *per in self.discoveredPers) {
        if ([peripheral.identifier isEqual:per.identifier]) { //是连接的外设
            DTConnectBlock block = per.connectBlock;
            if (block) {
                block(peripheral,error);
                per.connectBlock = nil;
                DTLog(@"连接失败:%@",peripheral.name);
            }
        }
    }
    //回调外设状态
    if (peripheral.stateChangedBlock) {
        peripheral.stateChangedBlock(peripheral);
    }
    if (self.stateChangedBlock) {
        self.stateChangedBlock(self.discoveredPers);
    }
}

//6,中心设备断开了外设连接代理
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    DTLog(@"-==6,didDisconnectPeripheral:%@==error:%@",peripheral,error);
    for (CBPeripheral *per in self.connectedPers) {
        if ([peripheral.identifier isEqual:per.identifier]) {
            DTDisConnectBlock block = per.disconnectBlock;
            if (block) {
                block(peripheral,error);
                per.disconnectBlock = nil;
            }
            [[DTBLEPeripherProxy shareManager] removeDelegateForPeripheral:peripheral];
            
            if (!peripheral.isReconnect) {
                [peripheral clearBindDatas];
            }
        }
    }
    //回调外设状态
    if (peripheral.stateChangedBlock) {
        peripheral.stateChangedBlock(peripheral);
    }
    if (self.disconnectBlock) {
        self.disconnectBlock(peripheral, error);
    }
    
    //重新连接，如果在断开连接后直接去掉了绑定的事件，那么重连后会无法监听到事件
    if ([self.reconnectPerArr containsObject:peripheral]) {
        peripheral.isReconnect = YES;
        
        DTLog(@"自动连接的可选项:%@===%@",peripheral.connectOptions,self.reconnectPerArr);
        [self.centralManager connectPeripheral:peripheral options:peripheral.connectOptions];
    }
    
    if (self.stateChangedBlock) {
        self.stateChangedBlock(self.discoveredPers);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DTBLEDisconnectedNotification object:peripheral];
}

- (BOOL)checkState {
    BOOL stateOn = NO;
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {

        stateOn = YES;
    }

    return stateOn;
}


- (PDTBLEManagerActionMananger *)actionManager {
    if (!_actionManager) {
        _actionManager = [[PDTBLEManagerActionMananger alloc] init];
    }
    return _actionManager;
}

@end
