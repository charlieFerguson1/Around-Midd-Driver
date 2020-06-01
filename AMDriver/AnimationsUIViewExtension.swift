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
    
    func addSubviewWithZoomInAnimation(_ view: UIView, duration: TimeInterval,
                                       options: UIView.AnimationOptions) {
      view.transform = view.transform.scaledBy(x: 0.01, y: 0.01)
      addSubview(view)
      UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
        view.transform = CGAffineTransform.identity
      }, completion: nil)
    }
    
    func removeWithZoomOutAnimation(duration: TimeInterval,
                                    options: UIView.AnimationOptions) {
      UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
      }, completion: { _ in
        self.removeFromSuperview()
      })
    }

}

