### 原理：通过在编译时期将函数存储到App二进制的段（Segment）中的节（Section）中。在运行时的某些时期（比如App启动后、tabbarVC/VC初始化后等时机）将函数从二进制中取出并调用函数。以达到替换系统Load函数的效果。主要用于App的启动优化。

## 1、SegmentManager.h
```
#import <Foundation/Foundation.h>

typedef void (*LoadRegisterCallback)(void);

#define KLoadRegisterSegmentName "__DATA"
#define kLoadRegisterSectionName "__register_load"
#define KLoadRegister_Data __attribute((used, section(KLoadRegisterSegmentName "," kLoadRegisterSectionName )))

// 编译保存Load
#define AppLoadRegister(loadName)  \
static void LoadRegister##loadName();\
static LoadRegisterCallback varLoadRegister##loadName KLoadRegister_Data = LoadRegister##loadName;\
static void LoadRegister##loadName


NS_ASSUME_NONNULL_BEGIN

@interface SegmentManager : NSObject

+ (void)registerLoad;

@end

NS_ASSUME_NONNULL_END

```
## 2、SegmentManager.m
```

#import "SegmentManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

static void LoadRegisterRun(const char * segmentName,const char *sectionName){
    Dl_info info;
    int ret = dladdr(LoadRegisterRun, &info);
    if (ret == 0) {
        // fatal error
    }
    
#ifndef __LP64__
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, segmentName, sectionName, & size);
#else
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, segmentName, sectionName, & size);
#endif
    
    if(size == 0){
        return;
    }
    for(int idx = 0; idx < size/sizeof(void*); ++idx){
        LoadRegisterCallback func = (LoadRegisterCallback)memory[idx];
        NSLog(@"2、获取存储在二进制段segment中section名为“__register_load”中的函数，并执行函数");
        func();
    }
}

@implementation SegmentManager

+ (void)registerLoad {
    LoadRegisterRun(KLoadRegisterSegmentName,kLoadRegisterSectionName);
}

@end

```
## 3、使用
### ViewController.m
```

#import "ViewController.h"
#import "SegmentManager.h"

@interface ViewController ()

@end

@implementation ViewController

AppLoadRegister(ViewController)() {
   // 类似于load方法
    NSLog(@"3、在函数响应方法中，加载需要放在load里的代码");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 注册load方法
    NSLog(@"1、在合适的时机注册load方法");
    [SegmentManager registerLoad];
}

@end

```

### 打印结果：
```
1、在合适的时机注册load方法
2、获取存储在二进制段segment中section名为“__register_load”中的函数，并执行函数
3、在函数响应方法中，加载需要放在load里的代码
```
