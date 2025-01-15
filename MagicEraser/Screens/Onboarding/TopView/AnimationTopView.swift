//
//  AnimationTopView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 08.01.2025.
//

import SwiftUI

struct AnimationTopView: View {
	var imageArray: [Image]
	var interval: TimeInterval = 3
	
	var body: some View {
		GeometryReader { proxy in
			TimelineView(.animation) { context in
				getImage(in: context.date
					.timeIntervalSince(startScreenDate))
				.resizable()
				.scaledToFill()
				.scaleEffect(anchor: .center)
				.frame(width: proxy.size.width,
					   height: proxy.size.height,
					   alignment: .center)
				.animation(.easeInOut(duration: 1),
						   value: context.date)
			}
		}
		.ignoresSafeArea(edges: .top)
		.onAppear {
			startScreenDate = Date()
		}
	}

	func getImage(in time: TimeInterval) -> Image {
		return imageArray[Int(
			(time/interval)
				.truncatingRemainder(
					dividingBy: Double(imageArray.count)
				)
		)]
	}
	
	@State private var startScreenDate = Date()
}
