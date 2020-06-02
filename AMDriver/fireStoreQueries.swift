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
import CoreLocation

class firestoreQueries {
    var UD = UserDefaults.standard

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
    
    func addTimeTillArrival(rideTag: String, fstore: Firestore, time: String) {
        print("Ride Tag FSQ: ", rideTag)
        var ref: DocumentReference? = nil
        ref = fstore.collection("ClaimedRides").document(rideTag)
        ref?.updateData([
            "timeTillArrival" : time
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
                        fstore.collection("ClaimedRides").document(rideID as! String).delete(){ err in
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
    
    /// Retrieves the locations and their cordinates from the DB. Sets the user default
    /// for the pickup and dropoff location arrays and cordinate dictionaries
    /// - Parameters:
    ///   - type: pickup or dropoff
    ///   - firestore: firestore instance
    func getLocationDict(type: String, firestore: Firestore) {
        var cordinates: [String: CLLocation] = [:]
        var locations: [String] = []
        let arrayName = type + "_locations"
        //let dictionaryName = type + "_cordinates"
        firestore.collection(type + "Locations").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let temp = document.data()
                    let locationName: String = temp["Location"] as! String
                    let long: Double = temp["longitude"] as! Double
                    let lat: Double = temp["latitude"] as! Double
                    let loc = CLLocation(latitude: lat, longitude: long)
                    print(" >location: ", locationName)
                    locations.append(locationName)
                    cordinates[locationName] = loc
                    self.UD.set(lat, forKey: locationName + "_lat")
                    self.UD.set(long, forKey: locationName + "_long")
                    self.UD.set(location: loc, forKey: locationName)
                }
                self.UD.set(locations, forKey: arrayName)
                //self.UD.set(cordinates, forKey: dictionaryName)
            }
        }
    }
}
