import SwiftUI
import StoreKit
import Combine

enum OnboardingType {
	case full
	case short
	case none
}

@MainActor
final class MonetizationService: ObservableObject {
	static var shared = MonetizationService()
	var products: [Product]?
	@Published var isLoaded = false
	@Published var subscribeIsActive: Bool?
	@Published var needShowOnboarding: Bool = false
	var onboardingType: OnboardingType = .none {
		didSet {
			switch onboardingType {
			case .full, .short:
				needShowOnboarding = true
			case .none:
				needShowOnboarding = false
			}
		}
	}
	var pageModels: [PageModel] {
		switch self.onboardingType {
		case .full:
			return self.fullPageModels
		case .short:
			return self.shortPageModels
		case .none:
			return []
		}
	}

	func configure() {
		self.appStoreConfigure {
			let openCount = UserDefaults.standard.integer(forKey: self.keyOpenCount)
			if self.subscribeIsActive == true {
				self.onboardingType = .none
			} else {
				switch openCount {
				case 0:
					self.onboardingType = .full
				case _ where openCount != 0 && openCount%3 == 0:
					self.onboardingType = .short
				default:
					self.onboardingType = .none
				}
			}
			UserDefaults.standard.setValue(openCount+1, forKey: self.keyOpenCount)
			self.isLoaded = true
		}
	}
	
	func buyProduct(id: ProductID) async throws -> MEResult? {
		guard let result = try await self.products?
			.first(where: {
				$0.id == id.rawValue
			})?
            .purchase() else {
            return .failure(error: MEError(
                errorDescription: "Purchase not found in the App Store, try again later"
            ))
        }
		switch result {
		case .success(.verified(let transaction)):
			await transaction.finish()
			await self.updatePurchased()
			return .success
		case .success(.unverified(_, let error)):
			return .failure(
				error: MEError(errorDescription: error.localizedDescription)
			)
		case .userCancelled:
			return .failure(error: MEError(
				errorDescription: "You have cancelled your purchase"
			))
		case .pending:
			for await result in Transaction.updates {
				guard case .verified(let transaction) = result else {
					continue
				}
				if transaction.productID == id.rawValue {
					return .success
				}
			}
			return .failure(error: MEError(
				errorDescription: "We couldn't wait for the purchase decision"
			))
		@unknown default:
			return nil
		}
	}

	private func appStoreConfigure(endHandler: (() -> ())? = nil) {
		Task(priority: .utility) {
			self.products = try? await Product.products(for: ProductID.allIds)
			await updatePurchased(endHandler: endHandler ?? {})
			cancellableSet.insert(
				AnyCancellable(observeTransactionUpdates())
			)
		}
	}

	private func observeTransactionUpdates() -> Task<Void, Never> {
		Task(priority: .background) { [weak self] in
			for await _ in Transaction.updates {
				await self?.updatePurchased()
			}
		}
	}

	private func updatePurchased(endHandler: (() -> ())? = nil) async {
		var subscribeIsActive = false
		for await result in Transaction.currentEntitlements {
			guard case .verified(let transaction) = result else {
				continue
			}
			if transaction.revocationDate == nil,
			   ProductID(rawValue: transaction.productID)?.isSubscribe == true {
				subscribeIsActive = true
			}
		}
		Task { @MainActor in
			self.subscribeIsActive = subscribeIsActive
			endHandler?()
		}
	}

	private var cancellableSet: Set<AnyCancellable> = []
	private var keyOpenCount = "AppOpenCount"
	private lazy var fullPageModels: [PageModel] = [
		PageModel(
			topView: AnyView(
				InteractiveTopView(
					imageLeft: Image(.before),
					imageRight: Image(.after))
			),
			titleKey: "Onboard1Title",
			textKey: "Onboard1Text"),
		PageModel(
			topView: AnyView(
				AnimationTopView(imageArray: [
					Image(._2Before),
					Image(._2Masks),
					Image(._2After),
				])
			),
			titleKey: "Onboard2Title",
			textKey: "Onboard2Text"),
		PageModel(
			topView: AnyView(MascotTopView()),
			titleKey: "Onboard3Title",
			textKey: "Onboard3Text",
			buttons: [
				.init(type: .buy(.year)),
				.init(type: .buy(.month)),
				.init(type: .buy(.week)),
			]),
	]

	private lazy var shortPageModels: [PageModel] = [
		PageModel(
			topView: AnyView(MascotTopView()),
			titleKey: "Onboard3Title",
			textKey: "Onboard3Text",
			buttons: [
				.init(type: .buy(.year)),
				.init(type: .buy(.month)),
				.init(type: .buy(.week)),
			])
	]
}

enum ProductID: String {
	case oneImage = "onePhoto"
	case week = "week"
	case month = "month"
	case year = "year"

	static var allIds: [String] { [Self.oneImage.rawValue,
								   Self.week.rawValue,
								   Self.month.rawValue,
								   Self.year.rawValue] }

	var id: String { self.rawValue }
	var with3DayTrial: Bool {
		switch self {
		case .week:
			true
		default:
			false
		}
	}
	var isSubscribe: Bool {
		switch self {
		case .month, .year, .week:
			true
		case .oneImage:
			false
		}
	}
}
