//
// NSString+MD5.m
// Originally created for MyFile
//
// Created by Árpád Goretity, 2011. Some infos were grabbed from StackOverflow.
// Released into the public domain. You can do whatever you want with this within the limits of applicable law (so nothing nasty!).
// I'm not responsible for any damage related to the use of this software. There's NO WARRANTY AT ALL.
//

#import "NSString+MD5.h"

@implementation NSString (MD5)

+ (NSString *) stringWithMD5OfFile: (NSString *) path {

	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath: path];
	if (handle == nil) {
		return nil;
	}
	
	CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	
	BOOL done = NO;
	
	while (!done) {
	
		NSData *fileData = [[NSData alloc] initWithData: [handle readDataOfLength: 4096]];
		CC_MD5_Update (&md5, [fileData bytes], (CC_LONG) [fileData length]);
		
		if ([fileData length] == 0) {
			done = YES;
		}
	}
	
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0],  digest[1], 
				   digest[2],  digest[3],
				   digest[4],  digest[5],
				   digest[6],  digest[7],
				   digest[8],  digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
				   
	return s;
	
}

- (NSString *) MD5Hash {
	
	CC_MD5_CTX md5;
	CC_MD5_Init (&md5);
	CC_MD5_Update (&md5, [self UTF8String], (CC_LONG) [self length]);
		
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final (digest, &md5);
	NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0],  digest[1], 
				   digest[2],  digest[3],
				   digest[4],  digest[5],
				   digest[6],  digest[7],
				   digest[8],  digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
				   
	return s;
	
}


- (NSDictionary *)parseUrlParams {
  NSMutableDictionary *parm = [[NSMutableDictionary alloc] init];
  NSURL *url = [NSURL URLWithString:self];
  if(!url) {
    return parm;
  }
  //传入url创建url组件类
  NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
  //回调遍历所有参数，添加入字典
  [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [parm setObject:obj.value forKey:obj.name];
  }];
  return parm;
}


- (NSString *)URLUTF8EncodingString
{
  if (self.length == 0) {
    return self;
  }
  NSString *encodeStr = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
  return encodeStr;
}

- (NSString *)URLUTF8DecodingString
{
  if (self.length == 0) {
    return self;
  }
  NSString *decodedPre = self;
  NSString *decodedNext = [decodedPre stringByRemovingPercentEncoding];
  while (decodedNext != nil && ![decodedNext isEqualToString:decodedPre]) {
    decodedPre = decodedNext;
    decodedNext = [decodedPre stringByRemovingPercentEncoding];
  }
  return decodedNext;
}

@end

