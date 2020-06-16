//
//  O2SSM2Cipher.m
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "O2SSM2Cipher.h"
#import "O2SECPointFp.h"
#import "O2SECCurveFp.h"
#import "O2SECFieldElementFp.h"
#import "O2SBigInt.h"
#import "O2SSMxUtils.h"
#import "O2SSM2Cipher+Private.h"

@interface O2SSM2Cipher ()

@property(nonatomic, strong) O2SECPointFp *g;

@property(nonatomic, assign) O2SECCMode eccMode;

@end

@implementation O2SSM2Cipher

- (instancetype)initWithFpParamPHex:(NSString *)pHex
                               aHex:(NSString *)aHex
                               bHex:(NSString *)bHex
                              gxHex:(NSString *)gxHex
                              gyHex:(NSString *)gyHex
                               nHex:(NSString *)nHex
{
    if (self = [super init])
    {
        self.pHex = pHex;
        self.aHex = aHex;
        self.bHex = bHex;
        self.gxHex = gxHex;
        self.gyHex = gyHex;
        self.nHex = nHex;
        
        O2SBigInt *p = [[O2SBigInt alloc] initWithString:pHex radix:16];
        O2SBigInt *a = [[O2SBigInt alloc] initWithString:aHex radix:16];
        O2SBigInt *b = [[O2SBigInt alloc] initWithString:bHex radix:16];
        if ((gxHex.length != gyHex.length) || gyHex.length % 2 != 0)
        {
            NSAssert(NO, @"decode point error");
        }
        self.curve = [[O2SECCurveFp alloc] initWithQ:p a:a b:b pointLen:gxHex.length * 2];
        self.g = [self.curve decodePointHex:[NSString stringWithFormat:@"04%@%@", gxHex, gyHex]];
        self.n = [[O2SBigInt alloc] initWithString:nHex radix:16];
        
        self.eccMode = O2SECCModeFp;
    }
    return self;
}

#pragma mark - Fp(素数域)椭圆曲线 y^2 = x^3 + ax + b

+ (O2SSM2Cipher *)EC_Fp_SM2_256V1
{
    static O2SSM2Cipher *param;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *pHex     = @"FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF";
        NSString *aHex     = @"FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC";
        NSString *bHex     = @"28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93";
        
        NSString *gxHex    = @"32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7";
        NSString *gyHex    = @"BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0";
        NSString *nHex     = @"FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123";
        
        param = [[O2SSM2Cipher alloc] initWithFpParamPHex:pHex
                                                     aHex:aHex
                                                     bHex:bHex
                                                    gxHex:gxHex
                                                    gyHex:gyHex
                                                     nHex:nHex];
        
    });
    return param;
}

+ (O2SSM2Cipher *)EC_Fp_X9_62_256V1
{
    static O2SSM2Cipher *param;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *pHex     = @"FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF";
        NSString *aHex     = @"FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC";
        NSString *bHex     = @"5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B";
        
        NSString *gxHex    = @"6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296";
        NSString *gyHex    = @"4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5";
        NSString *nHex     = @"FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551";
        
        param = [[O2SSM2Cipher alloc] initWithFpParamPHex:pHex
                                                     aHex:aHex
                                                     bHex:bHex
                                                    gxHex:gxHex
                                                    gyHex:gyHex
                                                     nHex:nHex];
        
    });
    return param;
}

+ (O2SSM2Cipher *)EC_Fp_SECG_256K1
{
    static O2SSM2Cipher *param;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *pHex     = @"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F";
        NSString *aHex     = @"0000000000000000000000000000000000000000000000000000000000000000";
        NSString *bHex     = @"0000000000000000000000000000000000000000000000000000000000000007";
        
        NSString *gxHex    = @"79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798";
        NSString *gyHex    = @"483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8";
        NSString *nHex     = @"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141";
        
        param = [[O2SSM2Cipher alloc] initWithFpParamPHex:pHex
                                                     aHex:aHex
                                                     bHex:bHex
                                                    gxHex:gxHex
                                                    gyHex:gyHex
                                                     nHex:nHex];
        
    });
    return param;
}

+ (O2SSM2Cipher *)EC_Fp_192
{
    static O2SSM2Cipher *param;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *pHex     = @"BDB6F4FE3E8B1D9E0DA8C0D46F4C318CEFE4AFE3B6B8551F";
        NSString *aHex     = @"BB8E5E8FBC115E139FE6A814FE48AAA6F0ADA1AA5DF91985";
        NSString *bHex     = @"1854BEBDC31B21B7AEFC80AB0ECD10D5B1B3308E6DBF11C1";
        
        NSString *gxHex    = @"4AD5F7048DE709AD51236DE65E4D4B482C836DC6E4106640";
        NSString *gyHex    = @"02BB3A02D4AAADACAE24817A4CA3A1B014B5270432DB27D2";
        NSString *nHex     = @"BDB6F4FE3E8B1D9E0DA8C0D40FC962195DFAE76F56564677";
        
        param = [[O2SSM2Cipher alloc] initWithFpParamPHex:pHex
                                                     aHex:aHex
                                                     bHex:bHex
                                                    gxHex:gxHex
                                                    gyHex:gyHex
                                                     nHex:nHex];
        
    });
    return param;
}

+ (O2SSM2Cipher *)EC_Fp_256
{
    static O2SSM2Cipher *param;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *pHex     = @"8542D69E4C044F18E8B92435BF6FF7DE457283915C45517D722EDB8B08F1DFC3";
        NSString *aHex     = @"787968B4FA32C3FD2417842E73BBFEFF2F3C848B6831D7E0EC65228B3937E498";
        NSString *bHex     = @"63E4C6D3B23B0C849CF84241484BFE48F61D59A5B16BA06E6E12D1DA27C5249A";
        
        NSString *gxHex    = @"421DEBD61B62EAB6746434EBC3CC315E32220B3BADD50BDC4C4E6C147FEDD43D";
        NSString *gyHex    = @"0680512BCBB42C07D47349D2153B70C4E5D7FDFCBFA36EA1A85841B9E46E09A2";
        NSString *nHex     = @"8542D69E4C044F18E8B92435BF6FF7DD297720630485628D5AE74EE7C32E79B7";
        
        param = [[O2SSM2Cipher alloc] initWithFpParamPHex:pHex
                                                     aHex:aHex
                                                     bHex:bHex
                                                    gxHex:gxHex
                                                    gyHex:gyHex
                                                     nHex:nHex];
        
    });
    return param;
}


//#pragma mark - F2m(二元扩域)椭圆曲线 y^2 + xy = x^3 + ax^2 + b
//+ (O2SSM2Cipher *)EC_F2m_193
//{
//    //F2m-193曲线
//    //基域生成多项式：x^193+x^15+1 
//    static O2SSM2Cipher *param;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSString *pHex      = @"2000000000000000000000000000000000000000000008001";
//        NSString *aHex      = @"00";
//        NSString *bHex      = @"002FE22037B624DBEBC4C618E13FD998B1A18E1EE0D05C46FB";
//
//        NSString *gxHex     = @"00D78D47E85C93644071BC1C212CF994E4D21293AAD8060A84";
//        NSString *gyHex     = @"00615B9E98A31B7B2FDDEEECB76B5D875586293725F9D2FC0C";
//        NSString *nHex      = @"80000000000000000000000043E9885C46BF45D8C5EBF3A1";
//
//        param = [[O2SSM2Cipher alloc] initWithP2mParamPHex:pHex
//                                                      aHex:aHex
//                                                      bHex:bHex
//                                                     gxHex:gxHex
//                                                     gyHex:gyHex
//                                                      nHex:nHex];
//    });
//    return param;
//}
//
//+ (O2SSM2Cipher *)EC_F2m_257
//{
//    //F2m-257曲线
//    //基域生成多项式：x^257+x^12+1
//    static O2SSM2Cipher *param;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSString *pHex      = @"20000000000000000000000000000000000000000000000000000000000001001";
//        NSString *aHex      = @"00";
//        NSString *bHex      = @"00E78BCD09746C202378A7E72B12BCE00266B9627ECB0B5A25367AD1AD4CC6242B";
//
//        NSString *gxHex     = @"00CDB9CA7F1E6B0441F658343F4B10297C0EF9B6491082400A62E7A7485735FADD";
//        NSString *gyHex     = @"013DE74DA65951C4D76DC89220D5F7777A611B1C38BAE260B175951DC8060C2B3E";
//        NSString *nHex      = @"7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBC972CF7E6B6F900945B3C6A0CF6161D";
//
//        param = [[O2SSM2Cipher alloc] initWithP2mParamPHex:pHex
//                                                      aHex:aHex
//                                                      bHex:bHex
//                                                     gxHex:gxHex
//                                                     gyHex:gyHex
//                                                      nHex:nHex];
//    });
//    return param;
//}

#pragma mark - Public

- (NSDictionary *)generateKeyPairHex
{
    @autoreleasepool {
        O2SBigInt *rng = [[O2SBigInt alloc] initWithRandomBits:(int)[_n bitLength]];
        O2SBigInt *d = [[rng modByBigInt:[_n subByBigInt:O2SBigInt.one]] addByBigInt:O2SBigInt.one];
        
        NSString *privateKey = [O2SSMxUtils leftPad:[d toString:16] num:64];
        
        O2SECPointFp *p = [_g multiply:d];
        NSString *px = [O2SSMxUtils leftPad:[[[p getX] toBigInteger] toString:16] num:64];
        NSString *py = [O2SSMxUtils leftPad:[[[p getY] toBigInteger] toString:16] num:64];
        NSString *publicKey = [NSString stringWithFormat:@"04%@%@", px, py];
        
        return @{@"publicKey": publicKey, @"privateKey": privateKey};
    }
}

#pragma mark - Private

- (NSUInteger)getPointLen
{
    return self.curve.pointLen;
}

- (O2SBigInt *)randomBigIntegerK
{
    @autoreleasepool {
        O2SBigInt *rng = [[O2SBigInt alloc] initWithRandomBits:(int)[_n bitLength]];
        O2SBigInt *d = [[rng modByBigInt:[_n subByBigInt:O2SBigInt.one]] addByBigInt:O2SBigInt.one];
        return d;
    }
}

- (O2SECPointFp *)kG:(O2SBigInt *)k
{
    @autoreleasepool {
        O2SECPointFp *kGPoint = [_g multiply:k];
        return kGPoint;
    }
}

- (O2SECPointFp *)kP:(O2SBigInt *)k PPointHex:(NSString *)pPointHex
{
    @autoreleasepool {
        O2SECPointFp *pPoint = [self.curve decodePointHex:[NSString stringWithFormat:@"04%@", pPointHex]];
        O2SECPointFp *kPPoint = [pPoint multiply:k];
        return kPPoint;
    }
}

- (O2SECPointFp *)kP:(O2SBigInt *)k PPoint:(O2SECPointFp *)pPoint
{
    @autoreleasepool {
        O2SECPointFp *kPPoint = [pPoint multiply:k];
        return kPPoint;
    }
}

@end
