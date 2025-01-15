//
//  MaskSingularPointSercher.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 04.08.2024.
//

import Foundation
import CoreGraphics

struct MaskSingularPointSercher {
	var point: CGPoint = .zero
	
	mutating func goNextPoint(in mask: CGImage, isOutputCorrectionPoint: (CGPoint) -> CGPoint) -> Bool {
		let values = pixelValues(fromCGImage: mask)
		guard let array = values.pixelValues else {
			return false
		}
		for y in Int(point.y)..<Int(mask.height)-1 {
			for x in Int(point.x)..<Int(mask.width)-1 {
				let pos = CGPoint(x: x, y: y)
				let pixelInfo: Int = ((Int(mask.width) * Int(pos.y)) + Int(pos.x))
				let value = array[pixelInfo]
				if value > 0 {
					print(value)
					self.point = isOutputCorrectionPoint(pos)
					return true
				}
			}
		}
		return false
	}
	
	private func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int) {
		var width = 0
		var height = 0
		var pixelValues: [UInt8]?
		if let imageRef = imageRef {
			width = imageRef.width
			height = imageRef.height
			let bitsPerComponent = imageRef.bitsPerComponent
			let bytesPerRow = imageRef.bytesPerRow
			let totalBytes = height * bytesPerRow

			let colorSpace = CGColorSpaceCreateDeviceGray()
			var intensities = [UInt8](repeating: 0, count: totalBytes)

			let contextRef = CGContext(
				data: &intensities,
				width: width,
				height: height,
				bitsPerComponent: bitsPerComponent,
				bytesPerRow: bytesPerRow,
				space: colorSpace,
				bitmapInfo: 0
			)
			contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

			pixelValues = intensities
		}

		return (pixelValues, width, height)
	}

	private func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage? {
		var imageRef: CGImage?
		if var pixelValues = pixelValues {
			let bitsPerComponent = 8
			let bytesPerPixel = 1
			let bitsPerPixel = bytesPerPixel * bitsPerComponent
			let bytesPerRow = bytesPerPixel * width
			let totalBytes = height * bytesPerRow

			imageRef = withUnsafePointer(to: &pixelValues, {
				ptr -> CGImage? in
				var imageRef: CGImage?
				let colorSpaceRef = CGColorSpaceCreateDeviceGray()
				let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
				let data = UnsafeRawPointer(ptr.pointee)
					.assumingMemoryBound(to: UInt8.self)
				let releaseData: CGDataProviderReleaseDataCallback = {
					(info: UnsafeMutableRawPointer?,
					 data: UnsafeRawPointer,
					 size: Int) -> () in
				}

				if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
					imageRef = CGImage(width: width,
									   height: height,
									   bitsPerComponent: bitsPerComponent,
									   bitsPerPixel: bitsPerPixel,
									   bytesPerRow: bytesPerRow,
									   space: colorSpaceRef,
									   bitmapInfo: bitmapInfo,
									   provider: providerRef,
									   decode: nil,
									   shouldInterpolate: false,
									   intent: CGColorRenderingIntent.defaultIntent)
				}

				return imageRef
			})
		}

		return imageRef
	}
}
