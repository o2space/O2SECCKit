//
//  O2SECPointFp.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class O2SECCurveFp;
@class O2SECFieldElementFp;
@class O2SBigInt;

NS_ASSUME_NONNULL_BEGIN

/// 椭圆曲线上点
@interface O2SECPointFp : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCurve:(O2SECCurveFp *)curve
                            x:(nullable O2SECFieldElementFp *)x
                            y:(nullable O2SECFieldElementFp *)y
                            z:(nullable O2SBigInt *)z;


// 椭圆曲线上的X坐标值(逻辑)
- (O2SECFieldElementFp *)getX;

// 椭圆曲线上的Y坐标值(逻辑)
- (O2SECFieldElementFp *)getY;

// Point在椭圆上的对称点
- (O2SECPointFp *)negate;

// 相同点(twice) 不同点：两点连成线与椭圆相交另一点的对称点
- (O2SECPointFp *)add:(O2SECPointFp *)b;

// Point切线与椭圆相交另一点的对称点
- (O2SECPointFp *)twice;

// k*Point
- (O2SECPointFp *)multiply:(O2SBigInt *)k;

@end

NS_ASSUME_NONNULL_END
