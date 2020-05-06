//
//  WebCacheFile.h
//  WebCacheFile
//
//  Created by LeiYinchun on 2020/4/26.
//  Copyright © 2020年 LeiYinchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>


#define WkPostBodyKey @"headerBody"

@interface WebCacheFile : NSURLProtocol

/**
 *注入拦截
 */
+ (void)initRegister:(NSArray * _Nullable)scheme;


+ (void)unregister;

/**
 *设置拦截的资源类型，建议默认 @[@"js", @"css"]
 */
+ (void)setInterceptResourceTypes:(NSArray * _Nullable)resourceTypes;

/**
 *设置拦截的资源类型，建议默认 @[@"post"]
 */
+ (void)setInterceptMethods:(NSArray * _Nullable)methods;

@end
