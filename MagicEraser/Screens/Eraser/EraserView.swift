//
//  EraserView.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 10.04.2024.
//

import SwiftUI
import TransformGesture
import CoreImage

struct EraserView: View {
    @StateObject var viewModel: ImageEditorVM
    @StateObject var transform = TouchTransform(scaleRange: 0.8...10)
    @State var cursorDot: CGPoint?
	@State var isShowBrushSize: Bool = false
	@State var accentColor: Color = .blue
	
    var body: some View {
		ZStack {
            ZStack(alignment: .center) {
                VStack {
					Spacer()
                    HStack {
                        Spacer()
                    }
                }
                if let image = viewModel.outputImage {
                    GeometryReader { proxy in
                        ZStack {
                            Image(decorative: image,
                                  scale: 1,
								  orientation: viewModel.imageOrientation)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            if let image = viewModel.maskImage,
							   let maskImage = maskToAlpha(inputImage: image) {
								Image(decorative: maskImage,
                                      scale: 1,
									  orientation: viewModel.imageOrientation)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .colorMultiply(.accentColor)
                                .opacity(0.5)
                            }
                        }
                        .scaleEffect(
                            transform.scale
                        )
                        .offset(transform.translation)
                        .transformGesture(transform: transform,
                                          draggingDisabled: false,
                                          active: true,
                                          onTap: { value in
                            if !dragIsProgress && !viewModel.isProgressed {
                                detectTouchDot(value, canvasSize: proxy.size)
                                Task { @MainActor in
                                    viewModel.endDraw()
                                    cursorDot = nil
                                }
                            }
						})
						.gesture(
                            DragGesture(minimumDistance: 0.2)
								.updating(
									$dragIsProgress,
									body: { value, dragIsProgress, transaction in
										if viewModel.isProgressed {
											return
										}
										if !dragIsProgress {
											detectTouchDot(value.startLocation, canvasSize: proxy.size)
											dragIsProgress = true
										}
										detectTouchDot(
											value.location,
											canvasSize: proxy.size
										)
										Task { @MainActor in
											self.cursorDot = value.location
										}
									})
								.onEnded({ _ in
									Task {
										viewModel.endDraw()
										cursorDot = nil
									}
								})
						)
						VStack {
							Spacer()
							HStack(alignment: .bottom) {
								Spacer()
								let width = calcBrushScreenSize(canvasSize: proxy.size)
								Circle()
									.frame(
										width: width,
										height: width
									)
									.foregroundColor(accentColor)
									.opacity(isShowBrushSize ? 0.8 : 0)
									.animation(.default, value: isShowBrushSize)
									.animation(.default, value: viewModel.brushWidth)
									.padding(.bottom, 10)
								Spacer()
							}
						}
                    }
					.animation(.default, value: viewModel.outputImage)
                } else {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .padding(.bottom, 100)
			VStack(alignment: .center) {
                Spacer()
                HStack {
					VStack {
						Picker("", selection: $viewModel.brushIsClean) {
							Image(systemName: "eraser")
								.rotationEffect(.degrees(-90))
								.tag(true)
							Image(systemName: "paintbrush")
								.rotationEffect(.degrees(-90))
								.tag(false)
						}
						.frame(width: 65, alignment: .center)
						.pickerStyle(.segmented)
						.rotationEffect(.degrees(90))
					}
					.frame(width: 40, alignment: .center)
					.padding(.vertical, 5)
					VStack(spacing: 0) {
						Button {
							viewModel.fillInTheSelection()
						} label: {
							ZStack {
								Text("Remove")
									.opacity(viewModel.isProgressed || viewModel.maskImage == nil ? 0 : 1)
								if viewModel.isProgressed {
									ProgressView()
								}
							}
							.animation(.default, value: viewModel.maskImage == nil)
							.animation(.default, value: viewModel.isProgressed)
							.padding(.horizontal, 7)
							.frame(height: 25)
							.background(
								Capsule()
									.foregroundColor(
										Color(UIColor.systemBackground)
											.opacity(0.15)
									)
							)
						}
						.disabled(viewModel.isProgressed)
						.padding(5)
						.clipShape(Rectangle())
						.padding(.trailing, 40)
						HStack {
							Slider(
								value: $viewModel.brushWidth,
								in: 1...viewModel.imageSize.width/10,
								step: 1,
								onEditingChanged: { isEdit in
									isShowBrushSize = isEdit
								}
							)
							Text("\(Int(viewModel.brushWidth))")
								.frame(width: 40)
								.padding(2)
								.background(
									Capsule()
										.foregroundColor(
											Color(UIColor.systemBackground)
												.opacity(0.15)
										)
								)
						}
					}
					.frame(width: 200, alignment: .center)
					.padding(.top, 5)
					.padding(.bottom, 5)
					.padding(.trailing, 10)
				}
				.background {
					Rectangle()
						.foregroundColor(
							Color(UIColor.secondarySystemBackground)
								.opacity(0.3)
						)
						.background(
							.ultraThinMaterial,
							in: RoundedRectangle(cornerRadius: 8, style: .continuous)
						)
						.mask(
							RoundedRectangle(
								cornerRadius: 8,
								style: .continuous
							)
						)
                        .padding(.bottom, -100)
                }
            }
        }
		.background(Color(UIColor.secondarySystemBackground))
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					if let image = viewModel.outputImage {
						navigator.navigationPath.append(
							NavigationTransition.save(
								image: image,
								imageOrientation: viewModel.imageOrientation
							)
						)
					}
				} label: {
					Image(systemName: "square.and.arrow.up")
				}
				.disabled(viewModel.outputImage == nil)
			}
		}
    }
    
    private func detectTouchDot(_ dot: CGPoint, canvasSize: CGSize) {
        var absoluteDot = (
            dot - transform.translation.asPoint() - canvasSize.asPoint()/2*(1-transform.scale)
        )/transform.scale
        let actualSize = viewModel.imageSize
		
		var realDot: CGPoint
		if actualSize.ratio > canvasSize.ratio {
			let sizeDifference = 1/actualSize.ratio - 1/canvasSize.ratio
			absoluteDot.y = absoluteDot.y + canvasSize.width*sizeDifference/2
			realDot = absoluteDot/canvasSize.width*actualSize.width
		} else {
			let sizeDifference = actualSize.ratio - canvasSize.ratio
			absoluteDot.x = absoluteDot.x + canvasSize.height*sizeDifference/2
			realDot = absoluteDot/canvasSize.height*actualSize.height
		}
		switch viewModel.imageOrientation {
		case .up:
			realDot.y = actualSize.height - realDot.y
		case .down:
			realDot.x = actualSize.width - realDot.x
		case .left:
			realDot = (actualSize.asPoint() - realDot).turned
		case .right:
			realDot = CGPoint(x: realDot.y, y: realDot.x)
		case .upMirrored, .downMirrored:
			break
		case .leftMirrored, .rightMirrored:
			realDot.y = actualSize.height - realDot.y
			realDot = CGPoint(x: realDot.y, y: realDot.x)
		}
        Task {
            viewModel.draw(dot: realDot)
        }
    }
    
	private func maskToAlpha(inputImage: CGImage) -> CGImage? {
		let ciImage = CIImage(cgImage: inputImage)
		guard let filter = CIFilter(name: "CIMaskToAlpha") else {
			return nil
		}
		filter.setDefaults()
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		let context = CIContext(options: nil)
		if let outputImage = filter.outputImage,
		   let cgImage = context.createCGImage(
			outputImage,
			from: outputImage.extent) {
			return cgImage
		}
		return nil
	}
	
	private func calcBrushScreenSize(canvasSize: CGSize) -> CGFloat {
		let imageRelativeWidth: CGFloat
		if canvasSize.ratio > viewModel.imageSize.ratio {
			let delta = (
				canvasSize.ratio - viewModel.imageSize.ratio
			) * canvasSize.height
			imageRelativeWidth = canvasSize.width-delta
		} else {
			imageRelativeWidth = canvasSize.width
		}
		return CGFloat(
			viewModel.brushWidth
		) * imageRelativeWidth * transform.scale / viewModel.imageSize.width
	}
	
	private let navigator: Navigator = .shared
    @GestureState private var dragIsProgress = false
}


