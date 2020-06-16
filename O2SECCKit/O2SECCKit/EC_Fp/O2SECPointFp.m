//
//  O2SECPointFp.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SECPointFp.h"
#import "O2SECCurveFp.h"
#import "O2SECFieldElementFp.h"
#import "O2SBigInt.h"

@interface O2SECPointFp ()

@property (nonatomic, weak) O2SECCurveFp *curve;
@property (nonatomic, strong) O2SECFieldElementFp *x;
@property (nonatomic, strong) O2SECFieldElementFp *y;
@property (nonatomic, strong) O2SBigInt *z;
@property (nonatomic, strong) O2SBigInt *zinv;

@end

@implementation O2SECPointFp

- (instancetype)initWithCurve:(O2SECCurveFp *)curve
                            x:(O2SECFieldElementFp *)x
                            y:(O2SECFieldElementFp *)y
                            z:(O2SBigInt *)z
{
    if (self = [super init])
    {
        self.curve = curve;
        self.x = x;
        self.y = y;
        // 标准射影坐标系：zinv == null 或 z * zinv == 1
        self.z = z == nil ? O2SBigInt.one : z;
        
        self.zinv = nil;
    }
    return self;
}

- (O2SECFieldElementFp *)getX
{
    @autoreleasepool {
        if (self.zinv == nil)
        {
            self.zinv = [self.z modInverseByBigInt:self.curve.q];
        }
        O2SBigInt *tmp = [[[self.x toBigInteger] multiplyByBigInt:self.zinv] modByBigInt:self.curve.q];
        return [self.curve fromBigInteger:tmp];
    }
}

- (O2SECFieldElementFp *)getY
{
    @autoreleasepool {
        if (self.zinv == nil)
        {
            self.zinv = [self.z modInverseByBigInt:self.curve.q];
        }
        O2SBigInt *tmp = [[[self.y toBigInteger] multiplyByBigInt:self.zinv] modByBigInt:self.curve.q];
        return [self.curve fromBigInteger:tmp];
    }
}

/// 判断相等
/// @param other .
- (BOOL)equals:(O2SECPointFp *) other
{
    @autoreleasepool {
        if (self == other)
        {
            return true;
        }
        
        if ([self isInfinity])
        {
            return [other isInfinity];
        }
        if ([other isInfinity])
        {
            return [self isInfinity];
        }
        
        // u = y2 * z1 - y1 * z2
        O2SBigInt *u = [[[[other.y toBigInteger] multiplyByBigInt:self.z] subByBigInt:([[self.y toBigInteger] multiplyByBigInt:other.z])] modByBigInt:self.curve.q];
        if ([u compare:O2SBigInt.zero] != NSOrderedSame)
        {
            return NO;
        }
        // v = x2 * z1 - x1 * z2
        O2SBigInt *v = [[[[other.x toBigInteger] multiplyByBigInt:self.z] subByBigInt:([[self.x toBigInteger] multiplyByBigInt:other.z])] modByBigInt:self.curve.q];
        return [v compare:O2SBigInt.zero] == NSOrderedSame;
    }
}

/// 是否是无穷远点
- (BOOL)isInfinity
{
    @autoreleasepool {
        if (self.x == nil && self.y == nil)
        {
            return true;
        }
    
        return [self.z compare:O2SBigInt.zero] == NSOrderedSame && !([[self.y toBigInteger] compare:O2SBigInt.zero]);
    }
}

/// 取反，x 轴对称点
- (O2SECPointFp *)negate
{
    @autoreleasepool {
        return [[O2SECPointFp alloc] initWithCurve:self.curve x:self.x y:[self.y negate] z:self.z];
    }
}


/// 相加
/// 标准射影坐标系
/// λ1 = x1 * z2
/// λ2 = x2 * z1
/// λ3 = λ1 − λ2
/// λ4 = y1 * z2
/// λ5 = y2 * z1
/// λ6 = λ4 − λ5
/// λ7 = λ1 + λ2
/// λ8 = z1 * z2
/// λ9 = λ3^2
/// λ10 = λ3 * λ9
/// λ11 = λ8 * λ6^2 − λ7 * λ9
/// x3 = λ3 * λ11
/// y3 = λ6 * (λ9 * λ1 − λ11) − λ4 * λ10
/// z3 = λ10 * λ8
/// @param b .
- (O2SECPointFp *)add:(O2SECPointFp *)b
{
    @autoreleasepool {
        if ([self isInfinity])
        {
            return b;
        }
        
        if ([b isInfinity]) {
            return self;
        }
        
        O2SBigInt *x1 = [self.x toBigInteger];
        O2SBigInt *y1 = [self.y toBigInteger];
        O2SBigInt *z1 = self.z;
        O2SBigInt *x2 = [b.x toBigInteger];
        O2SBigInt *y2 = [b.y toBigInteger];
        O2SBigInt *z2 = b.z;
        O2SBigInt *q = self.curve.q;
        
        O2SBigInt *w1 = [[x1 multiplyByBigInt:z2] modByBigInt:q];
        O2SBigInt *w2 = [[x2 multiplyByBigInt:z1] modByBigInt:q];
        O2SBigInt *w3 = [w1 subByBigInt:w2];
        O2SBigInt *w4 = [[y1 multiplyByBigInt:z2] modByBigInt:q];
        O2SBigInt *w5 = [[y2 multiplyByBigInt:z1] modByBigInt:q];
        O2SBigInt *w6 = [w4 subByBigInt:w5];
        
        if ([O2SBigInt.zero compare:w3] == NSOrderedSame)
        {
            if ([O2SBigInt.zero compare:w6] == NSOrderedSame)
            {
                return [self twice];
            }
            return self.curve.infinity;
        }
        
        O2SBigInt *w7 = [w1 addByBigInt:w2];
        O2SBigInt *w8 = [[z1 multiplyByBigInt:z2] modByBigInt:q];
        O2SBigInt *w9 = [[w3 square] modByBigInt:q];
        O2SBigInt *w10 = [[w3 multiplyByBigInt:w9] modByBigInt:q];
        O2SBigInt *w11 = [[[w8 multiplyByBigInt:[w6 square]] subByBigInt:[w7 multiplyByBigInt:w9]] modByBigInt:q];
        
        O2SBigInt *x3 = [[w3 multiplyByBigInt:w11] modByBigInt:q];
        O2SBigInt *y3 = [[[w6 multiplyByBigInt:[[w9 multiplyByBigInt:w1] subByBigInt:w11]] subByBigInt:[w4 multiplyByBigInt:w10]] modByBigInt:q];
        O2SBigInt *z3 = [[w10 multiplyByBigInt:w8] modByBigInt:q];
    
        return [[O2SECPointFp alloc] initWithCurve:self.curve x:[self.curve fromBigInteger:x3] y:[self.curve fromBigInteger:y3] z:z3];
    }
    
}



/// 自加
/// 标准射影坐标系：
///  λ1 = 3 * x1^2 + a * z1^2
///  λ2 = 2 * y1 * z1
///  λ3 = y1^2
///  λ4 = λ3 * x1 * z1
///  λ5 = λ2^2
///  λ6 = λ1^2 − 8 * λ4
///  x3 = λ2 * λ6
///  y3 = λ1 * (4 * λ4 − λ6) − 2 * λ5 * λ3
///  z3 = λ2 * λ5
///
- (O2SECPointFp *)twice
{
    @autoreleasepool {
        if ([self isInfinity])
        {
            return self;
        }
        if (![[self.y toBigInteger] signum]) {
            return self.curve.infinity;
        }
        
        O2SBigInt *x1 = [self.x toBigInteger];
        O2SBigInt *y1 = [self.y toBigInteger];
        O2SBigInt *z1 = self.z;
        O2SBigInt *q = self.curve.q;
        O2SBigInt *a = [self.curve.a toBigInteger];
        
        O2SBigInt *w1 = [[[[x1 square] multiplyByBigInt:O2SECCurveFp.Three] addByBigInt:[a multiplyByBigInt:[z1 square]]] modByBigInt:q];
        O2SBigInt *w2 = [[[y1 shiftLeft:1] multiplyByBigInt:z1] modByBigInt:q];
        O2SBigInt *w3 = [[y1 square] modByBigInt:q];
        O2SBigInt *w4 = [[[w3 multiplyByBigInt:x1] multiplyByBigInt:z1] modByBigInt:q];
        O2SBigInt *w5 = [[w2 square] modByBigInt:q];
        O2SBigInt *w6 = [[[w1 square] subByBigInt:[w4 shiftLeft:3]] modByBigInt:q];
        
        O2SBigInt *x3 = [[w2 multiplyByBigInt:w6] modByBigInt:q];
        O2SBigInt *y3 = [[[w1 multiplyByBigInt:[[w4 shiftLeft:2] subByBigInt:w6]] subByBigInt:[[w5 shiftLeft:1] multiplyByBigInt:w3]] modByBigInt:q];
        O2SBigInt *z3 = [[w2 multiplyByBigInt:w5] modByBigInt:q];
        
        return [[O2SECPointFp alloc] initWithCurve:self.curve x:[self.curve fromBigInteger:x3] y:[self.curve fromBigInteger:y3] z:z3];
    }
}


/// 倍点计算 kG
/// @param k .
- (O2SECPointFp *)multiply:(O2SBigInt *)k
{
    @autoreleasepool {
        if ([self isInfinity])
        {
            return self;
        }
        if (![k signum]) {
            return self.curve.infinity;
        }
        
        O2SBigInt *k3 = [k multiplyByBigInt:O2SECCurveFp.Three];
        O2SECPointFp *neg = [self negate];
        O2SECPointFp *Q = self;
        for (uint64_t i = [k3 bitLength] - 2; i > 0; i--)
        {
            Q = [Q twice];
            
            BOOL k3Bit = [k3 testBit:i];
            BOOL kBit = [k testBit:i];
            
            if (k3Bit != kBit)
            {
                Q = [Q add:(k3Bit? self : neg)];
            }
        }

        return Q;
    }
}

@end
