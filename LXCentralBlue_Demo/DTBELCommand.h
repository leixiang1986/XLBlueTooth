//
//  DTBELCommand.h
//  powercontrol
//
//  Created by leifayang on 2018/6/13.
//  Copyright © 2018年 datangtiancheng. All rights reserved.
//

#import <Foundation/Foundation.h>


//返回数据的类型
typedef NS_ENUM(NSInteger, DTDataReturnType)  {
    DTDataReturnType_none           = 0x00,
    DTDataReturnType_queryDelay     = 0x71,     //查询延时的返回
    DTDataReturnType_queryCircle    = 0x72,     //查询循环返回
    DTDataReturnType_deleteDelay    = 0x74,     //延迟时间到了，需要删除
    DTDataReturnType_setupTimer     = 0x82,     //设置定时器返回返回82
    DTDataReturnType_timerAble      = 0x84,     //定时器使能返回数据84
    DTDataReturnType_pwd            = 0x91,     //密码返回指令91
    DTDataReturnType_universal      = 0xfd,     //通用的返回类型fd
    DTDataReturnType_switch         = 0xff,     //开关的数据返回
};

//返回数据通用类型的子类型
typedef NS_ENUM(NSInteger, DTDataReturnUniversalType) {
    DTDataReturnUniversalType_none          = 0,
    DTDataReturnUniversalType_modifyName    = 0xA0,           //修改名字
    DTDataReturnUniversalType_setupDelay    = 0x71,           //设置延时返回
    DTDataReturnUniversalType_setupCircle   = 0x72,           //设置循环返回
    DTDataReturnUniversalType_deleteDelay   = 0x74            //删除
};

//返回定时器使能指令的子类型
typedef NS_ENUM(NSInteger, DTDataReturnTimerAbleType) {
    DTDataReturnTimerAbleType_setup     = 0xBE,     //设置
    DTDataReturnTimerAbleType_query     = 0xBC,     //查询
    DTDataReturnTimerAbleType_delete    = 0xBD      //删除
};

//密码类型
typedef NS_ENUM(NSInteger, DTPasswordType) {
    DTPasswordType_login    = 0xA0,     //登录
    DTPasswordType_modify   = 0xA1      //修改密码
};

//关闭是延时还是循环
typedef NS_ENUM(NSInteger, DTCloseDelayOrCircleType) {
    DTCloseDelayOrCircleType_delay  = 1,   //关闭延时
    DTCloseDelayOrCircleType_circle = 2     //关闭循环
};

#pragma pack(push, 1)
/*****  包头包尾 ******/
//包头
typedef struct {
    unsigned char head;
    unsigned char ram;
    unsigned short length;
}packet_head_t;

//包尾
typedef struct {
    unsigned char rcr;
    unsigned char end;
}packet_end_t;

/*****  数据部分 ******/



















//输入密码
typedef struct {
    unsigned char cmd;      //指令0x90
    unsigned short cmdLen;  //命令长度
    unsigned char type;     //输入0xA0,修改0xA1
    unsigned char length;
    unsigned char old_pwd[4];
    unsigned char new_pwd[4];
}data_inputpwd_t;

//密码返回
typedef struct {
    packet_head_t head;
    unsigned char cmd;       //指令0x91
    unsigned short len;
    unsigned char returnCmd; //回复的类型A0是登录，A1是修改密码
    unsigned char result;    //结果，成功1，失败0
    unsigned char reason;    //原因，正常0，登录1，错误密码2，错误密码格式3
    packet_end_t end;
}data_inputpwd_return_t;



#pragma pack(pop)


@interface DTBELCommand : NSObject
#pragma mark - 发送数据
//得到认证数据
+ (NSData *)authPerWithMacData:(NSData *)data;

//输入密码或修改密码数据,在输入密码时，pwd传nil
+ (NSData *)pwdDataOldPwd:(NSString *)oldPwd newPwd:(NSString *)pwd;


#pragma mark - 返回数据的处理

+ (DTDataReturnType)returnType:(NSData *)data;

+ (DTDataReturnUniversalType)returnUniversalType:(NSData *)data;

+ (BOOL)pwdReturn:(data_inputpwd_return_t *)pwd_return FormData:(NSData *)data;

//定时器设置返回指令:82
//timing_return为传出参数
//return表示是否成功
//+ (BOOL)timingReturn:(data_timing_return_t *)timing_return data:(NSData *)data;

////定时器使能指令返回
////通过block传出解析的数据，timerAble_return使能返回值,ableType使能的类型,timers在查询类型时得到的定时器数据
//+ (BOOL)timerAbleWithData:(NSData *)data block:(void(^)(data_timerable_return_t timerAble_return, DTDataReturnTimerAbleType ableType, data_timing_t *timers))block;



@end
