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

@interface RCT_EXTERN_MODULE(NativeSocket, RCTEventEmitter <RCTBridgeModule>)

RCT_EXTERN_METHOD(initialise:(nonnull NSNumber)p stopper:(NSString) stopper)
RCT_EXTERN_METHOD(listen:(RCTResponseSenderBlock) cb)
RCT_EXTERN_METHOD(disconnect)
RCT_EXTERN_METHOD(send:(NSString) data)

@end
