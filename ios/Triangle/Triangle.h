#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#ifndef Triangle_h
#define Triangle_h

// Javascript api
@interface TriangleModule : RCTEventEmitter <RCTBridgeModule>

+ (id)sharedInstance;
@property(nonatomic, assign) bool hasListeners;

@end

#endif /* Triangle_h */
