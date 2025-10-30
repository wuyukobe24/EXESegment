
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
