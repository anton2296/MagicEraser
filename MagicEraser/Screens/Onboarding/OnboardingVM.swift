//
//  OnboardingVM.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 09.01.2025.
//

import SwiftUI
import StoreKit

@MainActor
final class OnboardingVM: ObservableObject {
	@Published var buyInProgress: Bool = false
	@Published var isShowError: Bool = false {
		didSet {
			if isShowError == false {
				error = nil
			}
		}
	}
	let pageModels: [PageModel]
	var dismiss: DismissAction?
	var error: MEError? {
		didSet {
			if error != nil { isShowError = true }
		}
	}

	init(pageModels: [PageModel]) {
		self.pageModels = pageModels
	}

	func getProduct(id: ProductID) -> Product? {
		monetizationService.products?.first { $0.id == id.rawValue }
	}

	func buy(productId: ProductID) {
		buyInProgress = true
		Task {
			let result = try? await monetizationService.buyProduct(id: productId)
			Task { @MainActor in
				switch result {
				case .success:
					dismiss?()
				case .failure(error: let error):
					self.error = error
				case .none:
					self.error = MEError.unknown
				}
				buyInProgress = false
			}
		}
	}

	@Published private var monetizationService = MonetizationService.shared
}
