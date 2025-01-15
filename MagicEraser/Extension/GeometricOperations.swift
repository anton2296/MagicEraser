//
//  GeometricOperations.swift
//  MagicEraser
//
//  Created by Anton Khokhlov on 14.04.2024.
//

import Foundation

extension CGPoint {
    var ratio: CGFloat {
        self.x/self.y
    }
    
    var dimensionless: Self {
        if ratio > 1 {
            CGPoint(x: 1/ratio, y: 1)
        } else {
            CGPoint(x: 1, y: ratio)
        }
    }
    
	var turned: Self {
		.init(x: y, y: x)
	}
	
    static func +(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x+rhs, y: lhs.y+rhs)
    }
    
    static func -(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x-rhs, y: lhs.y-rhs)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
    }
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x*rhs, y: lhs.y*rhs)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x/rhs, y: lhs.y/rhs)
    }
    
    func asSize() -> CGSize {
        CGSize(width: self.x, height: self.y)
    }
}

extension CGSize {
    var ratio: CGFloat {
        self.width/self.height
    }
    
    var dimensionless: Self {
        if ratio > 1 {
            CGSize(width: 1/ratio, height: 1)
        } else {
            CGSize(width: 1, height: ratio)
        }
    }
    
    func asPoint() -> CGPoint {
        CGPoint(x: self.width, y: self.height)
    }
    
    static func +(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width+rhs, height: lhs.height+rhs)
    }
    
    static func -(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width-rhs, height: lhs.height-rhs)
    }
    
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width+rhs.width, height: lhs.height+rhs.height)
    }
    
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width-rhs.width, height: lhs.height-rhs.height)
    }
    
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
    }
    
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
}
