//
//  WebCacheFile.m
//  WebCacheFile
//
//  Created by LeiYinchun on 2020/4/26.
//  Copyright © 2019年 LeiYinchun. All rights reserved.
//

#import "WebCacheFile.h"
#import "NSString+MD5.h"
#import <JKSandBoxManager/JKSandBoxManager.h>
#import <AFNetworking/AFNetworking.h>

@interface WebCacheFile ()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

static NSString* const RequestedFlag = @"RequestedFlag";
static NSString* const FileCacheDir = @"webcachefiles";
static NSArray* gResourceTypes = nil;
static NSArray* gMethods = nil;

@implementation WebCacheFile

#pragma mark - 协议拦截

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  //已经处理
  if([NSURLProtocol propertyForKey:RequestedFlag inRequest:request]) {
    return NO;
  }
  
  return [self isNeedInterceptWithResourceTypes:request] || [self isNeedInterceptWithMethods:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

+ (void)unregister {
  [WebCacheFile unregisterClass:[WebCacheFile class]];
}

- (void)startLoading {
  
  //标记该请求已经处理
  NSMutableURLRequest *mutableReqeust = [super.request mutableCopy];
  [NSURLProtocol setProperty:@YES forKey:RequestedFlag inRequest:mutableReqeust];

  // 响应资源文件的拦截
  if([WebCacheFile isNeedInterceptWithResourceTypes:super.request]) {
    NSString *filePath = [self makeCacheFilePathByRequest];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
      [self responseWithFile:filePath];
    } else {
      [self downloadResourcesRequest:[mutableReqeust copy]];
    }
    return;
  }
  
  //响应指定方法的拦截
  if([WebCacheFile isNeedInterceptWithMethods:super.request]) {
    NSMutableDictionary *requestHeaders = [mutableReqeust.allHTTPHeaderFields mutableCopy];
    NSString *bodyDataStr = [[NSString alloc] initWithData:mutableReqeust.HTTPBody encoding:NSUTF8StringEncoding];
    if(!bodyDataStr) {
      bodyDataStr = [requestHeaders objectForKey:WkPostBodyKey];
      if(bodyDataStr) {
        [requestHeaders removeObjectForKey:WkPostBodyKey];
        bodyDataStr = [bodyDataStr URLUTF8DecodingString];
      } else {
        
      }
      bodyDataStr = bodyDataStr?:@"{}";
    }
    NSData *jsonData = [bodyDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [mutableReqeust setAllHTTPHeaderFields:requestHeaders];
    [mutableReqeust setHTTPBody:jsonData];
    [self postRequest:[mutableReqeust copy]];
    return;
  }
}

- (void)stopLoading {
}

#pragma mark - 协议自定义实现

//组装数据，响应被拦截的请求
- (void)reponseIntercept:(NSURLResponse * _Nonnull)response andData:(NSData *)data {
  [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  [[self client] URLProtocol:self didLoadData:data];
  [[self client] URLProtocolDidFinishLoading:self];
}

- (void)responseWithFile:(NSString *)filePath {
  NSLog(@"== %@", filePath);
  NSString *mimeType = [self getMimeTypeWithFilePath:filePath];
  NSData *data = [NSData dataWithContentsOfFile:filePath];
  NSURLResponse *response = [[NSURLResponse alloc] initWithURL:super.request.URL
                                                      MIMEType:mimeType
                                         expectedContentLength:-1
                                              textEncodingName:nil];
  
  [self reponseIntercept:response andData:data];
}

//普通请求
- (void)postRequest:(NSURLRequest *)request{
  NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request
                                                  uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    
  } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    
  } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
    NSData *data= [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
    [self reponseIntercept:response andData:data];
  }];
  [task resume];
}

//下载资源文件
- (void)downloadResourcesRequest:(NSURLRequest *)request {
  NSString *name = [NSString stringWithFormat:@"%@", super.request.URL.lastPathComponent];
  NSString *targetFilePath =[self makeCacheFilePathByRequest];
  
  NSURLSessionDownloadTask *task = [self.manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
    
  } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    NSURL *path = [NSURL fileURLWithPath:JKSandBoxPathTemp];
    return [path URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", name]];
    
  } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
    [JKSandBoxManager moveFileFrom:filePath.path to:targetFilePath];
    [self responseWithFile:targetFilePath];
  }];
  [task resume];
}

- (NSString *)getMimeTypeWithFilePath:(NSString *)filePath {
  CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
  CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
  CFRelease(pathExtension);
  
  //The UTI can be converted to a mime type:
  NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
  if (type != NULL)
    CFRelease(type);
  
  return mimeType;
}

- (NSString *)makeCacheFilePathByRequest {
  NSString *dir =[JKSandBoxManager createCacheFilePathWithFolderName:FileCacheDir];
  NSString *name = [NSString stringWithFormat:@"%@", super.request.URL.lastPathComponent];
  NSString *path =[dir stringByAppendingString:[NSString stringWithFormat:@"/%@", name]];
  return path;
}

- (AFURLSessionManager *)manager {
  if (!_manager) {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  }
  return _manager;
}

#pragma mark - 对外设置

+ (void)initRegister:(NSArray * _Nullable)scheme {
  if(!scheme || scheme.count<1) {
    return;
  }
  
  [NSURLProtocol registerClass:[WebCacheFile class]];
  
  Class cls = NSClassFromString(@"WKBrowsingContextController");
  SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
  if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    for (NSString *item in scheme) {
      [(id)cls performSelector:sel withObject:item];
    }
#pragma clang diagnostic pop
  }
}

+ (void)setInterceptResourceTypes:(NSArray * _Nullable)resourceTypes {
  if(!resourceTypes) {
    return;
  }
  gResourceTypes = resourceTypes;
}

+ (void)setInterceptMethods:(NSArray * _Nullable)methods {
  if(!methods) {
    return;
  }
  gMethods = methods;
}

+ (BOOL)isNeedInterceptWithResourceTypes:(NSURLRequest *)request {
  //是否是属于被拦截的资源类型
  NSString *extension = request.URL.pathExtension;
  return [[self resourceTypes] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    return [extension compare:obj options:NSCaseInsensitiveSearch] == NSOrderedSame;
  }] != NSNotFound;
}

+ (BOOL)isNeedInterceptWithMethods:(NSURLRequest *)request {
  //是否是属于被拦截的请求类型
  NSString *method = request.HTTPMethod;
  return [[self methods] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    return [method compare:obj options:NSCaseInsensitiveSearch] == NSOrderedSame;
  }] != NSNotFound;
}

+ (NSArray *)methods{
  if (!gMethods) {
    return @[@"post"];
  }
  return gMethods;
}

+ (NSArray *)resourceTypes
{
  if (!gResourceTypes) {
    return @[@"js", @"css"];
  }
  return gResourceTypes;
}

@end
