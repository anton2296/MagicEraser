//import SwiftUICore
import SwiftUI

struct AuroraBackgroundView: View {
	var body: some View {
		LinearNonTransparency()
	}
}

#Preview {
	AuroraBackgroundView()
}

struct LinearNonTransparency: View {
	@State var startPoint: UnitPoint = .topLeading
	@State var endPoint: UnitPoint = .bottomTrailing
	var gradient: Gradient {
		Gradient(colors: [
			.init(uiColor: .init(
				red: 0.5,
				green: 0.5,
				blue: 0.5,
				alpha: 0.5)
			),
			.init(uiColor: .init(
				red: 0.0,
				green: 0.1,
				blue: 0.9,
				alpha: 0.8)
			),
		])
	}

	var body: some View {
		LinearGradient(gradient: gradient,
					   startPoint: startPoint,
					   endPoint: endPoint)
			.ignoresSafeArea()
			.animation(
				.linear(duration: 3)
				.repeatForever(autoreverses: true),
				value: startPoint
			)
			.animation(
				.linear(duration: 3)
				.repeatForever(autoreverses: true),
				value: endPoint
			)
			.onAppear {
				startPoint = .bottomLeading
				endPoint = .topTrailing
			}
	}
}

extension UnitPoint: Identifiable {
	public var id: Int {
		var hasher = Hasher()
		hasher.combine(self.x)
		hasher.combine(self.y)
		return hasher.finalize()
	}
}
