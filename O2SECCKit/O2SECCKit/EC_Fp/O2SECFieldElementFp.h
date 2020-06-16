//
//  O2SECFieldElementFp.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class O2SBigInt;

NS_ASSUME_NONNULL_BEGIN

/// 椭圆曲线域元素
@interface O2SECFieldElementFp : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithQ:(O2SBigInt *)q
                        x:(O2SBigInt *)x;

/// 判断相等
/// @param other .
- (BOOL)equals:(O2SECFieldElementFp *)other;

/// 返回具体数值
- (O2SBigInt *)toBigInteger;

/// 取反
- (O2SECFieldElementFp *)negate;

/// 相加
/// @param b 16进制字符串如: 0A477E
- (O2SECFieldElementFp *)add:(O2SECFieldElementFp *)b;

/// 相减
/// @param b .
- (O2SECFieldElementFp *)subtract:(O2SECFieldElementFp *)b;

/// 相乘
/// @param b .
- (O2SECFieldElementFp *)multiply:(O2SECFieldElementFp *)b;

/// 相除
/// @param b .
- (O2SECFieldElementFp *)divide:(O2SECFieldElementFp *)b;

/// 平方
- (O2SECFieldElementFp *)square;

#pragma mark - 点压缩 (y^2) mod n = a mod n,求y
///平方根
- (O2SECFieldElementFp *)modsqrt;

@end

NS_ASSUME_NONNULL_END
