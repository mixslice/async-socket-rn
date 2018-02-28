//
//  NativeModule.swift
//  CSkinGo
//
//  Created by Benson zhang on 1/29/18.
//  Copyright © 2018 Mixslice. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

@objc(NativeSocket)
class NativeSocket: RCTEventEmitter {
  // RCTEventEmitter is also an NSObject so we can only let our class be one
  var port: NSNumber
  var msgStopper: String
  var socket: GCDAsyncSocket?

  override init(){
    self.port = 1234
    self.msgStopper = "::]]"
  }

  /**
   * All EXTERN method
   */

  @objc(send:)
  func send(_ data:NSString) -> Void{
    let msg = data as String
    let msgData: Data = msg.data(using: .utf8)!

    print("writing:\(msg) to socket")
    self.socket?.write(msgData, withTimeout: -1, tag: 0)
  }

  @objc(initialise:stopper:)
    func initialise(port:NSNumber, stopper:NSString) -> Void {
    self.port = port
    self.msgStopper = stopper as String
  }

  @objc(connect:)
  func connect(_ cb:RCTResponseSenderBlock) -> Void {
    if (self.socket == nil) {
      self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    if (self.socket?.isConnected)! {
      cb([NSNull(), "Already connected"])
      return
    }
    do {
      try self.socket?.accept(onPort: self.port as! UInt16)
      cb([NSNull(), "New connection successfull"])
    } catch {
      // connection failed
      cb(["new connection failed"])
    }
  }

  @objc(disconnect)
  func disconnect() -> Void {
    self.socket?.disconnect()
    return
  }

}

/**
 * extension for our object to be a GCDAsyncSocketDelegate
 */
extension NativeSocket: GCDAsyncSocketDelegate {

  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    self.socket = newSocket
    newSocket.readData(to: self.msgStopper.data(using: .utf8)!, withTimeout: -1, tag: 0)
  }

  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    self.sendEvent(withName: "disconnected", body: "ok")
  }

  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    self.sendEvent(withName: "connected", body: "\(host),\(port)")
  }

  func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
    self.sendEvent(withName: "writeData", body: "ok")
  }

  func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
    self.sendEvent(withName: "readDataPartialLength", body: "\(partialLength)")
  }

  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    self.sendEvent(withName: "read", body: String(data: data, encoding: .utf8) )
    sock.readData(to: self.msgStopper.data(using: .utf8)!, withTimeout: -1, tag: 0)
  }
}

/**
 * extension for our object to be an event emitter
 */
extension NativeSocket {
    // Returns an array of your named events
    override func supportedEvents() -> [String]! {
        return ["connected","disconnected","writeData","readDataPartialLength","read"]
    }


}
