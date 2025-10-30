
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
