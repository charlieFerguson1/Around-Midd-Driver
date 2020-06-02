//
//  AnimationsUIViewExtension.swift
//  
//
//  Created by Charlie Ferguson on 6/1/20.
//  Copyright © 2020 cferguson. All rights reserved.
//

import UIKit

extension UIView {
    func move(to destination: CGPoint, duration: TimeInterval, options: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.center = destination
        }, completion: nil)
    }
    
    func addSubviewWithZoomInAnimation(_ view: UIView, duration: TimeInterval, options: UIView.AnimationOptions) {
        view.transform = view.transform.scaledBy(x: 0.01, y: 0.01)
        addSubview(view)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            view.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func addSubviewWithFadeAnimation(_ view: UIView, duration: TimeInterval, options: UIView.AnimationOptions) {
        view.alpha = 0
        addSubview(view)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            view.alpha = 1
        }, completion: nil)
    }
    
    func addSubviewWithSlideBottom(_ view: UIView, duration: TimeInterval, options: UIView.AnimationOptions) {
        let rect = view.frame
        view.frame = CGRect(x: rect.minX, y: rect.maxY + rect.height, width: rect.width, height: rect.height)
        addSubview(view)
        UIView.animate(withDuration: duration, animations: {
            view.frame = rect
        }, completion: nil)
    }
    
    func addSubviewWithSlideTop(_ view: UIView, duration: TimeInterval, options: UIView.AnimationOptions) {
        let rect = view.frame
        view.frame = CGRect(x: rect.minX, y: 0 - rect.height, width: rect.width, height: rect.height)
        addSubview(view)
        UIView.animate(withDuration: duration, animations: {
            view.frame = rect
        }, completion: nil)
    }
    
    func removeWithZoomOutAnimation(duration: TimeInterval, options: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    func removeWithFadeAnimation(duration: TimeInterval, options: UIView.AnimationOptions) {
        let savedAlpha = self.alpha
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            self.alpha = savedAlpha
        })
    }
    
    func removeWithSlideOut(duration: TimeInterval, options: UIView.AnimationOptions) {
        let rect = self.frame
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.frame = CGRect(x: rect.minX, y: UIScreen.main.bounds.height, width: rect.width, height: rect.height)
        }, completion: { _ in
            self.removeFromSuperview()
            self.frame = rect
        })
    }
    
   
    
    
    
    
}

