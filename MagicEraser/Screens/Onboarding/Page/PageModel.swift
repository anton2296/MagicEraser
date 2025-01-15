//
//  PageModel.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 16.09.2024.
//

import Foundation
import SwiftUI

struct PageButtonModel: Identifiable {
	var id: String {
		switch type {
		case .next:
			return ""
		case .buy(let productID):
			return productID.id
		}
	}
	
	enum PageButtonType {
		case next
		case buy(ProductID)
	}
	let type: PageButtonType

//	var buttonLabel: String {
//		switch self.type {
//		case .next:
//			return String(localized: .init(stringLiteral: "Next"))
//		case .buy(let titleKey, _):
//			return String(localized: .init(stringLiteral: titleKey))
//		}
//	}

	init(type: PageButtonType) {
		self.type = type
	}
}

struct PageModel {
	let topView: AnyView
	let title: String
	let text: String
	let buttons: [PageButtonModel]

	init(topView: AnyView,
		 titleKey: String,
		 textKey: String,
		 buttons: [PageButtonModel] = [.init(type: .next)]) {
		self.topView = topView
		self.title = String(localized: .init(stringLiteral: titleKey))
		self.text = String(localized: .init(stringLiteral: textKey))
		self.buttons = buttons
	}
}

extension PageModel: Identifiable {
	var id: Int {
		var hasher = Hasher()
		hasher.combine(title)
		hasher.combine(text)
		return hasher.finalize()
	}
}
