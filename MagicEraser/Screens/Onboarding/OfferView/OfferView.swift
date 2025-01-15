//
//  OfferView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 30.12.2024.
//

import SwiftUI

struct OfferView: View {
	@StateObject var viewModel = OnboardingVM(pageModels: [
		PageModel(
			topView: AnyView(MascotTopView()),
			titleKey: "Onboard3Title",
			textKey: "Onboard3Text",
			buttons: [
				.init(type: .buy(.year)),
				.init(type: .buy(.month)),
				.init(type: .buy(.week)),
			])
	])

	var body: some View {
		ZStack {
			OnboardPageView(model: viewModel.pageModels.first!) {}
				.environmentObject(viewModel)
				.contentShape(Rectangle())
				.gesture(DragGesture())
			if viewModel.buyInProgress {
				HStack {
					Spacer()
					VStack {
						Spacer()
						ProgressView()
						Spacer()
					}
					Spacer()
				}
				.background {
					Rectangle()
						.fill(.ultraThinMaterial.opacity(0.8))
						.ignoresSafeArea()
				}
			}
		}
		.alert(isPresented: $viewModel.isShowError,
			   error: viewModel.error) {
			Button("OK") {
				//viewModel.error = nil
			}
		}
		.background {
			CircleMeshView(color: .accentColor.opacity(0.2))
				.ignoresSafeArea()
				.blur(radius: 2)
		}
		.onAppear {
			self.viewModel.dismiss = dismiss
		}
		.lockOrientation()
	}

	@Environment(\.dismiss) private var dismiss
}
