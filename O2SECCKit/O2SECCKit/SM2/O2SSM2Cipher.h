//
//  O2SSM2Cipher.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, O2SECCMode) {
    //目前仅支持素数域椭圆曲线
    O2SECCModeFp   = 0, //Fp(素数域)椭圆曲线 y^2 = x^3 + ax + b
    //O2SECCModeF2m  = 1, //F2m(二元扩域)椭圆曲线 y^2 + xy = x^3 + ax^2 + b
};


@interface O2SSM2Cipher : NSObject

- (instancetype)init NS_UNAVAILABLE;

// 自定义素数域椭圆曲线
- (instancetype)initWithFpParamPHex:(NSString *)pHex
                               aHex:(NSString *)aHex
                               bHex:(NSString *)bHex
                              gxHex:(NSString *)gxHex
                              gyHex:(NSString *)gyHex
                               nHex:(NSString *)nHex;

+ (O2SSM2Cipher *)EC_Fp_SM2_256V1;

+ (O2SSM2Cipher *)EC_Fp_X9_62_256V1;

+ (O2SSM2Cipher *)EC_Fp_SECG_256K1;

+ (O2SSM2Cipher *)EC_Fp_192;

+ (O2SSM2Cipher *)EC_Fp_256;

/// 随机生成公私钥,公钥前缀04，代表未压缩
/// return @{@"publicKey": publicKeyValue, @"privateKey": privateKeyValue}
- (NSDictionary *)generateKeyPairHex;

@end

NS_ASSUME_NONNULL_END
