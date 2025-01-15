//
//  MascotTopView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 08.01.2025.
//

import SwiftUI

struct MascotTopView: View {
	var body: some View {
		GeometryReader(content: { proxy in
			TimelineView(.animation) { context in
				let time = context.date.timeIntervalSinceAppStart()
				Image(.mascot)
					.resizable()
					.scaledToFit()
					.scaleEffect(anchor: .center)
					.padding()
					.frame(width: proxy.size.width,
						   height: proxy.size.height,
						   alignment: .center)
					.distortionEffect(
						ShaderLibrary.complexWave(
							.float(time),
							.float(0.2),
							.float(10),
							.float(2),
							.float2(proxy.size)
						),
						maxSampleOffset: .zero
					)
			}
		})
	}
}
