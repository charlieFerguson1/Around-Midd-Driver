//
//  AccountSetUpVC.swift
//  AMDriver
//
//  Created by Charlie Ferguson on 9/3/19.
//  Copyright © 2019 cferguson. All rights reserved.
//
import UIKit
import Firebase
import FirebaseUI
import FirebaseDatabase
import FirebaseFirestore


class AccountSetUpVC: UIViewController, FUIAuthDelegate {
    
    /* view related values */
    //colors
    let customIndigo: UIColor = UIColor(red: 38/255.0, green: 61/255.0, blue: 66/255.0, alpha: 1)
    let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
    let customPurple : UIColor = UIColor(red: 166/255.0, green: 217/255.0, blue: 247/255.0, alpha: 1)
    
    //spacing
    let screenSize: CGRect = UIScreen.main.bounds
    let rideConstraintY: CGFloat = 40
    
    //layout
    let rideY: CGFloat = 80
    let rideX: CGFloat = 0
    let driverY: CGFloat = 390
    let driverX: CGFloat = 0
    
    var titleHeight: CGFloat = 0.0 //reset in view did load
    var nameY: CGFloat = 195       //reset in view did load
    let labelSpacing: CGFloat = 55
    
    let labelHeight: CGFloat = 35
    
    /* general set up */
    var CUid: String!
    var fire: Firestore!
    
    let UD = UserDefaults.standard
    
    /* values */
    var color: String = "Not set"
    var maker: String = "Not set"
    var model: String = "Not set"
    var name: String = "Not set"
    
    /* view elements */
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = UIColor.white
        label.backgroundColor = self.customPurple
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var carLabel: UILabel = {
        let label = UILabel()
        label.text = "Car Model"
        label.textColor = UIColor.white
        label.backgroundColor = self.customPurple
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Color"
        label.textColor = UIColor.white
        label.backgroundColor = self.customPurple
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var carMakeLabel: UILabel = {
        let label = UILabel()
        label.text = "Car Maker"
        label.textColor = UIColor.white
        label.backgroundColor = self.customPurple
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var nameTF: UITextField = {
        let x = self.screenSize.midX + 20
        let width = self.screenSize.width/2 - 40
        let y = self.nameY
        let tf = UITextField(frame: CGRect(x: x, y: y, width: width, height: self.labelHeight))
        tf.adjustsFontSizeToFitWidth = true
        tf.attributedPlaceholder = NSAttributedString(string: "Your Name")
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        return tf
    }()
    
    
    lazy var carTF: UITextField = {
        let x = self.screenSize.midX + 20
        let width = self.screenSize.width/2 - 40
        let y = self.nameY + self.labelSpacing
        let tf = UITextField(frame: CGRect(x: x, y: y, width: width, height: self.labelHeight))
        tf.adjustsFontSizeToFitWidth = true
        tf.attributedPlaceholder = NSAttributedString(string: "Type of Car")
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        return tf
    }()
    
    lazy var carMakeTF: UITextField = {
        let x = self.screenSize.midX + 20
        let width = self.screenSize.width/2 - 40
        let y = self.nameY + self.labelSpacing * 2
        let tf = UITextField(frame: CGRect(x: x, y: y, width: width, height: self.labelHeight))
        tf.adjustsFontSizeToFitWidth = true
        tf.attributedPlaceholder = NSAttributedString(string: "Car Maker (ie Ford)")
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        return tf
    }()
    
    lazy var carColorTF: UITextField = {
        let x = self.screenSize.midX + 20
        let width = self.screenSize.width/2 - 40
        let y = self.nameY + self.labelSpacing * 3
        let tf = UITextField(frame: CGRect(x: x, y: y, width: width, height: self.labelHeight))
        tf.adjustsFontSizeToFitWidth = true
        tf.attributedPlaceholder = NSAttributedString(string: "Car Color")
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.masksToBounds = true
        return tf
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: CGFloat(0) , y: CGFloat(31) , width: self.screenSize.width, height: self.titleHeight))
        label.backgroundColor = self.customPink
        label.text = "Create Car"
        label.font = UIFont(name: "Copperplate-Bold", size: 60)
        label.textColor = self.customIndigo
        label.textAlignment = .center
        return label
    }()
    
    lazy var colorTitleBar: UILabel = {
        let label = UILabel(frame: CGRect(x:CGFloat(0), y: CGFloat(0), width: self.screenSize.width, height: 32))
        label.backgroundColor = self.customPink
        return label
    }()
    
    lazy var createCarBtn: UIButton = {
        let y = self.nameY  + self.labelSpacing * 4
        let width = self.screenSize.width - 40
        let btn = UIButton(frame: CGRect(x: 20, y: y, width: width , height: self.labelHeight * 1.5))
        btn.setTitle("Create Car", for: .normal)
        btn.setTitleColor(self.customPurple, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Copperplate-Bold", size: 50)
        
        btn.layer.cornerRadius = 7.0
        btn.layer.masksToBounds = true
        btn.layer.borderColor = self.customPurple.cgColor
        btn.layer.borderWidth = 1.5
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        btn.addTarget(self, action: #selector(createCar), for: .touchUpInside)
        return btn
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleHeight = screenSize.height * 0.17
        nameY = titleHeight + 32 + labelSpacing / 2
        let user = Auth.auth().currentUser
        CUid = user?.uid
        fire = Firestore.firestore()
        
        let labelArr = [nameLabel, colorLabel, carMakeLabel, carLabel ]
        let tfArr = [nameTF, carColorTF, carMakeTF, carTF]
        view.backgroundColor = customIndigo
        var i: CGFloat = 0
        for label in labelArr {
            view.addSubview(label)
            label.textColor = customIndigo
            let labelWidth = self.screenSize.width/2 - 30
            placeLabel(label: label, x: 20, y: (CGFloat(nameY + i * labelSpacing)), height: labelHeight, width: labelWidth)
            i+=1
        }
        
        for tf in tfArr {
            view.addSubview(tf)
        }
        view.addSubview(titleLabel)
        view.addSubview(colorTitleBar)
        view.addSubview(createCarBtn)
    }
    
    
    //MARK: View related functions
    
    /// Places the label based on the specified parameters
    /// - Parameters:
    ///   - label: the UILabel to be placed
    ///   - x: the positive diplacment from the center of the view
    ///   - y: the positive displacement fromt he top of the view
    ///   - height: Height of the label
    ///   - width: the width of the label
    func placeLabel(label: UILabel, x: CGFloat, y: CGFloat, height: CGFloat, width: CGFloat) {
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: width),
            label.heightAnchor.constraint(equalToConstant: height),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: x),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: y)
        ])
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut() // logs out the user or prints the errors
                performSegue(withIdentifier: "Logout", sender: self)
                print("LOGGED OUT")
            } catch { print(error) } //in a real version this should be better accounted for
        }
    }
    
    //MARK: Create cat methods
    
    @objc func createCar(){
        setUDCarValues()
        if name == "" || model == "" || color == "" || maker == "" {
            presentWarning(title: "Invalid Feild", message: "Please make sure all feilds are filled in.")
        }
        else {
            let doc = fire.collection("DriverAccounts").document(self.UD.string(forKey: "fst_d_id")!)
            doc.updateData([
                       "color" : color,
                       "maker" : maker,
                       "model" : model,
                       "driverName" : name
            ]){ err in
                if let err = err {
                    print("Error updating document - create car: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            performSegue(withIdentifier: "AllSet", sender: self)
        }
    }
    
    
    /// sets car values in the calss and in the user defaults
    func setUDCarValues(){
        name = nameTF.text!
        model = carTF.text!
        color = carColorTF.text!
        maker = carMakeTF.text!
        
        
        //TODO: I should probably make a car class or struct
        UD.set(name, forKey: "name")
        UD.set(model, forKey: "car_model")
        UD.set(maker, forKey: "car_maker")
        UD.set(color, forKey: "car_color")
    }
    
    func presentWarning(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

