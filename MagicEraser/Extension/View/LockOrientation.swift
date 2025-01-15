import SwiftUI

extension View {
	func lockOrientation() -> some View {
		self
			.onAppear {
				// Forcing the rotation to portrait
				Task { @MainActor in
					AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
					UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
				}
			}.onDisappear {
				// Unlocking the rotation when leaving the view
				Task { @MainActor in
					AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
				}
			}
	}
}
