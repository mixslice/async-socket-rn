//
//  UIImageExtension.swift
//  cskin-go-ios
//
//  Created by 菅思博 on 2017/8/30.
//  Copyright © 2017年 MixSlice. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {

    // MARK: - 公开方法
    /// Returns a new image which is scaled from this image.
    /// The image will be stretched as needed.
    func mx_imageByResizeTo(_ size: CGSize) -> UIImage? {
        if size.width <= 0.0 || size.height <= 0.0 {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect.init(origin: .zero, size: size))
        let tempImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tempImage
    }

    /// Returns a new image which is cropped from this image.
    func mx_imageByClipsTo(_ rect: CGRect) -> UIImage? {
        var tempRect: CGRect = rect
        tempRect.origin.x *= self.scale
        tempRect.origin.y *= self.scale
        tempRect.size.width *= self.scale
        tempRect.size.height *= self.scale
        if tempRect.size.width <= 0.0 || tempRect.size.height <= 0.0 {
            return nil
        }
        let tempCGImage: CGImage? = self.cgImage?.cropping(to: rect)
        let tempImage: UIImage? = UIImage(cgImage: tempCGImage!, scale: self.scale, orientation: self.imageOrientation)
        return tempImage
    }

    /// Create and return a pure color image with the given color and size.
    func mx_imageWith(_ color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let tempImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tempImage
    }

    /// Returns a new rotated image
    func mx_imageRotate(_ isClockwise: Bool) -> UIImage? {
        let size: CGSize = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: isClockwise ? .right : .left).draw(in: CGRect(origin: .zero, size: size))
        let tempImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tempImage
    }

    func mx_imageFix(_ image: UIImage) -> UIImage? {
        let size: CGSize = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        image.draw(in: CGRect(origin: .zero, size: size))
        let tempImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tempImage
    }

    func mx_readHEICOriginalImageFrom(_ path: String) -> UIImage {
        let url: URL = URL(fileURLWithPath: path)
        let source: CGImageSource? = CGImageSourceCreateWithURL(url as CFURL, nil)
        let cgimage: CGImage? = CGImageSourceCreateImageAtIndex(source!, 0, nil)
        return UIImage(cgImage: cgimage!)
    }

    func mx_readHEICThumbnailImageFrom(_ path: String, maxPixelSize: Int) -> UIImage {
        let url: URL = URL(fileURLWithPath: path)
        let source: CGImageSource? = CGImageSourceCreateWithURL(url as CFURL, nil)
        let options: [String: Any] = [kCGImageSourceCreateThumbnailFromImageIfAbsent as String: true,
                                      kCGImageSourceThumbnailMaxPixelSize as String: maxPixelSize] as [String: Any]
        let cgimage: CGImage? = CGImageSourceCreateThumbnailAtIndex(source!, 0, options as CFDictionary)
        return UIImage(cgImage: cgimage!)
    }

    func mx_writeHEICImageTo(_ path: String, compressionQuality: Float) {
        let url: URL = URL(fileURLWithPath: path)
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, AVFileType.heic as CFString, 1, nil) else {
            fatalError("unable to create CGImageDestination")
        }
        let options = [kCGImageDestinationLossyCompressionQuality: NSNumber(value: compressionQuality)]
        CGImageDestinationAddImage(destination, self.cgImage!, options as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
