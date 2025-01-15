//
//  LamaService.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 10.04.2024.
//

import Foundation
import CoreML

final class LamaService: ObservableObject {
    @Published var isRedy: Bool = false
	let windowSize: CGSize = .init(width: 800, height: 800)

    init() {
        Task {
            loadMLModel()
        }
    }
    
    func deleteObject(mask: CGImage, from image: CGImage) -> CGImage? {
        guard let maskPixelBuffer = CVPixelBuffer.getFromGray(mask) else {
			print("mask getFromGray error")
            return nil
        }
        guard let imagePixelBuffer = CVPixelBuffer.getFromRgb(image) else {
			print("image getFromRgb error")
            return nil
        }
        let output = try? model?.prediction(
            image: imagePixelBuffer,
            mask: maskPixelBuffer
        ).output
        return output?.cgImage
    }
    
    private func loadMLModel() {
        let modelConfiguration = MLModelConfiguration()
		modelConfiguration.computeUnits = .cpuAndNeuralEngine
		model = try? .init(configuration: modelConfiguration)
        
        isRedy = model != nil
    }

    private var model: LaMa_2?
}

