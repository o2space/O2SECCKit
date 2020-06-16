//
//  O2SSMxUtils.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface O2SSMxUtils : NSObject

/// 转换16进制字符串为NSData
/// @param string 二进制流的16进制字符串
/// @return 二进制数据对象
+ (NSData *)dataByHexString:(NSString *)string;

/// 将数据转换成16进制字符串
/// @param data data 原始数据
/// @return 字符串
+ (NSString *)hexStringByData:(NSData *)data;


/// 将 NSData 进行 Base64编码
/// @param data 原始数据
/// @return Base64编码后结果
+ (NSString *)stringByBase64EncodeData:(NSData *)data;


/// 将Base64编码的值 进行解码
/// @param string Base64编码的值
/// @return Base64解码结果 Data类型
+ (NSData *)dataByBase64DecodeString:(NSString *)string;


/// 将Base64编码的值 进行解码
/// @param string Base64编码的值
/// @return Base64解码结果 Data类型在转成原始String类型
+ (NSString *)stringByBase64DecodeString:(NSString *)string;

/// 16进制字符串根据长度补齐，不够左边0补齐
/// @param input 16进制字符串
/// @param num 总长度
+ (NSString *)leftPad:(NSString *)input num:(NSUInteger)num;

@end
