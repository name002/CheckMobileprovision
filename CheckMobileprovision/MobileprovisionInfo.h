//
//  MobileprovisionInfo.h
//  CheckMobileprovision
//
//  Created by elong on 2017/8/3.
//  Copyright © 2017年 QCxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileprovisionInfo : NSObject <NSXMLParserDelegate>

/**
 *  mobileprovision 路径
 */
@property (copy) NSString *filePath;

/**
 * mobileprovision 文件名
 */
@property (copy) NSString *fileName;

/**
 * mobileprovision 信息
 */
@property (copy) NSDictionary *content;

/**
 * mobileprovision 信息
 */
@property (copy) NSDictionary *entitlements;


@end
