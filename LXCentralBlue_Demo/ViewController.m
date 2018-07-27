//
//  ViewController.m
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/24.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "ViewController.h"
#import "CBPeripheral+Extension.h"
#import "DTBLEManager.h"
#import "DetatilViewController.h"
#import "DeviceTableViewCell.h"
#import "BLEDataManager.h"
#import "DTBELCommand.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFF0"];
    weakSelf(weakSelf)
    DTBLEManager *manager = [DTBLEManager shareManagerWithIdentifier:@"TestMananger" services:@[uuid] block:^(NSArray *discoveredPers) {
        [BLEDataManager shareManager].peripherals = discoveredPers;
        [weakSelf.tableView reloadData];
    }];

    [manager setScanFilterBlock:^BOOL(CBPeripheral *peripheral, NSDictionary *advertisementData) {
        return [self isSwitcher:advertisementData];
    }];
    
    [self observeBLECallBack];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:(UIControlEventValueChanged)];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"正在刷新" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    [self.tableView insertSubview:refresh atIndex:0];
}


- (void)observeBLECallBack {
    //断开连接
    [DTBLEManager shareManager].disconnectBlock = ^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开了连接:%@==%@",error,peripheral);
        [self.tableView reloadData];
    };
    
    [[DTBLEManager shareManager] addObserver:self centralManagerUpdateBlock:^(CBCentralManager *central) {
        NSLog(@"状态发生改变:%d",central.state);
        if (central.state == CBCentralManagerStatePoweredOn) {
            [[DTBLEManager shareManager] clearDiscoveredPersExceptConnectedPer:NO];
        }
        [self.tableView reloadData];
    }];
    

}


- (void)refresh:(id)sender {
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFF0"];
    weakSelf(weakSelf)
    [[DTBLEManager shareManager] scanPeripheralWithServices:@[uuid] stopDelay:5 block:^(NSArray *discoveredPers) {
        NSLog(@"===========下拉刷新的扫描:%@",discoveredPers);
        [BLEDataManager shareManager].peripherals = discoveredPers;
        [weakSelf.tableView reloadData];
    }];
    UIRefreshControl *refresh = (id)sender;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refresh endRefreshing];
    });
}

- (BOOL)isSwitcher:(NSDictionary *)advertiseData {
    NSData *data = advertiseData[@"kCBAdvDataManufacturerData"];
    if ([data isKindOfClass:[NSData class]] && data.length == 14) {
        NSData *subData = [data subdataWithRange:NSMakeRange(8, 6)];
        NSString *surfix = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
        return [surfix isEqualToString:@"-fdore"];
    }
    
    return NO;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [BLEDataManager shareManager].peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceTableViewCell" owner:nil options:nil] lastObject];
    }
    if ([BLEDataManager shareManager].peripherals.count <= indexPath.row) {
        return nil;
    }
    CBPeripheral *peripheral = [[BLEDataManager shareManager].peripherals objectAtIndex:indexPath.row];
    cell.peripheral = peripheral;
    weakSelf(weakSelf)
    cell.stateClickBlock = ^(DeviceTableViewCell *cell) {
        if (cell.peripheral.isConnected) {
            [[DTBLEManager shareManager] disconnectPeripheral:cell.peripheral block:^(CBPeripheral *peripheral, NSError *error) {
                [peripheral clearBindDatas];
            }];
        }
        else {
            [weakSelf connectPeripheral:cell.peripheral];
        }
        
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([BLEDataManager shareManager].peripherals.count <= indexPath.row) {
        return;
    }
    
    CBPeripheral *peripheral = [[BLEDataManager shareManager].peripherals objectAtIndex:indexPath.row];
    if (peripheral.isConnected) {
        [self pushToDetail];
        return;
    }
    //连接，发现服务，发现特征操作
    [self connectPeripheral:peripheral];
}

//连接，发现服务，发现特征操作
- (void)connectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral == nil) {
        return;
    }
    
    if (peripheral.isConnected) {
        NSLog(@"处理已经连接的情况:%@",peripheral);
        return;
    }
    
    [[BLEDataManager shareManager] connectPeriperal:peripheral block:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"发现特征:%@===error:%@",peripheral.discoveredService.characteristics,error);
        if (error) {
            NSLog(@"连接错误的原因:%@",error);
            return ;
        }
        //添加到自动重连数组中
        [[DTBLEManager shareManager] addPeripheralToReconnect:peripheral];
        
        //设置数据回调的监听
        for (CBCharacteristic *ch in peripheral.discoveredService.characteristics) {
            if ((ch.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {  //可以通知的特征
                NSLog(@"可以通知的特征:%@",ch);
                [peripheral setNotifyValueForObserver:self forCharacteristic:ch stateBlock:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
                    NSLog(@"监听外设的状态是否成功:%@==error:%@",characteristic,error);
                    if (error) {
                        [[DTBLEManager shareManager] disconnectPeripheral:peripheral block:^(CBPeripheral *peripheral, NSError *error) {
                            NSLog(@"连接失败---监听数据失败");
                        }];
                    }
                    else {
                        //发送认证数据
                        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF7"]) {
                            [self sendAuthenticationData];
                        }
                    }
                    
                } notifyBlock:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
                    NSLog(@"监听外设的数据:%@==error:%@",characteristic,error);
                    if ([characteristic.UUID.UUIDString isEqualToString:@"FFF7"]) { //通知数据
                        
                    }
                    else if ([characteristic.UUID.UUIDString isEqualToString:@"FFF8"]) {  //开关的状态，可读可监听
                        
                    }
                }];
            }
        }
    }];
}


- (void)sendAuthenticationData {
    if (![BLEDataManager shareManager].currentPeripheral.isConnected) {
        return;
    }
    NSData *advData = [[BLEDataManager shareManager].currentPeripheral.advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSData *data = [DTBELCommand authPerWithMacData:advData];
    CBCharacteristic *ch = [[BLEDataManager shareManager] characteristicOfUUIDString:@"FFF1"];
    if (ch == nil) {
        return;
    }
    weakSelf(weakSelf)
    [[BLEDataManager shareManager].currentPeripheral writeValue:data forCharacteristic:ch observer:self block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error, BOOL hasResponse) {
        if (error) {
            NSLog(@"写入有误:%@===%@",characteristic,error);
        }
        else {
            NSLog(@"写入认证数据成功:%@===",characteristic);
            [weakSelf sendPasswordData];
        }
        NSLog(@"写入了认证数据:%@",characteristic);
        [weakSelf.tableView reloadData];
    }];
    
    
}

//发送密码数据
- (void)sendPasswordData {
    NSData *data = [DTBELCommand pwdDataOldPwd:@"1234" newPwd:nil];
    CBCharacteristic *ch = [[BLEDataManager shareManager] characteristicOfUUIDString:@"FFF2"];
    if (ch == nil) {
        return;
    }
    
    [[BLEDataManager shareManager].currentPeripheral writeValue:data forCharacteristic:ch observer:self block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error, BOOL hasResponse) {
        NSLog(@"写入了密码数据:%@==error:%@",characteristic,error);
    }];
}


//跳转到详情
- (void)pushToDetail {
    if (![BLEDataManager shareManager].currentPeripheral.isConnected) {
        return;
    }
    
    DetatilViewController *vc = [[DetatilViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - private


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
