//
//  EraserVM.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 10.04.2024.
//

import SwiftUI
import Combine
import TransformGesture

final class ImageEditorVM: ObservableObject {
	@Published var isProgressed: Bool = false
    @Published var outputImage: CGImage?
    @Published var maskImage: CGImage?
	@Published var brushWidth: CGFloat = 20
	@Published var brushIsClean: Bool = false
    var imageSize: CGSize = .zero
    var imageOrientation: Image.Orientation

    init(imageData: Data) {
        originalImageData = imageData
		imageOrientation = UIImage(data: imageData)?
			.imageOrientation.toSwiftUIImage() ?? .up
		guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
			print("CGImageSourceCreateWithData fail")
			return
		}
		guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
			print("CGImageSourceCreateImageAtIndex fail")
			return
		}
		self.outputImage = resize(image: image)
		guard let imageSize = calculateSize(
			imageOrientation: imageOrientation,
			cgImage: self.outputImage) else {
			print("calculateSize fail")
			return
		}
		self.imageSize = imageSize
		brushWidth = imageSize.width / 30
    }

    func fillInTheSelection() {
		isProgressed = true
		Task {
			func progressedEnd() {
				Task { @MainActor in
					maskImage = nil
					isProgressed = false
				}
			}
			
			guard var mask = maskImage else {
				print("EaserVM, empty mask")
				progressedEnd()
				return
			}
			guard var image = outputImage else {
				print("EaserVM, empty image")
				progressedEnd()
				return
			}
			var sercher = MaskSingularPointSercher()
			var point: CGPoint = .zero
			
			guard let maskContext = makeMaskContext() else {
				print("EaserVM, mask context error")
				progressedEnd()
				return
			}
			let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
			let bitmapInfo = image.bitmapInfo
			let bytesPerRow = image.bytesPerRow
			let bitsPerComponent = image.bitsPerComponent
			guard let imageContext = CGContext(
				data: nil,
				width: Int(image.width),
				height: Int(image.height),
				bitsPerComponent: bitsPerComponent,
				bytesPerRow: bytesPerRow,
				space: colorSpace,
				bitmapInfo: bitmapInfo.rawValue,
				releaseCallback: nil,
				releaseInfo: nil) else {
				print("EaserVM, Context error")
				progressedEnd()
				return
			}
			imageContext.draw(
				image,
				in: CGRect(
					origin: .zero,
					size: CGSize(
						width: image.width,
						height: image.height
					)
				)
			)
			while sercher.goNextPoint(in: mask, isOutputCorrectionPoint: { serchedPoint in
				point = serchedPoint
				return .zero
			}) {
				let imageSize = CGSize(
					width: image.width,
					height: image.height
				)
				let mirrorYPoint = CGPoint(
					x: point.x,
					y: CGFloat(image.height) - point.y
				)
				let mirrorYCropRect = CGRect(
					origin: point - lama.windowSize.asPoint()/2,
					size: lama.windowSize
				)
				let cropRect = CGRect(
					origin: mirrorYPoint - lama.windowSize.asPoint()/2,
					size: lama.windowSize
				)
				
				guard let segmentImage = image.cropping(
					to: correctCrop(
						cropRect: mirrorYCropRect,
						maxSize: imageSize
					)
				) else {
					print("EaserVM, empty segmentImage")
					progressedEnd()
					return
				}
				guard let segmentMask = mask.cropping(
					to: correctCrop(
						cropRect: mirrorYCropRect,
						maxSize: imageSize
					)
				) else {
					print("EaserVM, empty segmentMask")
					progressedEnd()
					return
				}
				guard let inputImage = lama.deleteObject(mask: segmentMask, from: segmentImage)
				else {
					print("lama error")
					progressedEnd()
					return
				}
				let correctedCropRect = correctCrop(
					cropRect: cropRect,
					maxSize: imageSize
				)
				imageContext.draw(inputImage, in: correctedCropRect)
				maskContext.setBlendMode(.clear)
				maskContext.fill([correctedCropRect])
				maskContext.drawPath(using: .eoFillStroke)
				if let resultMask = maskContext.makeImage() {
					mask = resultMask
				} else {
					print("maskContext makeImage error")
				}
				if let resultImage = imageContext.makeImage() {
					image = resultImage
				} else {
					print("imageContext resultImage error")
				}
				let newImage = image
				let newMask = mask
				Task { @MainActor in
					outputImage = newImage
					maskImage = newMask
				}
			}
			progressedEnd()
		}
    }
    
    func clear() {
        maskImage = nil
    }

    func draw(dot: CGPoint) {
		print(dot)
        if maskContext == nil {
			makeMaskContext()
        }
        guard let context = maskContext else { return }
		context.setBlendMode(brushIsClean ? .clear : .copy)
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(brushWidth)
        context.beginPath()
        if let previousDot = previousDot {
            context.move(to: previousDot)
            context.addLine(to: dot)
            context.drawPath(using: .stroke)
        }
        context.strokePath()
        context.addEllipse(in: CGRect(x: dot.x - brushWidth/2,
                                      y: dot.y - brushWidth/2,
                                      width: brushWidth,
                                      height: brushWidth))
        context.drawPath(using: .fill)
        previousDot = dot
        maskImage = maskContext?.makeImage()
    }
    
    func endDraw() {
        previousDot = nil
        maskContext?.strokePath()
		dropMaskContext()
    }
    
	@discardableResult
	private func makeMaskContext() -> CGContext? {
		guard let outputImage = outputImage else { return nil }
		let size = CGSize(width: outputImage.width, height: outputImage.height)
		maskContext = CGContext(
			data: nil,
			width: Int(size.width),
			height: Int(size.height),
			bitsPerComponent: 8,
			bytesPerRow: Int(size.width),
			space: CGColorSpaceCreateDeviceGray(),
			bitmapInfo: 0,
			releaseCallback: nil,
			releaseInfo: nil)
		if let maskImage = maskImage {
			maskContext?.draw(
				maskImage,
				in: CGRect(origin: .zero, size: size)
			)
		}
		return maskContext
	}
	
	private func dropMaskContext() {
		maskContext = nil
	}

	private func correctCrop(cropRect: CGRect, maxSize: CGSize) -> CGRect {
		var correctedCropRect: CGRect = cropRect
		if cropRect.origin.x < 0 {
			correctedCropRect.origin.x = 0
		}
		if cropRect.origin.y < 0 {
			correctedCropRect.origin.y = 0
		}
		if cropRect.origin.x + cropRect.width > maxSize.width {
			correctedCropRect.origin.x -=
			cropRect.origin.x
			+ cropRect.width
			- maxSize.width
		}
		if cropRect.origin.y + cropRect.height > maxSize.height {
			correctedCropRect.origin.y -=
			cropRect.origin.y
			+ cropRect.height
			- maxSize.height
		}
		print(correctedCropRect)
		return correctedCropRect
	}
	
	private func calculateSize(imageOrientation: Image.Orientation, cgImage: CGImage?) -> CGSize? {
		guard let cgImage = cgImage else {
			return nil
		}
		var isRotate: Bool
		switch imageOrientation {
		case .down, .downMirrored, .up, .upMirrored:
			isRotate = false
		default:
			isRotate = true
		}
		return CGSize(
			width: isRotate ? cgImage.height : cgImage.width,
			height: isRotate ? cgImage.width : cgImage.height
		)
	}
	
	private func resize(maxSide: Int = 2048,
						minSide: Int = 800,
						image: CGImage) -> CGImage {
		if image.height < minSide || image.width < minSide {
			if image.height < image.width {
				return image.resize(
					size: CGSize(
						width: image.width*minSide/image.height,
						height: minSide
					)
				) ?? image
			} else {
				return image.resize(
					size: CGSize(
						width: minSide,
						height: image.height*minSide/image.width
					)
				) ?? image
			}
		} else if image.height > maxSide || image.width > maxSide {
			if image.height < image.width {
				if image.width*maxSide/image.height < minSide {
					return image
				} else {
					return image.resize(
						size: CGSize(
							width: image.width*maxSide/image.height,
							height: maxSide
						)
					) ?? image
				}
			} else {
				if image.height*maxSide/image.width < minSide {
					return image
				}
				return image.resize(
					size: CGSize(
						width: maxSide,
						height: image.height*maxSide/image.width
					)
				) ?? image
			}
		} else {
			return image
		}
	}
	
    private var maskContext: CGContext?
    private var previousDot: CGPoint?
	private let lama: LamaService = .init()
    private var cancellableSet: Set<AnyCancellable> = []
    private let originalImageData: Data
}
