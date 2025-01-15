//
//  GifImage.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 22.11.2024.
//

import SwiftUI
import UIKit
import ImageIO

extension UIImage {
	static func gif(data: Data) -> UIImage? {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
		
		let frameCount = CGImageSourceGetCount(source)
		var frames: [UIImage] = []
		var gifDuration = 0.0
		
		for i in 0..<frameCount {
			guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
			
			if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil),
			   let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
			   let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) {
				gifDuration += frameDuration.doubleValue + 0.25
			}
			
			let frameImage = UIImage(cgImage: cgImage)
			frames.append(frameImage)
		}
		let loopFrames = Array(frames.dropLast() + frames.reversed().dropLast())
		let animatedImage = UIImage.animatedImage(with: loopFrames, duration: gifDuration)
		return animatedImage
	}
}

struct GifImage: UIViewRepresentable {
	enum URLType {
		case local(String)
		case remote(URL?)
		
		var url: URL? {
			switch self {
			case .local(let name):
				return Bundle.main.url(forResource: name, withExtension: "gif")
			case .remote(let url):
				return url
			}
		}
	}
	
	let type: URLType
	var loaded: ((UIImageView, UIImage?) -> Void)?
	
	func makeUIView(context: Context) -> UIView {
		let view = UIImageView()
		view.image = .megapolis
		DispatchQueue.global(qos: .background).async {
			if let url = type.url, let data = try? Data(contentsOf: url) {
				DispatchQueue.main.async {
					if let image = UIImage.gif(data: data) {
						view.image = image
						view.contentMode = .scaleAspectFit
						self.loaded?(view, image)
					}
				}
			} else {
				DispatchQueue.main.async {
					self.loaded?(view, nil)
				}
			}
		}
		return view
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}
