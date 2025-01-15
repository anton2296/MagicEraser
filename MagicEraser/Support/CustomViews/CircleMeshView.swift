//
//  CircleMeshView.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 30.12.2024.
//

import SwiftUI

struct CircleMeshView: View {
	var color: Color

	var body: some View {
		TimelineView(.animation) { context in
			Rectangle()
				.foregroundColor(color)
				.colorEffect(
					ShaderLibrary.default.circleMesh(
						.boundingRect,
						.float(16),
						.float(0.4),
						.float(context.date.timeIntervalSinceAppStart())
					)
				)
		}
	}
}
