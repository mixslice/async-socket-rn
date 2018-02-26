//
//  NativeSocket.m
//  CSkinGo
//
//  Created by Benson zhang on 1/29/18.
//  Copyright © 2018 Mixslice. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import "NativeSocket.h"

@interface RCT_EXTERN_MODULE(NativeSocket, NSObject)

RCT_EXTERN_METHOD(hello)
RCT_EXTERN_METHOD(initialise:(nonnull NSNumber)p config:(NSDictionary) config)
RCT_EXTERN_METHOD(connect)
RCT_EXTERN_METHOD(disconnect)
RCT_EXTERN_METHOD(send:(NSString)data)

@end
