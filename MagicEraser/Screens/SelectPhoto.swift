//
//  SelectPhoto.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 11.04.2024.
//

import SwiftUI
import PhotosUI

extension View {
	func pulse(maxRadius: CGFloat = 4.0,
			   interval: CGFloat = 3.0,
			   color: Color = .white) -> some View {
		TimelineView(.animation) { context in
			let radius = abs(maxRadius - context.date.timeIntervalSinceAppStart().truncatingRemainder(dividingBy: interval)/interval * maxRadius*2) + 1

			self
				.shadow(color: color,
						radius: radius)
				.multilineTextAlignment(.center)
		}
	}
}

struct SelectPhoto: View {
    @State var photo: PhotosPickerItem?
    @State var error: Error?

    var body: some View {
        VStack {
			Spacer()
			HStack {
				Spacer()
				Text("RootScreenTitle")
					.font(.largeTitle)
					.foregroundColor(.white)
					.bold()
					.pulse()
				Spacer()
			}
			Spacer()
            Spacer()
            PhotosPicker(selection: $photo,
                         matching: .images,
                         preferredItemEncoding: .automatic) {
				Text("SelectPhoto")
					.padding()
            }
						 .background(
							 .thinMaterial,
							 in: RoundedRectangle(cornerRadius: 25, style: .continuous)
						 )
						 .contentShape(Rectangle())
        }
        .padding()
        .alert(error?.localizedDescription ?? "",
               isPresented: $error.map{ $0 != nil },
               actions: {
            Button("OK :(") {
                error = nil
            }
		})
		.background {
			ZStack {
				GifImage(type: .local("MegapolisVideo")) { _, _ in }
					.blur(radius: 4)
					.opacity(0.8)
					.scaledToFill()
				AuroraBackgroundView()
			}
			.ignoresSafeArea(.all,
							 edges: .all)
		}
        .navigationDestination(for: NavigationTransition.self) { transition in
            switch transition {
            case .editor(let imageData):
                EraserView(viewModel: .init(imageData: imageData))
			case .save(let image, let imageOrientation):
				SaveView(
					viewModel: SaveVM(
						image: image,
						imageOrientation: imageOrientation
					)
				)
			case .buy:
				OfferView()
			}
        }
        .onChange(of: photo, {
            if let photo = photo {
                loadTransferable(from: photo)
            }
        })
		.overlay(alignment: .topTrailing) {
            if MonetizationService.shared.subscribeIsActive == false {
                Button {
                    navigator.navigationPath.append(NavigationTransition.buy)
                } label: {
                    Image(systemName: "cart")
                        .foregroundColor(.white)
                        .pulse(color: .white)
                        .padding()
                }
                .contentShape(Rectangle())
            }
		}
    }
    
    @discardableResult
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.photo else { return }
                photo = nil
                switch result {
                case .success(let imageData?):
                    navigator.navigationPath.append(NavigationTransition.editor(imageData: imageData))
                case .success(nil):
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self.error = error
                }
            }
        }
    }

    private let startDate = Date()
    private let navigator: Navigator = .shared
}

#Preview {
    SelectPhoto()
}
