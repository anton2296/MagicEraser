//
//  MagicEraserApp.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 10.04.2024.
//

import SwiftUI

@main
struct MagicEraserApp: App {
	@State var appIsConfigured: Bool = false
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
			if appIsConfigured {
				RootView()
			} else {
				ProgressView()
					.background {
						CircleMeshView(color: .accentColor.opacity(0.2))
							.ignoresSafeArea()
							.blur(radius: 2)
					}
					.onAppear {
						appLoad()
					}
			}
        }
    }

	func appLoad() {
		MonetizationService.shared.configure()
		appIsConfigured = true
	}
}
