#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <dlfcn.h>

@interface FLEXManager

+ (instancetype)sharedManager;
- (void)showExplorer;
@end

@interface CFFLEXLoader : NSObject

@end

@implementation CFFLEXLoader

+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	static CFFLEXLoader* loader;
	dispatch_once(&onceToken, ^{
		loader = [[CFFLEXLoader alloc] init];
	});

	return loader;
}

- (void)show {
	NSLog(@"CFFLEXLoader show============");
	[[objc_getClass("FLEXManager") sharedManager] showExplorer];
}
@end

%ctor {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	// 记录开关配置的文件
	NSDictionary* pref = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.cf.flexloader.plist"];
	// 存放需要的dylib或者 framework的二进制文件的地方
	// 由于系统空间不足 只能临时放在user目录下了
	NSString* dylibPath = @"User/TempLibrary/Application Support/CFFLEXLoader/FLEX";

	if(![[NSFileManager defaultManager] fileExistsAtPath:dylibPath]) {
		NSLog(@"FLEXLoader dylib file not found: %@", dylibPath);
		return;
	}

	NSString* keyPath = [NSString stringWithFormat:@"CFFLEXLoaderEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]];
	NSLog(@"CFFLEXLoader keyPath==============%@", keyPath);
	if([[pref objectForKey:keyPath] boolValue]) {
		NSLog(@"CFFLEXLoader boolValue==trun============");
		void* handle = dlopen((const char *)[dylibPath UTF8String], RTLD_NOW);
		if(handle == NULL) {
			char* error = dlerror();
			NSLog(@"dylib dlopen ERROR: %s", error);
			return;
		}

		[[NSNotificationCenter defaultCenter] addObserver:[CFFLEXLoader sharedInstance] selector:@selector(show) name:UIApplicationDidBecomeActiveNotification object:nil];
	}else {
		NSLog(@"CFFLEXLoader boolValue==false============");
	}

	[pool drain];
}


