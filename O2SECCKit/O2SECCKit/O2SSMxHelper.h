//
//  O2SSMxHelper.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@class O2SSM2Cipher;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, O2SSM2CipherMode) {
    O2SSM2CipherModeC1C3C2 = 0,
    O2SSM2CipherModeC1C2C3 = 1,
};

@interface O2SSMxHelper : NSObject

#pragma mark - SM2

/// sm2加密
/// @param plainData 明文
/// @param publicKey 公钥 是私钥k*G的值 这里传点x和点y的拼接无需带04 ,非der， der文件可通过asn.1解码获得 https://aks.jd.com/tools/sec/
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
/// @param cipherMode c1+c2+c3或c1+c3+c2
+ (NSData *)sm2DoEncrypt:(NSData *)plainData
               publicKey:(NSString *)publicKey
                  cipher:(O2SSM2Cipher *)cipher
              cipherMode:(O2SSM2CipherMode)cipherMode;


/// sm2解密
/// @param cipherData 密文
/// @param privateKey 私钥 非der ，der文件可通过asn.1解码获得 https://aks.jd.com/tools/sec/
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
/// @param cipherMode c1+c2+c3或c1+c3+c2
+ (NSData *)sm2DoDecrypt:(NSData *)cipherData
              privateKey:(NSString *)privateKey
                  cipher:(O2SSM2Cipher *)cipher
              cipherMode:(O2SSM2CipherMode)cipherMode;


/// sm2签名
/// @param userId 用户身份标识
/// @param srcData 待签名内容
/// @param privateKey 私钥
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
+ (NSData *)sm2DoSignUserId:(NSString *)userId
                    srcData:(NSData *)srcData
                 privateKey:(NSString *)privateKey
                     cipher:(O2SSM2Cipher *)cipher;


/// sm2验签
/// @param userId 用户身份标识
/// @param srcData 待签名内容
/// @param publicKey 公钥
/// @param cipher 椭圆曲线相关系数(p,a,b,Gx,Gy,n)
/// @param sign 签名数据用于校验
+ (BOOL)sm2DoVerifyUserId:(NSString *)userId
                  srcData:(NSData *)srcData
                publicKey:(NSString *)publicKey
                   cipher:(O2SSM2Cipher *)cipher
                     sign:(NSData *)sign;

#pragma mark - SM3

/// sm3 摘要
/// @param msg String类型原始值
+ (NSData *)sm3DoHashWithString:(NSString *)msg;

/// sm3 摘要
/// @param msg Data类型原始值
+ (NSData *)sm3DoHashWithData:(NSData *)msg;

@end

NS_ASSUME_NONNULL_END
