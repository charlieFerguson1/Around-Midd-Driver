//
//  UIElementStyles.swift
//  AroundMidd
//
//  Created by Charlie Ferguson on 5/30/20.
//  Copyright © 2020 cferguson. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func createButtonWithShadow(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, labelTitle: String, font: String, fontSize: CGFloat, textColor: UIColor, backgroundColor: UIColor, borderColor: UIColor, shadowColor: UIColor, shadowOpacity: Float, hasShadow: Bool, view: UIView) {
        
        let element = self
        element.frame = CGRect(x: x, y: y, width: width, height: height)

        let shadowLayer = CALayer()
        shadowLayer.shadowPath = UIBezierPath(rect: CGRect(x: x, y: y, width: width, height: height)).cgPath
        shadowLayer.shadowRadius = 5
        shadowLayer.shadowOffset = CGSize(width: 3, height: 3)
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        
        //label
        element.setTitle(labelTitle, for: .normal)
        element.titleLabel?.font = UIFont(name: font, size: fontSize)
        element.titleLabel?.textColor = textColor
        element.setTitleColor(textColor, for: .normal)
        element.layer.masksToBounds = true
        element.layer.borderColor = borderColor.cgColor
        element.layer.borderWidth = 1.0
        element.layer.cornerRadius = 5.0
        element.backgroundColor = backgroundColor
        element.titleLabel?.adjustsFontSizeToFitWidth = true
        element.titleLabel?.textAlignment = .center
        
        if hasShadow {
            shadowLayer.addSublayer(element.layer)
            view.layer.addSublayer(shadowLayer)
        }
    }
}

extension UILabel {
    func createLabelWithShadow(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, labelTitle: String, font: String, fontSize: CGFloat, textColor: UIColor, backgroundColor: UIColor, borderColor: UIColor, shadowColor: UIColor, shadowOpacity: Float, shadowOffset: CGFloat, shadowRadius: CGFloat, hasShadow: Bool, view: UIView) {
        let element = self
        element.frame = CGRect(x: x, y: y, width: width, height: height)
        
        let shadowLayer = CALayer()
        shadowLayer.shadowPath = UIBezierPath(rect: CGRect(x: x, y: y, width: width, height: height)).cgPath
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        
        //label
        element.text = labelTitle
        element.numberOfLines = 1
        element.font = UIFont(name: font, size: fontSize)
        element.textColor = textColor
        element.layer.masksToBounds = true
        element.layer.borderColor = borderColor.cgColor
        element.layer.borderWidth = 1.0
        element.layer.cornerRadius = 5.0
        element.backgroundColor = backgroundColor
        element.adjustsFontSizeToFitWidth = true
        element.textAlignment = .center
        if hasShadow {
            shadowLayer.addSublayer(element.layer)
            view.layer.addSublayer(shadowLayer)
        }
        
       }
}



extension UIView {
    func createViewWithRoundCorners(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, backgroundColor: UIColor, borderColor: UIColor,  view: UIView) {
        let element = self
        element.frame = CGRect(x: x, y: y, width: width, height: height)
        element.layer.masksToBounds = true
        element.layer.borderColor = borderColor.cgColor
        element.layer.borderWidth = 1.0
        element.layer.cornerRadius = 5.0
        element.backgroundColor = backgroundColor
    }
    
    
    func addShadow(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, shadowColor: UIColor, shadowOpacity: Float, shadowOffset: CGFloat, shadowRadius: CGFloat, view: UIView) -> CALayer {
        
        let element = self
        print(element.debugDescription)
        
        let shadowLayer = CALayer()
        shadowLayer.shadowPath = UIBezierPath(rect: CGRect(x: x, y: y, width: width, height: height)).cgPath
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        
        //shadowLayer.addSublayer(element.layer)
        view.layer.addSublayer(shadowLayer)
        return shadowLayer
    }
}
