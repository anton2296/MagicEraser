//
//  RootView.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 11.04.2024.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var navigator = Navigator.shared
	@ObservedObject var monetizationService = MonetizationService.shared
    
    var body: some View {
		ZStack {
			if self.monetizationService.isLoaded {
				NavigationStack(path: $navigator.navigationPath) {
					SelectPhoto()
				}
				.fullScreenCover(isPresented: $monetizationService.needShowOnboarding) {
					OnboardingView(viewModel: OnboardingVM(pageModels: monetizationService.pageModels))
				}
			} else {
				CircleMeshView(color: .accentColor.opacity(0.2))
					.ignoresSafeArea()
					.blur(radius: 2)
			}
		}
		.animation(.default, value: monetizationService.isLoaded)
    }
}

#Preview {
    RootView()
}
