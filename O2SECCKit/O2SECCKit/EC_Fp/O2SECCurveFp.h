//
//  O2SECCurveFp.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Fp(素数域)上的椭圆曲线 y^2 = x^3 + ax + b
//椭圆曲线E (Fp )上的点按照下面的加法运算规则，构成一个交换群:
//a) O+O=O;
//b) ∀P = (x,y) ∈ E(Fp)\{O}，P+O = O+P = P;
//c) ∀P = (x,y) ∈ E(Fp)\{O}，P的逆元素−P = (x,−y)，P+(−P) = O;
//d) 两个非互逆的不同点相加的规则:
//   设P1 = (x1,y1) ∈ E(Fp)\{O}，P2 = (x2,y2) ∈ E(Fp)\{O}，且x1 ≠ x2，
//   设P3 = (x3,y3)=P1+P2，则
//         x3 =λ^2 − x1 − x2,
//         y3 =λ(x1 − x3) − y1
//     其中
//                y2 − y1
//            λ = ———————  ;
//                x2 − x1
//e) 倍点规则:
//   设P1 = (x1,y1) ∈ E(Fp)\{O}，且y1 ≠ 0，P3 = (x3,y3) = P1 +P1，则
//         x3 =λ^2−2x1,
//         y3 =λ(x1−x3)−y1,
//     其中
//                 3x1^2 + a
//             λ = —————————  。
//                    2y1


@class O2SECFieldElementFp;
@class O2SECPointFp;
@class O2SBigInt;

NS_ASSUME_NONNULL_BEGIN

/// 椭圆曲线 y^2 = x^3 + ax + b
@interface O2SECCurveFp : NSObject

@property (nonatomic, strong, readonly) O2SBigInt *q;
@property (nonatomic, strong, readonly) O2SECPointFp *infinity;
@property (nonatomic, strong, readonly) O2SECFieldElementFp *a;

@property (nonatomic, assign, readonly) NSUInteger pointLen;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithQ:(O2SBigInt *)q
                        a:(O2SBigInt *)a
                        b:(O2SBigInt *)b
                 pointLen:(NSUInteger)len;

+ (O2SBigInt *)Three;

- (O2SECFieldElementFp *)fromBigInteger:(O2SBigInt *)x;

- (O2SECPointFp *)decodePointHex:(NSString *)s;
- (NSString *)encodePoint:(O2SECPointFp *)point compressed:(BOOL)compressed;

- (NSString *)toString;

@end

NS_ASSUME_NONNULL_END
