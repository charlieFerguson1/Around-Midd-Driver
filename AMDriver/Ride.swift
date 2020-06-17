//
//  Ride.swift
//  AMDriver
//
//  Created by Charlie Ferguson on 8/20/19.
//  Copyright © 2019 cferguson. All rights reserved.
//

import Foundation

class Ride: CustomStringConvertible {
    
    var pickUpLoc: String
    var dropOffLoc: String
    var UId : String
    var stp_id: String
    var riders: String
    var rideID: String
    var name: String
    var value: Int?
    var completed: Bool?
    var time: NSDate?
    var timeString: String?
    var longitude: String?
    var latitude: String?
    var timeTillPickup: String = "Calculating"
    
    var canceledOn: Bool = false
    var claimed: Bool
    
    init(pickUpLoc: String, dropOffLoc: String, UId: String, riders: String, rideID: String, name: String, stp_id: String) {
        self.pickUpLoc = pickUpLoc
        self.dropOffLoc = dropOffLoc
        self.UId = UId
        self.riders = riders
        self.rideID = rideID
        self.name = name
        self.stp_id = stp_id
        claimed = false
    }
    
    public var description: String { return "PickUp: \(pickUpLoc) Dropoff: \(dropOffLoc) UId: \(UId) rideID: \(rideID)" }
    
    func claimRide() {
        claimed = true
    }
    
    func toString() { }
}

extension Ride: Equatable {
    static func == (lhs: Ride, rhs: Ride) -> Bool {
        return
            lhs.rideID == rhs.rideID 
                //lhs.UId == rhs.UId &&
                //lhs.pickUpLoc == rhs.pickUpLoc &&
                //lhs.dropOffLoc == rhs.dropOffLoc
    }
}
