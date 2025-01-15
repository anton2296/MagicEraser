//
//  OnboardPageView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 16.09.2024.
//

import SwiftUI

struct OnboardPageView: View {
	var nextHandler: () -> Void
	var cellRatio: CGFloat {
		if model.buttons.count > 1 {
			0.25
		} else {
			0.55
		}
	}

	init(model: PageModel, nextHandler: @escaping () -> Void) {
		self.model = model
		self.nextHandler = nextHandler
		self.isShowLegal = model.buttons.contains(where: {
			switch $0.type {
			case .next:
				false
			case .buy:
				true
			}
		})
	}

	var body: some View {
		GeometryReader { proxy in
			let isRotate = elementOrientationAngle.degrees != 90
			LazyHGrid(rows: [GridItem(.fixed(proxy.size.height*cellRatio)),
							 GridItem(.fixed(proxy.size.height*(1-cellRatio)))],
					  spacing: 0) {
				Group {
					model.topView
						.frame(
							width: isRotate ? proxy.size.width : proxy.size.height*cellRatio,
							height: isRotate ? proxy.size.height*cellRatio : proxy.size.width
						)
						.mask(Rectangle())
					VStack(spacing: 0) {
						textView
						ForEach(model.buttons) { buttonModel in
							Button {
								switch buttonModel.type {
								case .next:
									nextHandler()
								case .buy(let id):
									viewModel.buy(productId: id)
                                }
                            } label: {
                                Group {
                                    switch buttonModel.type {
                                    case .next:
                                        Text(
                                            String(localized: .init(stringLiteral: "Next"))
                                        )
                                        .font(.system(size: isIpad ? 26 : 16, weight: .regular, design: .default))
                                    case .buy(let id):
                                        if let product = viewModel.getProduct(id: id) {
                                            let offer = product.subscription?.introductoryOffer
                                            let withTrial = offer?.paymentMode == .freeTrial
                                            let period = offer?.period.value
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(product.displayName.localizedCapitalized)
                                                    if withTrial {
                                                        Group {
                                                            Text("\(period ?? 0)") +
                                                            Text(" ") +
                                                            Text("days trial")
                                                        }
                                                        .font(.system(size: isIpad ? 16 : 10, weight: .regular, design: .default))
                                                    }
                                                }
                                                .font(.system(size: isIpad ? 20 : 14, weight: .regular, design: .default))
                                                Spacer()
                                                VStack(alignment: .center, spacing: 0) {
                                                    if withTrial {
                                                        Text("Free").bold()
                                                        Group {
                                                            Text("and then") +
                                                            Text(" ") +
                                                            Text(
                                                                String(localized: .init(stringLiteral: product.displayPrice))
                                                            )
                                                        }
                                                        .font(.system(size: isIpad ? 16 : 10, weight: .regular, design: .default))
                                                    } else {
                                                        Text(
                                                            String(localized: .init(stringLiteral: product.displayPrice))
                                                        )
                                                        .bold()
                                                    }
                                                }
                                                .font(.system(size: isIpad ? 20 : 14, weight: .regular, design: .default))
                                                .padding(.vertical)
                                                .foregroundColor(.white)
                                                .padding(.horizontal)
                                                .frame(width: 140, height:  isIpad ? 66 : 50)
                                                .background {
                                                    if withTrial {
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .foregroundColor(.accentColor)
                                                            .opacity(0.9)
                                                            .pulse(
                                                                interval: 1,
                                                                color: .accentColor
                                                            )
                                                    } else {
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .foregroundColor(.accentColor)
                                                            .opacity(0.9)
                                                    }
                                                }
                                                .padding(3)
                                            }
                                            .padding(.leading, 20)
                                        }
                                    }
                                }
								.frame(width: min(isRotate ? proxy.size.width : proxy.size.height*(1-cellRatio), isIpad ? 700 : 500) - 30,
									   height: isIpad ? 70 : 56
								)
								.background(
									.ultraThinMaterial.opacity(0.7),
									in: RoundedRectangle(cornerRadius: 25)
								)
								.background {
									RoundedRectangle(cornerRadius: 25)
										.stroke(Color.accentColor.opacity(0.5),
												lineWidth: 2)
										.shadow(color: .accentColor,
												radius: 10)
								}
								.contentShape(Rectangle())
							}
							.padding(.bottom, 10)
						}
						if isShowLegal {
							legalView
								.frame(height: 20)
						}
					}
					.padding(.bottom, isShowLegal ? 5 : 25)
					.frame(
						width: isRotate ? proxy.size.width : proxy.size.height*(1-cellRatio),
						height: isRotate ? proxy.size.height*(1-cellRatio) : proxy.size.width
					)
				}
				.rotationEffect(elementOrientationAngle)
				.animation(.default, value: elementOrientationAngle)
			}
			.rotationEffect(isIpad ? .zero : orientationAngle >= .zero ? .zero : Angle(degrees: -180))
			.animation(.default, value: orientationAngle)
			.frame(width: proxy.size.width, height: proxy.size.height)
		}
		.onRotate { newOrientation in
			if newOrientation != .portraitUpsideDown,
			   let rotate = newOrientation.rotate,
			   rotate != orientationAngle {
				orientationAngle = rotate
			}
		}
	}

	private var legalView: some View {
		HStack(spacing: 20) {
			Spacer()
			Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
				Text("EULA")
					.font(.system(size: 10))
			}
			PresentScreenButton(
				label: Text("Terms of use")
				.font(.system(size: 10))
			) {
				ScrollView {
					VStack(alignment: .center) {
						Text("Terms of use")
							.font(.system(size: 17))
							.bold()
							.foregroundColor(.primary)
							.padding()
						Text(Strings.termOfUse)
							.font(.system(size: 10))
							.padding()
							.foregroundColor(.primary)
					}
				}
			}
			Spacer()
		}
		.foregroundColor(.gray.opacity(0.5))
	}
	
	private var textView: some View {
		GeometryReader { proxy in
			VStack(alignment: .center) {
				Spacer(minLength: 0)
				Spacer(minLength: 0)
				Spacer(minLength: 0)
				Text(model.title)
					.font(.system(size: isIpad ? 32 : 17, weight: .bold, design: .default))
					.multilineTextAlignment(.leading)
					.frame(maxWidth: 700, alignment: .leading)
					.padding(.horizontal, 25)
				Spacer(minLength: 0)
				Text(model.text)
					.font(.system(size: isIpad ? 30 : 16, weight: .regular, design: .default))
					.multilineTextAlignment(.leading)
					.frame(maxWidth: 700, alignment: .leading)
					.padding(.horizontal, 25)
				HStack { Spacer() }
					.frame(height: 0)
				Spacer(minLength: 0)
			}
			.padding(.vertical, 1)
		 }
	}

	@EnvironmentObject private var viewModel: OnboardingVM
	private var elementOrientationAngle: Angle { isIpad ? .zero : orientationAngle >= .zero ? orientationAngle : -orientationAngle }
	@State private var orientationAngle = Angle(degrees: 0)
	private let model: PageModel
	private var isIpad : Bool { UIDevice.current.userInterfaceIdiom == .pad }
	private let isShowLegal: Bool
}

extension View {
	func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
		self.modifier(DeviceRotationViewModifier(action: action))
	}
}

struct DeviceRotationViewModifier: ViewModifier {
	let action: (UIDeviceOrientation) -> Void

	func body(content: Content) -> some View {
		content
			.onAppear {
				Task { @MainActor in
					let orientation = UIDevice.current.orientation
					memory.lastOrientation = orientation
					action(orientation)
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				Task { @MainActor in
					let newOrientation = UIDevice.current.orientation
					if newOrientation != memory.lastOrientation {
						action(newOrientation)
					}
				}
			}
	}

	private final class OrientationMemory {
		var lastOrientation: UIDeviceOrientation = .unknown
	}
	private let memory = OrientationMemory()
}

extension UIDeviceOrientation {
	var rotate: Angle? {
		switch self {
		case .portrait:
			Angle(degrees: 0)
		case .portraitUpsideDown:
			Angle(degrees: 180)
		case .landscapeLeft:
			Angle(degrees: 90)
		case .landscapeRight:
			Angle(degrees: -90)
		case .faceUp:
			nil
		case .faceDown:
			nil
		case .unknown:
			nil
		@unknown default:
			nil
		}
	}
}
