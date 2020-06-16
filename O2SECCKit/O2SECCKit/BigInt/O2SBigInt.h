//
//  O2SBigInt.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface O2SBigInt : NSObject

#pragma mark - 大数对象 初始化

/// 初始化大数对象
/// @return 大数对象
- (instancetype)init;

/// 初始化大数对象
/// @param value 整型数据
/// @return 大数对象
- (instancetype)initWithInt:(NSInteger)value;

/// 初始化大数对象
/// @param value 大数对象
/// @return 大数对象
- (instancetype)initWithBigInteger:(O2SBigInt *)value;

/// 初始化大数对象
/// @param valueString 数值字符串
/// @return 大数对象
- (instancetype)initWithString:(NSString *)valueString;

/// 初始化大数对象
/// @param valueString 数值字符串
/// @param radix       进制
/// @return 大数对象
- (instancetype)initWithString:(NSString *)valueString radix:(int)radix;

/// 初始化大数对象
/// @param bits 大素数位数
/// @return 大数对象
- (instancetype)initWithRandomPremeBits:(int)bits;

/// 初始化大数对象
/// @param bits 位数
/// @return 大数对象
- (instancetype)initWithRandomBits:(int)bits;

/// 初始化大数对象
/// @param bytes 字节流
/// @param size  长度
/// @return 大数对象
- (instancetype)initWithBytes:(const void *)bytes size:(int)size;

/// 初始化大数对象
/// @param bytes 无符号字节流
/// @param size  长度
/// @return 大数对象
- (instancetype)initWithUnsignedBytes:(const void *)bytes size:(int)size;

#pragma mark - 特殊大数对象 0，1

/// 获取 0
/// @return 大数对象
+ (O2SBigInt *)zero;

/// 获取 1
/// @return 大数对象
+ (O2SBigInt *)one;

#pragma mark - 大数运算

#pragma mark 加:

/// 大数相加
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)addByBigInt:(O2SBigInt *)value;

/// 大数相加
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)addByInt:(NSInteger)value;

#pragma mark 减：

/// 大数相减
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)subByBigInt:(O2SBigInt *)value;

/// 大数相减
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)subByInt:(NSInteger)value;

#pragma mark 乘：

/// 大数相乘
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)multiplyByBigInt:(O2SBigInt *)value;

/// 大数相乘
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)multiplyByInt:(NSInteger)value;

#pragma mark 除：

/// 大数相除
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)divideByBigInt:(O2SBigInt *)value;

/// 大数相除
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)divideByInt:(NSInteger)value;

#pragma mark 求余：

/// 大数求余
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)reminderByBigInt:(O2SBigInt *)value;

/// 大数求余
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)reminderByInt:(NSInteger)value;

#pragma mark 幂运算：

/// 大数幂运算
/// @param exponent 指数
/// @return 大数对象
- (O2SBigInt *)pow:(NSUInteger)exponent;

#pragma mark 幂运算求余：

/// 大数幂运算求余
/// @param exponent 指数
/// @param value    模数
/// @return 大数对象
- (O2SBigInt *)pow:(O2SBigInt *)exponent mod:(O2SBigInt *)value;

#pragma mark 平方：

/// 大数平方运算
/// @return 大数对象
- (O2SBigInt *)square;

#pragma mark 平方根：

/// 大数平方根运算
/// @return 大数对象
- (O2SBigInt *)sqrt;

#pragma mark 求反：

/// 大数求反
/// @return 大数对象
- (O2SBigInt *)negate;

#pragma mark 绝对值：

/// 大数绝对值
/// @return 大数对象
- (O2SBigInt *)abs;

#pragma mark 异或：

/// 大数位异或
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)bitwiseXorByBigInt:(O2SBigInt *)value;

/// 大数位异或
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)bitwiseXorByInt:(NSInteger)value;

#pragma mark 或：

/// 大数或
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)bitwiseOrByBigInt:(O2SBigInt *)value;

/// 大数或
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)bitwiseOrByInt:(NSInteger)value;

#pragma mark 与：

/// 大数与
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)bitwiseAndByBigInt:(O2SBigInt *)value;

/// 大数与
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)bitwiseAndByInt:(NSInteger)value;

#pragma mark 左移：

/// 左移
/// @param num 左移位数
/// @return 大数对象
- (O2SBigInt *)shiftLeft:(int)num;

#pragma mark 右移：

/// 右移
/// @param num 右移位数
/// @return 大数对象
- (O2SBigInt *)shiftRight:(int)num;

#pragma mark 最大公约数：

/// 最大公约数
/// @param value 大数对象
/// @return 大数对象
- (O2SBigInt *)gcdByBigInt:(O2SBigInt *)value;

/// 最大公约数
/// @param value 整数
/// @return 大数对象
- (O2SBigInt *)gcdByInt:(NSInteger)value;

#pragma mark 余逆：

/// 大数求余逆
/// @param n 阶数
/// @return 大数对象
- (O2SBigInt *)modInverseByBigInt:(O2SBigInt *)n;

/// 大数求余逆
/// @param n 阶数
/// @return 大数对象
- (O2SBigInt *)modInverseByInt:(NSInteger)n;

#pragma mark 余：

/// 大数求余
/// @param n 阶数
/// @return 大数对象
- (O2SBigInt *)modByBigInt:(O2SBigInt *)n;

/// 大数求余
/// @param n 阶数
/// @return 大数对象
- (O2SBigInt *)modByInt:(NSInteger)n;

#pragma mark - Other

/// 比较
/// @param value 大数对象
/// @return 比较结果
- (NSComparisonResult)compare:(O2SBigInt *)value;

/// 转换为字符串
/// @return 数值字符串
- (NSString *)toString;

/// 转换为字符串
/// @param radix 进制
/// @return 字符串
- (NSString *)toString:(int)radix;

/// 获取字节流
/// @param bytes  字节流
/// @param length 长度
- (void)getBytes:(void **)bytes length:(int *)length;

/// 获取无符号字节流
/// @param bytes  字节流
/// @param length 长度
- (void)getUnsignBytes:(void **)bytes length:(int *)length;

- (int)signum;

- (uint64_t)bitLength;

- (BOOL)testBit:(uint64_t)index;

@end


/// 商数和余数
@interface O2SBigInt_QuotientAndRemainder : NSObject

/// 商
@property (nonatomic, strong) O2SBigInt *quotient;

/// 余数
@property (nonatomic, strong) O2SBigInt *reminder;

- (instancetype)initWithQuotient:(O2SBigInt *)quotient
                        reminder:(O2SBigInt *)reminder;

@end
