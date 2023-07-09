#import <Foundation/Foundation.h>
#import <objc/objc.h>
#import <Cocoa/Cocoa.h>


@interface MyWindowObserver : NSObject

- (instancetype)init;
- (void)dealloc;

@end

@implementation MyWindowObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        // Register for the NSWindowDidBecomeKeyNotification notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowDidChange:)
                                                     name:NSWindowDidBecomeKeyNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    // Unregister from the NSWindowDidBecomeKeyNotification notification
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowDidBecomeKeyNotification
                                                  object:nil];
}

- (void)windowDidChange:(NSNotification *)notification {
    NSWindow *window = notification.object;
    NSUInteger windowID = window.windowNumber;
    NSLog(@"Window changed: %lu", windowID);
}

@end
