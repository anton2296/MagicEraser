//
//  SaveVM.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 05.09.2024.
//

import SwiftUI
import Combine

@MainActor
final class SaveVM: ObservableObject {
	@Published var outputImage: CGImage?
	@Published var buyInProgress: Bool = false
	@Published var isShowError: Bool = false {
		didSet {
			if isShowError == false {
				error = nil
			}
		}
	}
	
	var error: MEError? {
		didSet {
			if error != nil { isShowError = true }
		}
	}
	
	var isShowWatermark: Bool {
		didSet {
			if isShowWatermark {
				outputImage = drawWatermark(image)
			} else {
				outputImage = image
			}
		}
	}
	var imageOrientation: Image.Orientation

	init(image: CGImage, imageOrientation: Image.Orientation) {
		self.image = image
		self.imageOrientation = imageOrientation
		isShowWatermark = true
		if isShowWatermark {
			outputImage = drawWatermark(image)
		}
		self.isShowWatermark = monetizationService.subscribeIsActive != true
		monetizationService.$subscribeIsActive
			.sink { value in
				if value == true {
					self.isShowWatermark = false
				}
			}
			.store(in: &cancellableSet)
	}
	
	func deleteWatermark() {
		buyInProgress = true
		Task {
			let result = try? await monetizationService.buyProduct(id: .oneImage)
			Task { @MainActor in
				switch result {
				case .success:
					isShowWatermark = false
				case .failure(error: let error):
					self.error = error
				case .none:
					self.error = MEError.unknown
				}
				buyInProgress = false
			}
		}
	}
	
	private func drawWatermark(_ image: CGImage) -> CGImage? {
		guard let imageContext = CGContext(
			data: nil,
			width: Int(image.width),
			height: Int(image.height),
			bitsPerComponent: image.bitsPerComponent,
			bytesPerRow: image.bytesPerRow,
			space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: image.bitmapInfo.rawValue,
			releaseCallback: nil,
			releaseInfo: nil) else {
			print("EaserVM, Context error")
			return nil
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

		imageContext.saveGState()
		
		let string = "* Eraser wizard *"
		// Parameters
		let margin: CGFloat = 10
		let color = CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.4)
		let fontSize: CGFloat = CGFloat(min(image.width, image.height))/CGFloat(string.count)
		let shadow = {
			let shadow = NSShadow()
			shadow.shadowBlurRadius = fontSize/20
			return shadow
		}()
		
		// You can use the Font Book app to find the name
		let fontName = "Chalkboard" as CFString
		let font = CTFontCreateWithName(fontName, fontSize, nil)

		let attributes: [NSAttributedString.Key : Any] = [
			.font: font,
			.shadow: shadow,
			.foregroundColor: color
		]

		// Text
		let attributedString = NSAttributedString(string: string,
												  attributes: attributes)

		// Render
		let line = CTLineCreateWithAttributedString(attributedString)
		let stringRect = CTLineGetImageBounds(line, imageContext)

		imageContext.textPosition = CGPoint(
			x: CGFloat(image.width)/2 - stringRect.width/2 - margin,
			y: CGFloat(image.height)/2 - stringRect.height/2 - margin
		)
		CTLineDraw(line, imageContext)
		imageContext.restoreGState()

		return imageContext.makeImage()
	}

	private let image: CGImage
	private let monetizationService: MonetizationService = .shared
	private var cancellableSet: Set<AnyCancellable> = []
}
