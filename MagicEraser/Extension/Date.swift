import Foundation

extension Date {
	static let startAppDate = Date()
	
	func timeIntervalSinceAppStart() -> TimeInterval {
		self.timeIntervalSince(Date.startAppDate)
	}
}
