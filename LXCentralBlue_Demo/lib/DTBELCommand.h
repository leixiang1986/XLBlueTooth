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

//开关的结构体
typedef struct {
    unsigned char cmd; //70
    unsigned short len;  //长度
    unsigned char flag; //1为开，0位关
}data_switch_t;

//延时结构体
typedef struct {
    unsigned char cmd; //71
    unsigned short len;  //长度
    UInt8 on;          //延时开启还是延时关闭
    UInt32 seconds; //秒数
}data_delay_t;

//连续循环开关
typedef struct {
    unsigned char cmd;
    unsigned short len;
    UInt32 startSec;     //开启时间间隔
    UInt32 stopSec;      //结束时间间隔
}data_circulation_open_t;


//校时结构体
typedef struct {
    unsigned char cmd;      //80
    unsigned short len;      //长度
    unsigned char type;     //类型:1设置，2查询，3回应
    unsigned short year;     //低位在前，比如2000（0x07D0），则数据格式为0xD0,0x07，变化范围2000~2255
    unsigned char month;    //1-12
    unsigned char day;      //0-31
    unsigned char week;     //0为周日，0-6
    unsigned char hour;     //0-23
    unsigned char minite;   //0-59
    unsigned char second;   //0-59
}data_time_t;

//定时器使能指令返回的定时器内容结构体,是定时器指令去掉命令和长度
typedef struct {
    unsigned char order;    //序号
    unsigned char s_flag;   //开始标记
    unsigned char s_hour;
    unsigned char s_minite;
    unsigned char e_flag;
    unsigned char e_hour;
    unsigned char e_minite;
    unsigned char repeat;   //是否重复
    unsigned char on;       //是否开启
}data_timingcontent_t;

//设置定时器
typedef struct {
    unsigned char cmd;      //81
    unsigned short len;     //长度
    data_timingcontent_t timingContent; //定时器内容结构体
}data_timing_t;

//设置定时器返回结果
typedef struct {
    packet_head_t head;
    unsigned char cmd;    //82
    unsigned short len;
    unsigned char order;  //序号1-100
    unsigned char result; //1成功，0失败
    unsigned char type;   //1重新生成，2更新内容
    packet_end_t end;
}data_timing_return_t;

//定时器使能指令
typedef struct {
    unsigned char cmd;      //83,返回状态84
    unsigned short len;      //长度
    unsigned char type;     //操作类型:设置0xBE,查询0xBC,删除0xBD
    unsigned char order;    //1-100,0xFF表示所有
    unsigned char func;     //功能,设置0x2开始时间，0x4结束时间，0x8重复状态,开启状态0x10,查询所有用0xFF
}data_timerable_t;

//定时器使能指令返回
typedef struct {
    packet_head_t head;
    data_timerable_t timer_able;
    unsigned char result;         //返回结果,在删除和设置时，成功1，失败0；在查询所有时，代表记录的总数
    unsigned char data[0];        //在查询时，记录n条定时器指令的数组(在实际使用时，这里不赋值，只是起到提示作用)；在删除和设置时，不用设置
}data_timerable_return_t;

//读取延迟开关循环的数据
typedef struct {
    unsigned char cmd;
    unsigned short len;
}data_delay_read_t;

//查询延迟开关的返回数据
typedef struct {
    packet_head_t head;
    unsigned char cmd;   //71延迟开关,72循环开关
    unsigned short len;
    unsigned char on;   //是开还是关
    uint32_t seconds;
    packet_end_t end;
}data_query_delay_return_t;

//查询循环开关的返回数据
typedef struct {
    packet_head_t head;
    unsigned char cmd;
    unsigned short len;
    uint32_t startInterval;
    uint32_t endInterval;
    packet_end_t end;
}data_query_circle_return_t;


//延时循环的关闭
typedef struct {
    unsigned char cmd;
    unsigned short len;
    unsigned char type;     //1为关闭延时，2为关闭循环
}data_delay_close_t;


//延时到期后删除延时回数据
typedef struct {
    packet_head_t head;
    unsigned char cmd;
    unsigned short len;
    unsigned char type; //1表示关闭延时，2表示关闭循环
    packet_end_t end;
}data_delete_delay_return_t;


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

//修改名称
typedef struct {
    unsigned char cmd;
    unsigned short len;  //命令把长度,最长17
    unsigned char data[0]; //名字数据
}data_modifyname_t;

//通用的返回结果结构体
typedef struct {
    unsigned char cmd;          //返回命令FD
    unsigned short len;
    unsigned char return_cmd;   //返回的命令
    unsigned char result;       //成功0，失败1，密码错误2，未登录3
}data_return_t;


#pragma pack(pop)


@interface DTBELCommand : NSObject
#pragma mark - 发送数据
//得到认证数据
+ (NSData *)authPerWithMacData:(NSData *)data;

//输入密码或修改密码数据,在输入密码时，pwd传nil
+ (NSData *)pwdDataOldPwd:(NSString *)oldPwd newPwd:(NSString *)pwd;

//开关数据
+ (NSData *)switchData:(BOOL)open;

//延时
+ (NSData *)delayData:(UInt32)seconds open:(BOOL)open;

//循环开关命令
//interval 时间间隔，单位毫秒
+ (NSData *)circulationDataWithStartSeconds:(UInt32)starts stopSeconds:(UInt32)stops;

//关闭延时或循环
+ (NSData *)closeDelayOrCircle:(DTCloseDelayOrCircleType)type;

//时间校准数据
+ (NSData *)currentTimeData;

+ (NSData *)quetyCurrentTimeData;

//定时器设置指令
+ (NSData *)setupTimerData:(data_timing_t*)timing;

//读取定时器指令
+ (NSData *)readTimerData;

//读取延迟开关和循环开关数据的指令
+ (NSData *)readDelayAndCircleData;

//删除定时器
+ (NSData *)deleteTimerDataWithOrder:(unsigned char)order;

//修改名字
+ (NSData *)dataOfModifyName:(NSString *)nameStr;

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
