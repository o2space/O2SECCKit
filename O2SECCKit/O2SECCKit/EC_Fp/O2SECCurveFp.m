//
//  O2SECCurveFp.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SECCurveFp.h"
#import "O2SECPointFp.h"
#import "O2SECFieldElementFp.h"
#import "O2SBigInt.h"
#import "O2SSMxUtils.h"

@interface O2SECCurveFp()

@property (nonatomic, strong) O2SBigInt *q;
@property (nonatomic, strong) O2SECFieldElementFp *a;
@property (nonatomic, strong) O2SECFieldElementFp *b;
@property (nonatomic, strong) O2SECPointFp *infinity;
@property (nonatomic, assign) NSUInteger pointLen;

@end

@implementation O2SECCurveFp

+ (O2SBigInt *)Three
{
    static O2SBigInt *three;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        three = [[O2SBigInt alloc] initWithInt:3];
    });
    return three;
}

- (instancetype)initWithQ:(O2SBigInt *)q
                        a:(O2SBigInt *)a
                        b:(O2SBigInt *)b
                 pointLen:(NSUInteger)len
{
    if (self = [super init])
    {
        self.q = q;
        self.a = [self fromBigInteger:a];
        self.b = [self fromBigInteger:b];
        
        self.infinity =  [[O2SECPointFp alloc] initWithCurve:self
                                                            x:nil
                                                            y:nil
                                                            z:nil];
        
        self.pointLen = len;
    }
    return self;
}

/// 判断两个椭圆曲线是否相等
/// @param other .
- (BOOL)equals:(O2SECCurveFp *) other
{
    @autoreleasepool {
        if (self == other)
        {
            return YES;
        }
    
        return [self.q compare:other.q] == NSOrderedSame && [self.a equals:other.a] && [self.b equals:other.b];
    }
}

/// 生成椭圆曲线域元素
/// @param x .
- (O2SECFieldElementFp *)fromBigInteger:(O2SBigInt *)x
{
    return [[O2SECFieldElementFp alloc] initWithQ:self.q x:x];
}

#pragma mark - 椭圆曲线点的压缩与解压缩

/// 解析 16 进制串为椭圆曲线点 坐标点压缩 压缩格式：若公钥y坐标最后一位为0，则首字节为0x02，否则为0x03。非压缩格式：公钥首字节为0x04
/// @param s .
- (O2SECPointFp *)decodePointHex:(NSString *)s
{
    if (s.length < 2)
    {
        return nil;
    }
    NSRange range = (NSRange){0,2};
    unsigned long outVal = strtoul([[s substringWithRange:range] UTF8String], 0, 16);
    switch (outVal) {
        case 0:
            return self.infinity;
            break;
        case 2:
        case 3:
        {
            // 已知椭圆方程式y^2 = x^3 + ax + b，和已知的点的坐标x值，求点的坐标y值
            NSUInteger len = ([s length] - 2 );
            if (len != self.pointLen/2)
            {
//                NSAssert(NO, @"decode point error");
                return nil;
            }
            NSRange range = (NSRange){2,len};
            NSString *xHex = [s substringWithRange:range];
            O2SBigInt *x = [[O2SBigInt alloc] initWithString:xHex radix:16];

            O2SECFieldElementFp *x_fe = [self fromBigInteger:x];
            O2SECFieldElementFp *rhs =  [[x_fe square] multiply:x_fe];
            rhs = [rhs add:[self.a multiply:x_fe]];
            rhs = [rhs add:self.b];

            O2SECFieldElementFp *y_fe = [rhs modsqrt];//modsqrt(),这里是[y^2 mod q = (x^3 + ax + b) mod q]求y(模平方根)
            unsigned long yp = outVal & 1;

            if ([[[y_fe toBigInteger] bitwiseAndByInt:1] compare:[[O2SBigInt alloc] initWithInt:yp]] == NSOrderedSame)
            {
                return [[O2SECPointFp alloc] initWithCurve:self x:x_fe  y:y_fe z:nil];
            }
            else
            {
                O2SECFieldElementFp *field = [[O2SECFieldElementFp alloc] initWithQ:self.q x:self.q];
                y_fe = [field subtract:y_fe];
                return [[O2SECPointFp alloc] initWithCurve:self x:x_fe  y:y_fe z:nil];
            }
            
//            NSAssert(NO, @"decode point error");
            return nil;
        }
            break;
        case 4:
        case 6:
        case 7:
        {
            NSUInteger len = ([s length] - 2 ) / 2;
            if (len != self.pointLen/2)
            {
//                NSAssert(NO, @"decode point error");
                return nil;
            }
        
            NSRange range = (NSRange){2,len};
            NSString *xHex = [s substringWithRange:range];
            O2SBigInt *x = [[O2SBigInt alloc] initWithString:xHex radix:16];
            O2SECFieldElementFp *x_fe = [self fromBigInteger:x];
            
            range.location = len + 2;
            NSString *yHex = [s substringWithRange:range];
            O2SBigInt *y = [[O2SBigInt alloc] initWithString:yHex radix:16];
            O2SECFieldElementFp *y_fe = [self fromBigInteger:y];
            
            return [[O2SECPointFp alloc] initWithCurve:self x:x_fe  y:y_fe z:nil];
        }
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

- (NSString *)encodePoint:(O2SECPointFp *)point compressed:(BOOL)compressed
{
    if (compressed == NO)
    {
        //04
        NSString *pointX = [O2SSMxUtils leftPad:[[[point getX] toBigInteger] toString:16] num:self.pointLen/2];
        NSString *pointY = [O2SSMxUtils leftPad:[[[point getY] toBigInteger] toString:16] num:self.pointLen/2];
        NSString *pointHex = [NSString stringWithFormat:@"04%@%@", pointX, pointY];
        return pointHex;
    }
    else
    {
        //02 03
        NSString *pointX = [O2SSMxUtils leftPad:[[[point getX] toBigInteger] toString:16] num:self.pointLen/2];
        
        O2SBigInt *y = [[point getY] toBigInteger];
        O2SBigInt *py = [y bitwiseAndByInt:1];
        O2SBigInt *pc = [py bitwiseOrByInt:0x02];
        NSString *pcStr = [O2SSMxUtils leftPad:[pc toString:16] num:2];
        NSRange range = (NSRange){pcStr.length - 2, 2};
        pcStr = [pcStr substringWithRange:range];
        
        NSString *pointHex = [NSString stringWithFormat:@"%@%@", pcStr, pointX];
        return pointHex;
    }
}

- (NSString *)toString
{
    return [NSString stringWithFormat:@"\"Fp\": y^2 = x^3 + %@*x + %@ over %@",[self.a.toBigInteger toString:10],[self.b.toBigInteger toString:10],[self.q toString:10]];
}

@end
