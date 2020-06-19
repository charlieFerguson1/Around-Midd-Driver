//
//  MyAPIClient.swift
//  AMDriver
//
//  Created by Charlie Ferguson on 4/21/20.
//  Copyright © 2020 cferguson. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import Firebase
import FirebaseUI
import FirebaseFirestore

class MyAPIClient: NSObject, STPCustomerEphemeralKeyProvider{
    
    static let sharedClient = MyAPIClient() //initializes an instance of this class
    var baseURLString: String? = "https://us-central1-around-midd.cloudfunctions.net"
    var customerId:String!
    var fStoreClient : Firestore!
    var CUid:String!

    var baseURL: URL {
           if let urlString = self.baseURLString, let url = URL(string: urlString) {
               return url
           } else {
               fatalError()
           }
       }
    
    func createPaymentIntent(CUid: String, stp_id: String, rideTag: String, vc: ExecuteRideVC, fStoreClient: Firestore) {
        print("Class: MYAPICLient; Func: createPaymentIntent")
        self.fStoreClient = fStoreClient
        let url = self.baseURL.appendingPathComponent("delayedPaymentIntent") //this is the path to the backend function
        print("URL: ", url)
        //create payment intent
        AF.request(url, method: .post, parameters: [
            "customer_id" : stp_id,
            "amount" : 4000
        ])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any] {
                        let clientSecret = JSON["clientSecret"] as! String
                        print(" Clinet secret (MYAPI):\n     ", clientSecret)
                        print(" Ride tag (MYAPI):\n     ", rideTag)
                        firestoreQueries().addClientSecret(rideTag: rideTag, fstore: self.fStoreClient, secret: clientSecret)
                        vc.paymentIntent = clientSecret
                    }
                case .failure(let error):
                    print(error)
                    break
                    // error handling
                    
                }
        }
    }
    
    func captureFunds(paymentIntent: String, captureAmount: Int) {
        let url = self.baseURL.appendingPathComponent("captureFunds")
        AF.request(url, method: .post, parameters: [
            "paymentIntent": paymentIntent,
            "captureAmount": captureAmount
        ])
        .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any] {
                        let captured = JSON["captured"] as! String
                        print(captured)
                    }
                case .failure(let error):
                    print(error)
                    break
                    // error handling
                    
                }
        }
    }
    
    func calculateArrivalTime(ride: Ride, driverLong: String, driverLat: String, firestore: Firestore) -> String {
        let arivalTime = "15"
        
        return arivalTime
    }

    func setCustomerID(fstId: String, completion: @escaping () -> Void)  {
        print("Class: MYAPIClient;    Func: setCustomerID")
        
        fStoreClient = Firestore.firestore()
        print("   Querry to:  ", fstId)
        let ref = fStoreClient.collection("RiderAccounts").document(fstId)
        ref.getDocument() { (document, error) in
            if let document = document, document.exists {
                let temp = document.data()
                print("(MYAPICli): setCustomerID:")
                print("   customerid in query: ", temp!["stp_id"] ?? "NIL")
                self.customerId = temp!["stp_id"] as? String
                print("        Customerid    : ", self.customerId ?? "NO CUSTOMER")
                completion()
                
            } else {
                print("Document does not exist -- Func: setCustomerID")
            }
        }
    }
    
    /*
     createCustometKey:
        not sure what this does or if its still needed...
     
     */
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("Class: MYAPIClient;    Func: createCustomerKey")
        /*
        //setting customer id so that there is the proper input below
        let url = self.baseURL.appendingPathComponent("ephemeralKeys") // this is the call to the backend function!!
        setCustomerID(fstId: ) {
            print("createCustoemrKey - querry")
            if( self.customerId != nil) {
                AF.request(url, method: .post, parameters: [
                    "api_version": apiVersion,
                    "customer_id": self.customerId!
                ])
                    .validate(statusCode: 200..<300)
                    .responseJSON { responseJSON in
                        switch responseJSON.result {
                        case .success(let json):
                            completion(json as? [String: AnyObject], nil)
                        case .failure(let error):
                            completion(nil, error)
                        }
                }
            }
            else { print(" The current customer id has not been set") }
        }
         */
    }
    
    
}
