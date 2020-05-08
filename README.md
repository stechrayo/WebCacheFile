# WebCacheFile

Cache the web file locally for faster access next time. 

缓存web文件到本地以提高下次访问速度。

## 安装

该库最低支持 iOS 9.0 和 Xcode 11。

### CocoaPods

1. 在 Podfile 中添加 pod 'WebCacheFile'。
2. 执行 pod install 或 pod update。
3. 导入 <WebCacheFile/WebCacheFile.h>。

### 手动安装

1. 下载 WebCacheFile 文件夹内的所有内容。
2. 将 WebCacheFile 内的源文件添加(拖放)到你的工程。
3. 导入 WebCacheFile.h。

## 使用

```
@implementation WkViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 1.注册需要拦截的协议类型
  [WebCacheFile initRegister:@[@"http", @"https"]];
  
  // 2.
  [WebCacheFile setInterceptResourceTypes:@[@"js", @"css", @"png", @"jpg", @"gif"]];
  // [self addWKWebView];
}

- (void)dealloc {
  [WebCacheFile unregister];
}

@end
```