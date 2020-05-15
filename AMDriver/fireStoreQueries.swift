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
    
    func removeRideFromClaimed(rideTag: String, fstore: Firestore){
        print("givenID  **Delete ride**: ", rideTag)
        fstore.collection("ClaimedRides").whereField("rideID", isEqualTo: rideTag).getDocuments() {(snapshot, err) in
            if err != nil {
                print(err!)
            }
            else {
                print("In delete ride ELSE")
                for document in (snapshot?.documents)! {
                    if let rideID = document.data()["rideID"] {
                        print(rideID)
                        fstore.collection("Ride List").document(rideID as! String).delete(){ err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addToCollection(ride: Ride, collection: String, time: NSDate, fireStore: Firestore) {
        fireStore.collection(collection).document(ride.UId).setData([
            "PickupLoc": ride.pickUpLoc,
            "DropoffLoc": ride.dropOffLoc,
            "currentUid": ride.UId,
            "Time": time,
            "Riders": ride.riders,
            "rideID": ride.rideID,
            "Name": ride.name
        ])
    }
    
    
}
