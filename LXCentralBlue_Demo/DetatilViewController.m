//
//  DetatilViewController.m
//  LXCentralBlue_Demo
//
//  Created by fuzzy@fdore.com on 2018/7/26.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DetatilViewController.h"

@interface DetatilViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *list;
@end

@implementation DetatilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    
    
    return cell;
}



@end
