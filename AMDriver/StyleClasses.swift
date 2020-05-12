//
//  StyleClasses.swift
//  AroundMidd
//
//  Created by Charlie Ferguson on 12/30/19.
//  Copyright © 2019 cferguson. All rights reserved.
//

import Foundation
import UIKit

/*
 Button:
  - pink background
  - white text
  - small font
 */
class MyCustomButton : UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
        self.layer.cornerRadius = 5.0
        self.titleLabel?.font = UIFont(name: "Copperplate", size: 23)
        self.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.backgroundColor = customPink
        self.tintColor = UIColor.white
    }
}

/*
 Button:
    - white background
    - pink boarder
    - pink text
    - small font
 */
class MyCustomButton2 : UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
        self.layer.cornerRadius = 5.0
        self.titleLabel?.font = UIFont(name: "Copperplate", size: 17)
        self.titleLabel?.textColor = customPink
        
        self.layer.masksToBounds = true
        self.layer.borderColor = customPink.cgColor
        self.layer.borderWidth = 1.0
        
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.tintColor = UIColor.white
    }
}

/*
 Label:
    - pink background
    - white text
    - small font
 */
class MyCustomLabel : UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
        self.font = UIFont(name: "Copperplate", size: 17)
        self.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.backgroundColor = customPink
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5.0
    }
}


class CustomLargeLabel : UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
        self.font = UIFont(name: "Copperplate-Bold", size: 37)
        self.textColor = customPink
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5.0
    }
}
