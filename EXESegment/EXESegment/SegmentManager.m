
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
