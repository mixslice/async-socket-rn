//
//  NativeModule.swift
//  CSkinGo
//
//  Created by Benson zhang on 1/29/18.
//  Copyright © 2018 Mixslice. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import UIImageExtension


// Sandbox Paths
let homePath: String = NSHomeDirectory()
let libraryPath: String = homePath + "/Library/"
let documentsPath: String = homePath + "/Documents/"
let tmpPath: String = homePath + "/tmp/"

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
        let length = min(data.count, 20)
        let metaData: Data = data.subdata(in: 0..<length)
        let metaString: String = String(data: metaData, encoding: .utf8) ?? "unknown"
        if (metaString.contains("msg://")) {
            // If a messag is put, send it to JS to handle
            self.sendEvent(withName: "read", body: data.base64EncodedString(options: .lineLength64Characters))
        } else if (metaString.contains("file://")) {
            // If a file is put, save the file locally, then send the file dir to js to handle
            let index = metaString.index(metaString.startIndex, offsetBy: 7)
            let meta = metaString[index...].trimmingCharacters(in: .whitespaces)
            let fileData: Data = data.subdata(in: length..<data.count)
            processImageData(fileData: fileData, meta: String(meta))
        }
        sock.readData(to: self.msgStopper.data(using: .utf8)!, withTimeout: -1, tag: 0)
    }

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
        }

        // WARNING: - 内存爆炸
        displayImage = fullImage?.mx_imageByResizeTo(CGSize(width: 345.0, height: 518.0))
        fullImage = fullImage?.mx_imageByResizeTo(CGSize(width: 3456.0, height: 5184.0))

        let displayImagePath : String = tmpPath + "thumbnail" + meta
        let fullImagePath : String = tmpPath + meta

        displayImage?.mx_writeHEICImageTo(displayImagePath + ".heic", compressionQuality: 1.0)
        fullImage?.mx_writeHEICImageTo(fullImagePath + ".heic", compressionQuality: 1.0)

        self.sendImagePath(displayImagePath: displayImagePath, fullImagePath: fullImagePath)
    }

    func sendImagePath(displayImagePath : String, fullImagePath : String) {
        var toSend : String = "file://"
        let fileType: String = ".heic"
        toSend += displayImagePath + fileType + ":" + fullImagePath + fileType
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
