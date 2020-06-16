//
//  O2SCalculator.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "O2SBigInt.h"

NS_ASSUME_NONNULL_BEGIN

@interface O2SCalculator : NSObject

@property (nonatomic, strong, readonly) O2SBigInt *bigInt;

- (instancetype)initWithBigInt:(nonnull O2SBigInt *)bigInt;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark 加：
@property (nonatomic, strong, readonly) O2SCalculator* (^addByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^addByInt)(NSInteger value);

#pragma mark 减：
@property (nonatomic, strong, readonly) O2SCalculator* (^subByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^subByInt)(NSInteger value);

#pragma mark 乘：
@property (nonatomic, strong, readonly) O2SCalculator* (^multiplyByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^multiplyByInt)(NSInteger value);

#pragma mark 除：
@property (nonatomic, strong, readonly) O2SCalculator* (^divideByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^divideByInt)(NSInteger value);

#pragma mark 求余：
@property (nonatomic, strong, readonly) O2SCalculator* (^reminderByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^reminderByInt)(NSInteger value);

#pragma mark 幂运算：
@property (nonatomic, strong, readonly) O2SCalculator* (^pow)(NSUInteger value);

#pragma mark 幂运算求余：
@property (nonatomic, strong, readonly) O2SCalculator* (^powByMod)(O2SBigInt *exponent, O2SBigInt *value);

#pragma mark 异或：
@property (nonatomic, strong, readonly) O2SCalculator* (^bitwiseXorByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^bitwiseXorByInt)(NSInteger value);

#pragma mark 或：
@property (nonatomic, strong, readonly) O2SCalculator* (^bitwiseOrByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^bitwiseOrByInt)(NSInteger value);

#pragma mark 与：
@property (nonatomic, strong, readonly) O2SCalculator* (^bitwiseAndByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^bitwiseAndByInt)(NSInteger value);

#pragma mark 左移：
@property (nonatomic, strong, readonly) O2SCalculator* (^shiftLeft)(int value);

#pragma mark 右移：
@property (nonatomic, strong, readonly) O2SCalculator* (^shiftRight)(int value);

#pragma mark 最大公约数
@property (nonatomic, strong, readonly) O2SCalculator* (^gcdByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^gcdByInt)(NSInteger value);

#pragma mark 余逆：
@property (nonatomic, strong, readonly) O2SCalculator* (^modInverseByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^modInverseByInt)(NSInteger value);

#pragma mark 余：
@property (nonatomic, strong, readonly) O2SCalculator* (^modByBigInt)(O2SBigInt *value);
@property (nonatomic, strong, readonly) O2SCalculator* (^modByInt)(NSInteger value);

#pragma mark 平方：
@property (nonatomic, strong, readonly) O2SCalculator* (^square)(void);

#pragma mark 平方根：
@property (nonatomic, strong, readonly) O2SCalculator* (^sqrt)(void);

#pragma mark 求反：
@property (nonatomic, strong, readonly) O2SCalculator* (^negate)(void);

#pragma mark 绝对值：
@property (nonatomic, strong, readonly) O2SCalculator* (^abs)(void);

@end

NS_ASSUME_NONNULL_END
