//
//  WheelSlider.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 30.05.2024.
//

import SwiftUI

struct WheelSlider: View {
	@Binding var selectedValue: Float
	@State private var selectedIndex: Int
	private var didEndChange: () -> ()
	private var indexes: [Int]
	private let divisionsCount: Int
	private let startValue: Float
	private let step: Float

	init(selectedValue: Binding<Float>,
		 divisionsCount: Int,
		 startValue: Float = 0,
		 step: Float,
		 didEndChange: @escaping () -> () = {}) {
		self.step = step
		self.startValue = startValue
		self.divisionsCount = divisionsCount
		self._selectedValue = selectedValue
		self.didEndChange = didEndChange
		indexes = Array(0...divisionsCount)
		selectedIndex = Int((selectedValue.wrappedValue - startValue)/step)
	}

	var body: some View {
		WheelPicker($selectedIndex, items: indexes) { value in
			VStack(spacing: 1) {
				Rectangle()
					.size(CGSize(width: 1, height: 10))
					.foregroundColor(value % 50 == 0 ? Color.primary : Color.clear)

				Rectangle()
					.size(CGSize(width: 1, height: 5))
					.foregroundColor(value % 5 == 0 ? Color.primary : Color.clear)
			}
			.frame(height: 25)
		}
		.centerView(AnyView(
			Rectangle()
				.size(CGSize(width: 1, height: 25))
				.foregroundColor(.accentColor)
				.opacity(0.8)
		), width: .Fixed(2))
		.width(.VisibleCount(indexes.count))
		.onValueChangeEnded { _ in
			Task {
				try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
				didEndChange()
			}
		}
		.scrollScale(0.15)
		.scrollAlpha(0.3)
		.frame(height: 30)
		.onChange(of: selectedIndex) { oldValue, newValue in
			if abs(Int(oldValue/5) - Int(newValue/5)) > 0 {
				generator.impactOccurred()
			}
			selectedValue = startValue + Float(selectedIndex)*step
		}
	}

	private let generator = UIImpactFeedbackGenerator(style: .soft)
}
