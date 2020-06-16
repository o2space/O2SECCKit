//
//  O2SCalculator.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SCalculator.h"

@interface O2SCalculator()

@property (nonatomic, strong) O2SBigInt *bigInt;

@end

@implementation O2SCalculator

- (instancetype)initWithBigInt:(O2SBigInt *)bigInt
{
    if (self = [super init])
    {
        self.bigInt = bigInt;
    }
    return self;
}

#define O2SCALCULATOR_IMPLEMENTATION(MethodName, Type)  - (O2SCalculator *(^)(Type value))MethodName\
{\
    return ^O2SCalculator *(Type value){\
        self.bigInt = [self.bigInt MethodName:value];\
        return self;\
    };\
}\

#pragma mark 加：
O2SCALCULATOR_IMPLEMENTATION(addByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(addByInt, NSInteger)
// 原始
//- (O2SCalculator *(^)(O2SBigInt *value))addByBigInt
//{
//    return ^O2SCalculator *(O2SBigInt *value){
//        self.bigInt = [self.bigInt addByBigInt:value];
//        return self;
//    };
//}

//- (O2SCalculator *(^)(NSInteger value))addByInt
//{
//    return ^O2SCalculator *(NSInteger value){
//        self.bigInt = [self.bigInt addByInt:value];
//        return self;
//    };
//}

#pragma mark 减：
O2SCALCULATOR_IMPLEMENTATION(subByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(subByInt, NSInteger)

#pragma mark 乘：
O2SCALCULATOR_IMPLEMENTATION(multiplyByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(multiplyByInt, NSInteger)

#pragma mark 除：
O2SCALCULATOR_IMPLEMENTATION(divideByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(divideByInt, NSInteger)


#pragma mark 求余：
O2SCALCULATOR_IMPLEMENTATION(reminderByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(reminderByInt, NSInteger)

//#pragma mark 幂运算：
O2SCALCULATOR_IMPLEMENTATION(pow, NSUInteger)

#pragma mark 幂运算求余：
- (O2SCalculator *(^)(O2SBigInt *exponent, O2SBigInt *value))powByMod
{
    return ^O2SCalculator *(O2SBigInt *exponent, O2SBigInt *value){
        self.bigInt = [self.bigInt pow:exponent mod:value];
        return self;
    };
}

#pragma mark 异或：
O2SCALCULATOR_IMPLEMENTATION(bitwiseXorByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(bitwiseXorByInt, NSInteger)

#pragma mark 或：
O2SCALCULATOR_IMPLEMENTATION(bitwiseOrByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(bitwiseOrByInt, NSInteger)

#pragma mark 与：
O2SCALCULATOR_IMPLEMENTATION(bitwiseAndByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(bitwiseAndByInt, NSInteger)

#pragma mark 左移：
O2SCALCULATOR_IMPLEMENTATION(shiftLeft, int)

#pragma mark 右移：
O2SCALCULATOR_IMPLEMENTATION(shiftRight, int)

#pragma mark 最大公约数
O2SCALCULATOR_IMPLEMENTATION(gcdByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(gcdByInt, NSInteger)

#pragma mark 余逆：
O2SCALCULATOR_IMPLEMENTATION(modInverseByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(modInverseByInt, NSInteger)

#pragma mark 余：
O2SCALCULATOR_IMPLEMENTATION(modByBigInt, O2SBigInt *)
O2SCALCULATOR_IMPLEMENTATION(modByInt, NSInteger)

#define O2SCALCULATOR_IMPLEMENTATION_NONEARGUMENT(MethodName)  - (O2SCalculator *(^)(void))MethodName\
{\
    return ^O2SCalculator *(void){\
        self.bigInt = [self.bigInt MethodName];\
        return self;\
    };\
}\

#pragma mark 平方：
O2SCALCULATOR_IMPLEMENTATION_NONEARGUMENT(square)
// 原始
//- (O2SCalculator *(^)(void))square
//{
//    return ^O2SCalculator *(void){
//        self.bigInt = [self.bigInt square];
//        return self;
//    };
//}

#pragma mark 平方根：
O2SCALCULATOR_IMPLEMENTATION_NONEARGUMENT(sqrt)

#pragma mark 求反：
O2SCALCULATOR_IMPLEMENTATION_NONEARGUMENT(negate)

#pragma mark 绝对值：
O2SCALCULATOR_IMPLEMENTATION_NONEARGUMENT(abs)

#undef O2SCALCULATOR_IMPLEMENTATION

@end
