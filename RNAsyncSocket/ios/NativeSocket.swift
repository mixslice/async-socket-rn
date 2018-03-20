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

        self.socket?.write(msgData, withTimeout: -1, tag: 0)
    }

    @objc(initialise:stopper:)
    func initialise(port:NSNumber, stopper:NSString) -> Void {
        self.port = port
        self.msgStopper = stopper as String
    }

    @objc(listen:)
    func listen(_ cb:RCTResponseSenderBlock) -> Void {
        if (self.socket == nil) {
            self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        }
        if (self.socket?.isConnected)! {
            cb([NSNull(), "Already listening"])
            return
        }
        do {
            try self.socket?.accept(onPort: self.port as! UInt16)
            cb([NSNull(), "Start listening on port \(self.port)"])
        } catch {
            // connection failed
            cb(["Cannot listen on port \(port)"])
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

    // a new socket connection is created
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        self.socket = newSocket
        self.sendEvent(withName: "connected", body: "new")
        newSocket.readData(to: self.msgStopper.data(using: .utf8)!, withTimeout: -1, tag: 0)
    }

    // the socket disconnects
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if(err==nil){
            self.sendEvent(withName: "disconnected", body: "old")
        }else{
            self.sendEvent(withName: "disconnected", body: String(describing: err))
        }
    }

    // the socket successfully connects to the host with specific port
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        self.sendEvent(withName: "connected", body: "\(host),\(port)")
    }

    // the socket successfully writes data
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        self.sendEvent(withName: "writeData", body: "ok")
    }

    // the socket reads some data with specific length
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        self.sendEvent(withName: "readDataPartialLength", body: "\(partialLength)")
    }

    // the socket reads data
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let length = min(data.count, 20)
        let metaData: Data = data.subdata(in: 0..<length)
        // try to transform the data into String
        let metaString: String = String(data: metaData, encoding: .utf8) ?? "unknown"
        if (metaString.contains("msg://")) {
            // If a messag is put, send it to JS to handle
            self.sendEvent(withName: "read", body: String(data: data, encoding: .utf8))
        } else if (metaString.contains("file://")) {
            // If a file is put, save the file locally, then send the file dir to js to handle
            let index = metaString.index(metaString.startIndex, offsetBy: 7)
            let meta = metaString[index...].trimmingCharacters(in: .whitespaces)
            let fileData: Data = data.subdata(in: length..<data.count)
            if #available(iOS 11.0, *) {
                DispatchQueue.global(qos: .background).async {
                    self.processImageData(fileData: fileData, meta: String(meta))
                }
            }
        }
        // keep reading
        sock.readData(to: self.msgStopper.data(using: .utf8)!, withTimeout: -1, tag: 0)
    }
}

/*
 * extension for images processing
 */
extension NativeSocket {
    @available(iOS 11.0, *)
    func processImageData(fileData: Data, meta: String) {
        let originalImage: UIImage? = UIImage(data: fileData)

        var displayImage: UIImage?
        var fullImage: UIImage?
        // This rotation is for image displaying
        if (meta.contains("left")) {
            fullImage = originalImage?.mx_imageRotate(false)
        }
        else if (meta.contains("middle")) {
            fullImage = originalImage?.mx_imageRotate(true)
        }
        else if (meta.contains("right")) {
            fullImage = originalImage?.mx_imageRotate(true)
        }else{
            fullImage = originalImage
        }

        // WARNING: - 内存爆炸
        displayImage = fullImage?.mx_imageByResizeTo(CGSize(width: 345.0, height: 518.0))
        fullImage = fullImage?.mx_imageByResizeTo(CGSize(width: 3456.0, height: 5184.0))

        let tmpPath : NSString = NSTemporaryDirectory() as NSString

        let displayImagePath : String = tmpPath.appendingPathComponent("thumbnail" + meta + ".heic")
        let fullImagePath : String = tmpPath.appendingPathComponent(meta + ".heic")

        displayImage?.mx_writeHEICImageTo(displayImagePath, compressionQuality: 1.0)
        fullImage?.mx_writeHEICImageTo(fullImagePath, compressionQuality: 1.0)

        self.sendImagePath(displayImagePath: displayImagePath, fullImagePath: fullImagePath)
    }

    func sendImagePath(displayImagePath : String, fullImagePath : String) {
        var toSend : String = "file://"
        toSend += displayImagePath + ":" + fullImagePath
        self.sendEvent(withName: "read", body: toSend)
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
