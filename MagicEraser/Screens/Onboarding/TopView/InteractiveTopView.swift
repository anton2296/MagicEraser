//
//  InteractiveTopView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 29.11.2024.
//

import SwiftUI

struct InteractiveTopView: View {
	@State private var percentage = 0.5
	let imageLeft: Image
	let imageRight: Image
	
	var body: some View {
		GeometryReader { proxy in
			ZStack {
				Spacer()
				imageLeft
					.resizable()
					.scaledToFill()
					.scaleEffect(anchor: .bottom)
					.frame(width: proxy.size.width,
						   height: proxy.size.height,
						   alignment: .center)
					.mask {
						Rectangle()
							.scaleEffect(
								CGSize(
									width: (1-percentage),
									height: 1.0
								),
								anchor: .trailing
							)
					}
				imageRight
					.resizable()
					.scaledToFill()
					.scaleEffect(anchor: .bottom)
					.frame(width: proxy.size.width, height: proxy.size.height)
					.mask {
						Rectangle()
							.scaleEffect(
								CGSize(
									width: percentage,
									height: 1.0
								),
								anchor: .leading
							)
					}
				slider
					.padding(.leading, proxy.size.width*percentage-15)
					.padding(.trailing, proxy.size.width*(1-percentage)-15)
					.gesture(DragGesture().onChanged({ value in
						percentage = min(1, max(value.location.x/proxy.size.width, 0))
					}))
			}
			.animation(.easeInOut(duration: 1), value: percentage)
		}

	}
	
	private var slider: some View {
		ZStack(alignment: .center) {
			Rectangle()
				.foregroundColor(.accentColor)
				.frame(width: 2)
			Image(systemName: "arrow.left.arrow.right.circle")
				.padding(2)
				.frame(width: 30, height: 30)
				.background(content: {
					Circle().foregroundColor(.accentColor)
				})
				.contentShape(Rectangle())
		}
	}
}
