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



@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CBUUID *uuid = [CBUUID UUIDWithString:@"FFF0"];
    DTBLEManager *manager = [DTBLEManager shareManagerWithIdentifier:@"TestMananger" services:@[uuid]];
    __weak typeof(self) weakSelf = self;
    [manager addObserver:self centralManagerUpdateBlock:^(CBCentralManager *central) {
        NSLog(@"状态发生改变:%d",central.state);
    }];
}



#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cellId"];
    }
    if (self.list.count <= indexPath.row) {
        return nil;
    }
    CBPeripheral *peripheral = [self.list objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.localName;
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
    cell.detailTextLabel.text = state;
    return cell;
}


#pragma mark - private
- (NSMutableArray *)list {
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
