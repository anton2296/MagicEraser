//
//  SaveView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 05.09.2024.
//

import SwiftUI

struct SaveView: View {
	@StateObject var viewModel: SaveVM
	
	var outputImage: Image? {
		if let image = viewModel.outputImage {
			Image(decorative: image,
				  scale: 1,
				  orientation: viewModel.imageOrientation)
		} else {
			nil
		}
	}
	
	var body: some View {
		VStack {
			Spacer()
			outputImage?
				.resizable()
				.scaledToFit()
			Spacer()
			HStack {
				Spacer()
				if let image = outputImage {
					ShareLink(item: image,
							  preview: SharePreview("Image", image: image.resizable())) {
						VStack {
							Image(systemName: "square.and.arrow.up")
								.frame(width: 50, height: 50)
								.background(
									.ultraThinMaterial,
									in: RoundedRectangle(cornerRadius: 25, style: .continuous)
								)
								.padding(.horizontal)
							Text("Save")
								.font(.system(size: 10))
								.foregroundColor(.primary)
						}
					}
				}
				if viewModel.isShowWatermark {
					Button {
						if !viewModel.buyInProgress {
							viewModel.deleteWatermark()
						}
					} label: {
						VStack {
							ZStack {
								if viewModel.buyInProgress {
									ProgressView()
								} else {
									Image(systemName: "water.waves.slash")
								}
							}
								.frame(width: 50, height: 50)
								.background(
									.ultraThinMaterial,
									in: RoundedRectangle(cornerRadius: 25, style: .continuous)
								)
								.padding(.horizontal)
							Text("Delete Watermark")
								.font(.system(size: 10))
								.foregroundColor(.primary)
						}
					}
				}
				Spacer()
			}
			.animation(.default, value: viewModel.isShowWatermark)
			.alert(isPresented: $viewModel.isShowError,
				   error: viewModel.error) {
				Button("OK") {
					//viewModel.error = nil
				}
			}
		}
		.background {
			CircleMeshView(color: .accentColor.opacity(0.2))
				.ignoresSafeArea()
				.blur(radius: 2)
		}
		.overlay(alignment: .topTrailing) {
            if !viewModel.isShowWatermark {
                Button {
                    navigator.navigationPath.append(NavigationTransition.buy)
                } label: {
                    Image(systemName: "cart")
                        .foregroundColor(.accentColor)
                        .pulse(color: .accentColor)
                }
                .frame(width: 50, height: 50)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 25, style: .continuous)
                )
                .contentShape(Rectangle())
                .padding()
            }
		}
	}

	private let navigator: Navigator = .shared
}
