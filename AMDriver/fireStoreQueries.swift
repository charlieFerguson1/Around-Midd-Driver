//
//  fireStoreQueries.swift
//  AMDriver
//
//  Created by Charlie Ferguson on 4/22/20.
//  Copyright © 2020 cferguson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI
import FirebaseDatabase
import FirebaseFirestore

class firestoreQueries {
    
    func addClientSecret(rideTag: String, fstore: Firestore, secret: String) {
        print("Add secret to FSQ: ", secret)
        print("Ride Tag FSQ: ", rideTag)
        var ref: DocumentReference? = nil
        ref = fstore.collection("Ride List").document(rideTag)
        ref?.updateData([
            "clientSecret" : secret
        ]){ err in
            if let err = err {
                print("Error updating document *addClientSecret*: \(err)")
            } else {
                print("Document successfully updated -- added client Sectet")
            }
        }
    }
}
