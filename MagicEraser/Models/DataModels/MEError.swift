//
//  MEError.swift
//  MagicEraser
//
//  Created by Хохлов Антон Сергеевич on 13.10.2024.
//

import Foundation

struct MEError: LocalizedError {
	let errorDescription: String?
}

extension MEError {
	static let unknown = Self(errorDescription: "Unknown error")
}
