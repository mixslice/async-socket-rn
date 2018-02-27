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
class NativeSocket: NSObject {
  var port: NSNumber
  var logString: String
  var config: NSDictionary?
  var socket: GCDAsyncSocket?
  var receiveCB : RCTResponseSenderBlock?

  override init(){
    self.logString = ""
    self.port = 1234
  }

  /**
   * All EXTERN method
   */

  @objc(send:)
  func send(_ data:NSString) -> Void{
    let msg = data as String
    let msgData: Data = msg.data(using: .utf8)!

    self.socket?.write(msgData, withTimeout: -1, tag: 0)
  }

  @objc(receive:)
  func receive(_ cb:@escaping RCTResponseSenderBlock) -> Void {
    self.receiveCB = cb
  }

  @objc(initialise:config:)
    func initialise(port:NSNumber, config:NSDictionary) -> Void {
    self.port = port
    self.config = config
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
      cb([NSNull(), "New connection failed"])
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
    newSocket.readData(to: "===file===".data(using: .utf8)!, withTimeout: -1, tag: 0)
  }

  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    self.logString = "断开连接: \(String(describing: err))"
  }

  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    self.logString = "连接到 host: \(host) port: \(port)"
  }

  func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
    self.logString = "写入数据"
  }

  func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
    self.logString = "partialLength: \(partialLength)"
  }

  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    let meta = data.subdata(in: 0..<16)
    let fileData = data.subdata(in: 16..<data.count)
    self.logString = "meta: \(String.init(data: meta, encoding: .utf8)!)"
    sock.readData(to: "===file===".data(using: .utf8)!, withTimeout: -1, tag: 0)
  }
}
