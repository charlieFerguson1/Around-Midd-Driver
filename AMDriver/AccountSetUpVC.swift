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
    
    //car details text fields
    @IBOutlet weak var carColorTF: UITextField!
    @IBOutlet weak var carBrandTF: UITextField!
    @IBOutlet weak var LisencePlateStateTF: UITextField!
    @IBOutlet weak var LiscencePlateNumberTF: UITextField!
    
    //car details labels
    @IBOutlet weak var ColorLabel: UILabel!
    @IBOutlet weak var BrandLabel: UILabel!
    @IBOutlet weak var LisencePlateLabel: UILabel!
    
    @IBOutlet weak var createCarBtn: UIButton!
    
    var CUid: String!
    var fire: Firestore!
    
    let UD = UserDefaults.standard
    
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        CUid = user?.uid
        //createCarBtn.btnCorner()
        fire = Firestore.firestore()
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
    @IBAction func createCarAction(_ sender: Any) {
        let color = carColorTF.text ?? "NO COLOR"
        let brand = carBrandTF.text ?? "NO BRAND"
        let state = LisencePlateStateTF.text ?? "NO STATE"
        let lpNum = LiscencePlateNumberTF.text ?? "NO NUMBER"
        
        let doc = fire.collection("DriverAccounts").document(self.UD.string(forKey: "fst_d_id")!)
        
        doc.updateData([
            "Car Color" : color,
            "Car Brand" : brand,
            "Lisence Plate State" : state,
            "Lisence Plate Number" : lpNum
            
            ])
        { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        performSegue(withIdentifier: "AllSet", sender: self)
    }
    
}

