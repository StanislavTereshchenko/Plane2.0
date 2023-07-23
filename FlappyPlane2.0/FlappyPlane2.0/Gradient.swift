//
//  Gradient.swift
//  FlappyPlane2.0
//
//  Created by Stanislav Tereshchenko on 22.07.2023.
//

import Foundation
import UIKit


extension UIView {
    
    func addGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, transform: CATransform3D?) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.cornerRadius = 10
        
        
        if let transform = transform {
            gradientLayer.transform = transform
        }
        
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
