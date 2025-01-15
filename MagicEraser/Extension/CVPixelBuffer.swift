//
//  CVPixelBuffer.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 10.04.2024.
//

import Foundation
import VideoToolbox

extension CVPixelBuffer {
    var cgImage: CGImage? {
        var cgImage: CGImage?
         VTCreateCGImageFromCVPixelBuffer(
            self,
            options: nil,
            imageOut: &cgImage
         )
        return cgImage
    }
    
    static func getFromGray(_ image: CGImage) -> CVPixelBuffer? {
        let imageWidth = Int(image.width)
        let imageHeight = Int(image.height)

        let attributes : [NSObject:AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
        ]

        var pxbuffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault,
                            imageWidth,
                            imageHeight,
                            kCVPixelFormatType_OneComponent8,
                            attributes as CFDictionary?,
                            &pxbuffer)

        if let _pxbuffer = pxbuffer {
            let flags = CVPixelBufferLockFlags(rawValue: 0)
            CVPixelBufferLockBaseAddress(_pxbuffer, flags)
            let pxdata = CVPixelBufferGetBaseAddress(_pxbuffer)
            let grayColorSpace = CGColorSpaceCreateDeviceGray();
            let context = CGContext(data: pxdata,
                                    width: imageWidth,
                                    height: imageHeight,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(_pxbuffer),
                                    space: grayColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.none.rawValue)

            if let _context = context {
                _context.draw(image, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
            }
            else {
                CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
                return nil
            }

            CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
            return _pxbuffer;
        }

        return nil
    }
    
    static func getFromRgb(_ image: CGImage) -> CVPixelBuffer? {
        let imageWidth = Int(image.width)
        let imageHeight = Int(image.height)

        let attributes : [NSObject:AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
        ]

        var pxbuffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault,
                            imageWidth,
                            imageHeight,
                            kCVPixelFormatType_32ARGB,
                            attributes as CFDictionary?,
                            &pxbuffer)

        if let _pxbuffer = pxbuffer {
            let flags = CVPixelBufferLockFlags(rawValue: 0)
            CVPixelBufferLockBaseAddress(_pxbuffer, flags)
            let pxdata = CVPixelBufferGetBaseAddress(_pxbuffer)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            let context = CGContext(data: pxdata,
                                    width: imageWidth,
                                    height: imageHeight,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(_pxbuffer),
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

            if let _context = context {
                _context.draw(image, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
            }
            else {
                CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
                return nil
            }

            CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
            return _pxbuffer;
        }

        return nil
    }
}
