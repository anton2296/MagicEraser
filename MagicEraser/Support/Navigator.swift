//
//  Navigator.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 11.04.2024.
//

import SwiftUI

final class Navigator: ObservableObject {
    static var shared = Navigator()
    @Published var navigationPath = NavigationPath()

    private init() {}
}

enum NavigationTransition: Hashable {
    case editor(imageData: Data)
	case save(image: CGImage, imageOrientation: Image.Orientation)
	case buy

    var hashValue: Int {
        switch self {
        case .editor: return 1
		case .save: return 2
		case .buy: return 3
		}
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
}
