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

#pragma mark - 返回数据的处理



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
