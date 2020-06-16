//
//  O2SSM3Digest.h
//  O2SECCKit
//
//  Created by wkx on 2020/6/12.
//  Copyright © 2020 O2Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface O2SSM3Digest : NSObject

+ (NSData *)KDF:(NSData *)z keylen:(int)keylen;

+ (NSData *)hash:(NSString *)message;

+ (NSData *)hashData:(NSData *)data;

@end

