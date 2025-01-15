//
//  FullScreen.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 10.01.2025.
//

import SwiftUI

struct PresentScreenButton<Label, Content>: View where Label: View, Content: View {
	let label: Label
	let content: () -> Content
	
	var body: some View {
		Button {
			isShow = true
		} label: {
			label
		}
		.sheet(isPresented: $isShow, content: content)
	}
	
	@State private var isShow = false
}
