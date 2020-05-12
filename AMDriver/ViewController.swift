//
//  ViewController.swift
//  AMDriver
//
//  Created by Charlie Ferguson on 8/27/19.
//  Copyright © 2019 cferguson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseDatabase
import FirebaseFirestore


class ViewController: UIViewController, FUIAuthDelegate {
    
    //Firestore Setup
    var authUI : FUIAuth?
    var ref : DatabaseReference?
    var loggedIn = false
    var fstore : Firestore!
    var newUser = false
    var firstViewDidLoad = true
    
    let UD = UserDefaults.standard
    
    
    //Outlets
    @IBOutlet var Login: UIView!
    @IBOutlet weak var CreateAccount: UIButton!
    
    //General Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers : [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
        fstore = Firestore.firestore()
        print("newUser - in viewdidload (ViewController) - ", newUser)
    }
    
    func isUserNew() {
        print("In isNewUser()")
        let Uid: String = Auth.auth().currentUser?.uid ?? "No UID"
        print("UID IS: ", Uid)
        let ref = fstore.collection("DriverAccounts").document(Uid)
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                //it is not a new driver account
                print("User already established")
                self.performSegue(withIdentifier: "Login", sender: self)
            } else {
                //NEW driver account
                print("USER IS NEW")
                self.createUser()
                self.performSegue(withIdentifier: "SetUpAccount", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated
    }
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print("IN AUTHUI - VIEWCONTROLLER")
        if error == nil { //user logged in
            print("User signed in - from authUI didSignInWith")
            print("IS THE USER NEW: ", self.newUser)
            if Auth.auth().currentUser != nil {
                UD.set(Auth.auth().currentUser?.uid, forKey: "fst_d_id")
                print("UD fst_d_id set to: ", UD.string(forKey: "fst_d_id") as Any)
                isUserNew()
            }
            else {
                 print("User is null")
            }
        }
        else { print("NO USER CREATED WHEN TRYING TO ADD USER DOC TO FIRESTORE")}
            
    }
    
    
    func createUser() {
        print("CREATING USER DOCUMENT")
        let userName: String = Auth.auth().currentUser?.displayName ?? "No Name"
        print("Post UID", UD.string(forKey: "fst_d_id") as Any)
        let ref = fstore.collection("DriverAccounts").document()
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                print("User already established")
               self.newUser = false
            } else {
                let data: [String: Any] = [
                    "Uid" : self.UD.string(forKey: "fst_d_id")!,
                    "name" : userName,
                    "InRide" : false,
                    "NumberOfRides" : 0,
                    "isDriving" : false //this could be a source of error in the fututre... make sure to update this in homepageVC in fstore
                ]
                self.fstore.collection("DriverAccounts").document(self.UD.string(forKey: "fst_d_id")!).setData(data)
                self.newUser = true
            }
        }
    }
    
    //Outlet Methods
    @IBAction func Login(_ sender: Any) {
        print("Login")
        //going to change this so only approved drivers can login
        if Auth.auth().currentUser == nil {
            if let authVC = authUI?.authViewController() {
                present(authVC, animated: true, completion: nil)
                print("logged in - from btn login")
            }
        }
        else {
            do {
                try Auth.auth().signOut()
                print("logged out - from btn login")
            }
            catch{}
        }
    }
    
    @IBAction func CreateAccount(_ sender: Any) {
        //going to change this so only approved drivers can login
    }
    
    
}

