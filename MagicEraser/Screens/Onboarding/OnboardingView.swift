//
//  OnboardingView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 16.09.2024.
//

import SwiftUI

struct OnboardingView: View {
	@State var selectedTab: Int = 0
	@StateObject var viewModel: OnboardingVM

    var body: some View {
		ZStack {
			TabView(selection: $selectedTab) {
				ForEach(Array(viewModel.pageModels.enumerated()), id: \.offset) { offset, model in
					OnboardPageView(model: model) {
						if self.viewModel.pageModels.count - 1 > self.selectedTab {
							self.selectedTab += 1
						}
					}
					.environmentObject(viewModel)
					.id(offset)
					.contentShape(Rectangle())
					.gesture(DragGesture())
				}
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			.animation(.default, value: selectedTab)
			HStack {
				VStack {
					Button {
						if self.selectedTab >= self.viewModel.pageModels.count - 1 {
							dismiss()
						}
					} label: {
						Image(systemName: "xmark")
					}
					.foregroundColor(
                        .accentColor.opacity(0.5)
					)
					.padding()
					.opacity(self.selectedTab >= self.viewModel.pageModels.count - 1 ? 1 : 0)
					Spacer()
				}
				Spacer()
			}
			.animation(.easeIn(duration: 4), value: isShowCross)
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
		.onAppear {
			viewModel.dismiss = dismiss
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
		.lockOrientation()
	}

	private var isShowCross: Bool { self.selectedTab >= self.viewModel.pageModels.count - 1 }
	@Environment(\.dismiss) private var dismiss
}
