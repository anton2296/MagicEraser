//
//  Orientation.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 11.04.2024.
//

import Foundation
import SwiftUI

extension UIImage.Orientation {
    func toSwiftUIImage() -> Image.Orientation {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
}
