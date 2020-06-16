//
//  O2SSM2Cipher+Private.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SSM2Cipher.h"
#import "O2SECCurveFp.h"

@class O2SBigInt;
@class O2SECPointFp;

@interface O2SSM2Cipher ()

@property(nonatomic, copy) NSString *pHex;
@property(nonatomic, copy) NSString *aHex;
@property(nonatomic, copy) NSString *bHex;
@property(nonatomic, copy) NSString *gxHex;
@property(nonatomic, copy) NSString *gyHex;
@property(nonatomic, copy) NSString *nHex;

@property(nonatomic, strong) O2SECCurveFp *curve;
@property(nonatomic, strong) O2SBigInt *n;

- (O2SBigInt *)randomBigIntegerK;

- (O2SECPointFp *)kG:(O2SBigInt *)k;

//pPointHex 非压缩点
- (O2SECPointFp *)kP:(O2SBigInt *)k PPointHex:(NSString *)pPointHex;
- (O2SECPointFp *)kP:(O2SBigInt *)k PPoint:(O2SECPointFp *)pPoint;

- (NSUInteger)getPointLen;

@end
