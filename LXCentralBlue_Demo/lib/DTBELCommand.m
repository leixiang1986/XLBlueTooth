//
//  DTBELCommand.m
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import "DTBELCommand.h"



@implementation DTBELCommand

+(NSData *)authPerWithMacData:(NSData *)data{
    // NSData --> Byte
    Byte *byteArray = (Byte *)[data bytes];
    if (data.length < 8) {
        return nil;
    }
    char abcde[6] = {0};
    for (int i=2; i<8; i++) {
        abcde[i-2]=byteArray[i];
    }
    
    
    char abc[1] = {0};
    for (int i=0; i<6; i++) {
        char b = abcde[i];
        abc[0] = (abc[0])^b;
    }
    
    NSData *authData = [NSData dataWithBytes: abc length:1];
    
    return authData;
}


//通过密码获取输入密码的结构体
+ (data_inputpwd_t)inputPwdStructWithPwd:(NSString *)pwdStr {
    data_inputpwd_t inputpwd = {0};
    NSData *pwdData = [pwdStr dataUsingEncoding:NSUTF8StringEncoding];
    DTLog(@"密码长度:%ld",pwdData.length);
    inputpwd.cmd = 0x90;
    inputpwd.length = pwdData.length;
    memcpy(inputpwd.old_pwd, [pwdData bytes], pwdData.length);
    
    return inputpwd;
}


//输入密码或修改密码数据
+ (NSData *)pwdDataOldPwd:(NSString *)oldPwd newPwd:(NSString *)pwd {
    if (oldPwd.length == 0 ) {
        return nil;
    }
    

    data_inputpwd_t input_pwd = [self inputPwdStructWithPwd:oldPwd];
    input_pwd.cmdLen = sizeof(input_pwd) - 3;
    input_pwd.type = 0xA0;
    
    if (pwd.length) {
        NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding]; //新密码的data
        unsigned char len = 2;
        len = len << 4;
        input_pwd.length = input_pwd.length | len; //高位是新密码的长度
        input_pwd.type = 0xA1;
        memcpy(input_pwd.new_pwd, [pwdData bytes], sizeof(input_pwd.new_pwd));
    }
    else {
        unsigned char len = 1;
        len = len << 4;
        input_pwd.length = input_pwd.length | len; //高位是新密码的长度
        memset(input_pwd.new_pwd, '\0', sizeof(input_pwd.new_pwd));
    }

    NSMutableData *mutableData = [[NSMutableData alloc] init];
    [mutableData appendBytes:&input_pwd length:sizeof(input_pwd)];
    DTLog(@"密码数据:%@",mutableData);
    
    return [mutableData copy];
}

//开关数据
+ (NSData *)switchData:(BOOL)open {
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    unsigned char flag = open ? 0x1: 0x0;
    data_switch_t sw = {0};
    sw.cmd = 0x70;
    sw.flag = flag;
    sw.len = 1;
    
    NSData *data = [NSData dataWithBytes:&sw length:sizeof(sw)];
    [resultData appendData:data];
    
    return [resultData copy];
}

//延时,cmd代表开关1为开，0为关
+ (NSData *)delayData:(UInt32)seconds open:(BOOL)open{
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    data_delay_t delay = {0};
    delay.cmd = 0x71;
    delay.len = sizeof(delay.seconds) + sizeof(delay.on);
    delay.on = open ? 1:0;
    DTLog(@"测试delay.seconds长度:%d",delay.len);
    delay.seconds = seconds;
    [resultData appendBytes:&delay length:sizeof(delay)];
    
    return [resultData copy];
}

//循环开关命令
+ (NSData *)circulationDataWithStartSeconds:(UInt32)starts stopSeconds:(UInt32)stops {
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    data_circulation_open_t circulation = {0};
    circulation.cmd = 0x72;
    circulation.len = sizeof(circulation.startSec) + sizeof(circulation.stopSec);
    circulation.startSec = starts;
    circulation.stopSec = stops;
    [resultData appendBytes:&circulation length:sizeof(circulation)];
    
    return [resultData copy];
}

//关闭延时或循环
+ (NSData *)closeDelayOrCircle:(DTCloseDelayOrCircleType)type {
    NSMutableData *resultData = [NSMutableData dataWithCapacity:sizeof(data_delay_close_t)];
    
    data_delay_close_t delayClose = { 0 };
    delayClose.cmd = 0x74;
    delayClose.len = 1;
    delayClose.type = type;
    [resultData appendBytes:&delayClose length:sizeof(data_delay_close_t)];
    
    return [resultData copy];
}


//时间校时指令数据
+ (NSData *)currentTimeData{
    
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unit fromDate:date];
    
    data_time_t time = {0};
    time.cmd = 0x80;
    time.len = sizeof(time) - sizeof(time.len) - sizeof(time.cmd);
    time.type = 1;
    time.year = components.year;
    time.month = components.month;
    time.week = components.weekday - 1;
    time.day = components.day;
    time.hour = components.hour;
    time.minite = components.minute;
    time.second = components.second;
    NSMutableData *resultData = [[NSMutableData alloc] init];
    [resultData appendBytes:&time length:sizeof(time)];
    DTLog(@"校时的的数据:%@==%@",resultData,date);
    return [resultData copy];
}

+ (NSData *)quetyCurrentTimeData {
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:4];
    unsigned char cmd = 0x80;
    [data appendBytes:&cmd length:1];
    unsigned short len = 1;
    [data appendBytes:&len length:sizeof(len)];
    unsigned char type = 2;
    [data appendBytes:&type length:sizeof(type)];
    return data;
}



//定时器设置指令
+ (NSData *)setupTimerData:(data_timing_t*)timing {
    NSMutableData *resultData = [[NSMutableData alloc] init];

    timing->cmd = 0x81;
    timing->len = sizeof(data_timing_t) - sizeof(timing->len) - sizeof(timing->cmd);
    [resultData appendBytes:timing length:sizeof(data_timing_t)];
    DTLog(@"定时器发送指令:%@",resultData);
    return [resultData copy];
}

//读取定时器指令
+ (NSData *)readTimerData {
    NSMutableData *resultData = [[NSMutableData alloc] init];
    data_timerable_t timer_able = { 0 };
    timer_able.cmd = 0x83;
    timer_able.len = sizeof(data_timerable_t) - sizeof(timer_able.len) - sizeof(timer_able.cmd);
    timer_able.type = 0xBC;
    timer_able.order = 0xFF;
    timer_able.func = 0xFF;
    [resultData appendBytes:&timer_able length:sizeof(timer_able)];
    
    return [resultData copy];
}

//读取延迟开关和循环开关数据的指令
+ (NSData *)readDelayAndCircleData {
    NSMutableData *resultData = [[NSMutableData alloc] initWithCapacity:3];
    data_delay_read_t delayRead = {0};
    delayRead.cmd = 0x73;
    delayRead.len = 0;
    [resultData appendBytes:&delayRead length:sizeof(delayRead)];
    
    return [resultData copy];
}


+ (NSData *)deleteTimerDataWithOrder:(unsigned char)order {
    NSMutableData *resultData = [[NSMutableData alloc] init];
    data_timerable_t timer_able = {0};
    timer_able.cmd = 0x83;
    timer_able.len = sizeof(data_timerable_t) - sizeof(timer_able.len) - sizeof(timer_able.cmd);
    timer_able.type = 0xBD;
    timer_able.order = order;
    timer_able.func = 0xFF;
    [resultData appendBytes:&timer_able length:sizeof(timer_able)];
    
    return [resultData copy];
}


//最长不超过17
+ (NSData *)dataOfModifyName:(NSString *)nameStr {
    if (nameStr.length == 0) {
        return nil;
    }

    NSData *nameData = [nameStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    data_modifyname_t name_s = {0}; //修改名字结构体
    name_s.cmd = 0xA0;
    name_s.len = nameData.length;
    [resultData appendBytes:&name_s length:sizeof(name_s)];
    
    [resultData appendData:nameData];
    
    return [resultData copy];
}
#pragma mark - 返回数据的处理

//定时器设置返回指令:82
//timing_return为传出参数
//return表示是否成功
//+ (BOOL)timingReturn:(data_timing_return_t *)timing_return data:(NSData *)data {
//    DTDataReturnType type = [self returnType:data];
//    if (type != DTDataReturnType_setupTimer) {
//        return NO;
//    }
//
//    [data getBytes:timing_return length:sizeof(timing_return)];
//
//    return YES;
//}

////定时器使能指令返回
////通过block传出解析的数据，timerAble_return使能返回值,ableType使能的类型,timers在查询类型时得到的定时器数据
//+ (BOOL)timerAbleWithData:(NSData *)data block:(void(^)(data_timerable_return_t timerAble_return, DTDataReturnTimerAbleType ableType, data_timing_t *timers))block{
//
//    DTDataReturnType type = [self returnType:data];
//    if (type != DTDataReturnType_timerAble) {
//        return NO;
//    }
//
//    data_timerable_return_t timerAble_r ;  //定时器使能返回数据结构体,没有包含返回的定时器数组
//    [data getBytes:&timerAble_r range:NSMakeRange(sizeof(packet_head_t), sizeof(timerAble_r))];
//
//    //使能查询的返回
//    if (timerAble_r.timer_able.type == DTDataReturnTimerAbleType_query) {
//#warning 注意不一定是data_timing_t结构体
//        data_timing_t *timers_p = NULL;
//        if (timerAble_r.result > 0) {
//            timers_p = calloc(timerAble_r.result, sizeof(data_timing_return_t)); //block调用过后释放掉
//            [data getBytes:timers_p range:NSMakeRange(sizeof(packet_head_t) + sizeof(timerAble_r), timerAble_r.result * sizeof(data_timing_t))];
//        }
//
//        if (block) {
//            block(timerAble_r,timerAble_r.timer_able.type,timers_p);
//            block = nil;
//            free(timers_p);  //调用过后释放指针指向的对象
//        }
//        return YES;
//    }
//    else if (timerAble_r.timer_able.type == DTDataReturnTimerAbleType_delete || timerAble_r.timer_able.type == DTDataReturnTimerAbleType_setup) { //使能删除和设置的返回
//        block(timerAble_r,timerAble_r.timer_able.type,NULL);
//        return YES;
//    }
//    else {
//        return NO;
//    }
//}

//密码写入后的返回数据
//pwd_return返回数据
+ (BOOL)pwdReturn:(data_inputpwd_return_t *)pwd_return FormData:(NSData *)data {
    
    if (data.length != sizeof(data_inputpwd_return_t)) {
        DTLog(@"XXXXXXXXXXX密码返回数据长度和定义长度不同:%@==%ld==%ld",data,data.length,sizeof(data_inputpwd_return_t));
        return NO;
    }
    
    [data getBytes:pwd_return length:data.length];
    
    return YES;
}


//获取返回数据的类型
+ (DTDataReturnType)returnType:(NSData *)data {
    if (data.length <= sizeof(packet_head_t) + 3) {
        return DTDataReturnType_none;
    }
    unsigned char cmd ;
    [data getBytes:&cmd range:NSMakeRange(sizeof(packet_head_t), 1)];
    if (cmd == DTDataReturnType_setupTimer) { //设置定时器返回结果
        return DTDataReturnType_setupTimer;
    }
    else if (cmd == DTDataReturnType_timerAble) { //定时器使能
        return DTDataReturnType_timerAble;
    }
    else if (cmd == DTDataReturnType_pwd) {  //密码
        return DTDataReturnType_pwd;
    }
    else if (cmd == DTDataReturnType_universal) { //通用返回
        return DTDataReturnType_universal;
    }
    else if (cmd == DTDataReturnType_queryDelay) {
        return DTDataReturnType_queryDelay;
    }
    else if (cmd == DTDataReturnType_queryCircle) {
        return DTDataReturnType_queryCircle;
    }
    else if (cmd == DTDataReturnType_deleteDelay) {
        return DTDataReturnType_deleteDelay;
        
    }
    return DTDataReturnType_none;
}

//返回通用类型的子类型
+ (DTDataReturnUniversalType)returnUniversalType:(NSData *)data {
    if (data.length != 11) {
        return DTDataReturnUniversalType_none;
    }
    unsigned char cmd ;
    [data getBytes:&cmd range:NSMakeRange(7, 1)];
    
    return cmd;
}


#pragma mark - private method




//得到数据的亦或校验值
+ (unsigned char)XORData:(NSData *)data {
    if (data.length <= 1) {
        return '\0';
    }
    unsigned char crc = 0xE0;
    
    Byte *byte = (Byte *)[data bytes];
    for (NSInteger i = 1; i < data.length; i++) {
        crc ^= *(byte + i);
    }
    return crc;
}

//包头数据
+ (packet_head_t)packetHead {
    packet_head_t packet_head = {0};
    packet_head.head = 0x44;
    packet_head.ram = arc4random() % 256;
    return packet_head;
}

//入参是拼接好的包头和data数据(注意在内部改变了包头的长度)
+ (NSData *)addEndPacketForData:(NSData *)data {
    //修改包头长度数据
    NSMutableData *mutableData = [[NSMutableData alloc] initWithData:data];
    unsigned short len = data.length - 4; //减去包头的4字节就是数据的长度
    [mutableData replaceBytesInRange:NSMakeRange(2, 2) withBytes:&len];
    //校验码
    unsigned char rcr = [self XORData:mutableData];
    packet_end_t packet_end;
    packet_end.end = 0x54;
    packet_end.rcr = rcr;
    
    [mutableData appendBytes:&packet_end length:sizeof(packet_end_t)];
    
    DTLog(@"最终数据:%@",mutableData);
    return [mutableData copy];
}

@end
