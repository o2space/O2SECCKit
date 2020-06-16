//
//  ViewController.m
//  O2SECCKitDemo
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import "ViewController.h"
#import <O2SECCKit/O2SECCKit.h>

@interface ViewController ()

@property (nonatomic, copy) NSData *signData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *str = @"ALICE123@YAHOO.COM";
    NSData *plainData = [str dataUsingEncoding: NSUTF8StringEncoding];
    NSString * str16 = [O2SSMxUtils hexStringByData:plainData];
}

- (IBAction)onGenerateKeyPair:(id)sender
{
    NSDictionary *keyPair = [O2SSM2Cipher EC_Fp_SM2_256V1].generateKeyPairHex;
    NSLog(@"publicKey:%@",keyPair[@"publicKey"]);
    NSLog(@"privateKey:%@",keyPair[@"privateKey"]);
}

- (IBAction)onStartSM2Crypt:(id)sender
{
    for (int i = 0; i < 100; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @autoreleasepool {
                NSString *plainText = [NSString stringWithFormat:@"hello world 哈哈 i=%04d",i];
                NSData *plainData = [plainText dataUsingEncoding: NSUTF8StringEncoding];
                                        
                NSString *publicKey = @"34B3C792B462041066F697B1018C4A96E615EE889A33FFDF8F870BC1662A4234091F5D6D4220AFDAF0041B9CA7DD880016A90F246C26F173DD61BA371D376E26";
                O2SSM2Cipher *cipher = [O2SSM2Cipher EC_Fp_X9_62_256V1];
                NSData *cipherData = [O2SSMxHelper sm2DoEncrypt:plainData publicKey:publicKey cipher:cipher cipherMode:O2SSM2CipherModeC1C2C3];
                if (cipherData == nil)
                {
                    NSLog(@"加密失败");
                    return;
                }
                else
                {
                    NSLog(@"加密结果16进制字符串：%@",[O2SSMxUtils hexStringByData:cipherData]);
                    NSLog(@"加密结果Base64编码字符串：%@",[O2SSMxUtils stringByBase64EncodeData:cipherData]);
                }
                NSString *privateKey = @"EFA93286160DFDE76C876A6A994DD334624044270BB27C218AE9272A597BE5DA";
                NSData *m = [O2SSMxHelper sm2DoDecrypt:cipherData privateKey:privateKey cipher:cipher cipherMode:O2SSM2CipherModeC1C2C3];
                if (m)
                {
                    NSLog(@"解密成功:%@",[[NSString alloc] initWithData:m encoding:NSUTF8StringEncoding]);
        
                }
                else
                {
                    NSLog(@"解密失败%04d", i);
                }
            }
        });
    }
}

- (IBAction)onSM2Sign:(id)sender
{
    NSString *p =   @"8542D69E4C044F18E8B92435BF6FF7DE457283915C45517D722EDB8B08F1DFC3";
    NSString *a =   @"787968B4FA32C3FD2417842E73BBFEFF2F3C848B6831D7E0EC65228B3937E498";
    NSString *b =   @"63E4C6D3B23B0C849CF84241484BFE48F61D59A5B16BA06E6E12D1DA27C5249A";
    NSString *Gx =  @"421DEBD61B62EAB6746434EBC3CC315E32220B3BADD50BDC4C4E6C147FEDD43D";
    NSString *Gy =  @"0680512BCBB42C07D47349D2153B70C4E5D7FDFCBFA36EA1A85841B9E46E09A2";
    NSString *n =   @"8542D69E4C044F18E8B92435BF6FF7DD297720630485628D5AE74EE7C32E79B7";
    O2SSM2Cipher *cipher = [[O2SSM2Cipher alloc] initWithFpParamPHex:p aHex:a bHex:b gxHex:Gx gyHex:Gy nHex:n];
    NSString *privateKey = @"128B2FA8BD433C6C068C8D803DFF79792A519A55171B1B650C23661D15897263"; //私钥
    
    NSString *userId = @"o2space@163.com";
    NSString *srcStr = @"ABCDEFG1234566 Hello world, 哈哈";
    NSData *srcData = [srcStr dataUsingEncoding: NSUTF8StringEncoding];
    
    NSData *signData = [O2SSMxHelper sm2DoSignUserId:userId srcData:srcData privateKey:privateKey cipher:cipher];
    self.signData = signData;
    NSLog(@"sign:%@",[O2SSMxUtils hexStringByData:signData]);
}

- (IBAction)onSM2Verify:(id)sender
{
    if (self.signData == nil)
    {
        NSLog(@"请先进行签名");
        return;
    }
    NSString *p =   @"8542D69E4C044F18E8B92435BF6FF7DE457283915C45517D722EDB8B08F1DFC3";
    NSString *a =   @"787968B4FA32C3FD2417842E73BBFEFF2F3C848B6831D7E0EC65228B3937E498";
    NSString *b =   @"63E4C6D3B23B0C849CF84241484BFE48F61D59A5B16BA06E6E12D1DA27C5249A";
    NSString *Gx =  @"421DEBD61B62EAB6746434EBC3CC315E32220B3BADD50BDC4C4E6C147FEDD43D";
    NSString *Gy =  @"0680512BCBB42C07D47349D2153B70C4E5D7FDFCBFA36EA1A85841B9E46E09A2";
    NSString *n =   @"8542D69E4C044F18E8B92435BF6FF7DD297720630485628D5AE74EE7C32E79B7";
    O2SSM2Cipher *cipher = [[O2SSM2Cipher alloc] initWithFpParamPHex:p aHex:a bHex:b gxHex:Gx gyHex:Gy nHex:n];
    NSString *publicKey = @"0AE4C7798AA0F119471BEE11825BE46202BB79E2A5844495E97C04FF4DF2548A7C0240F88F1CD4E16352A73C17B7F16F07353E53A176D684A9FE0C6BB798E857"; //公钥
    
    NSString *userId = @"o2space@163.com";
    NSString *srcStr = @"ABCDEFG1234566 Hello world, 哈哈";
    NSData *srcData = [srcStr dataUsingEncoding: NSUTF8StringEncoding];
    
    BOOL verify = [O2SSMxHelper sm2DoVerifyUserId:userId srcData:srcData publicKey:publicKey cipher:cipher sign:self.signData];
    NSLog(@"%@",verify?@"验签成功":@"验签失败");
}

- (IBAction)onSM3Hash:(id)sender
{
    NSString *sourceStr = @"哈哈哈";
    NSData *data = [O2SSMxHelper sm3DoHashWithString:sourceStr];
    NSLog(@"SM3 HASH：%@",[O2SSMxUtils hexStringByData:data]);
}

@end
