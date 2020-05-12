//
//  ExecuteRideVC.swift
//  AMDriver
//
//  Created by Charlie Ferguson on 9/6/19.
//  Copyright © 2019 cferguson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseUI
import Stripe

class ExecuteRideVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pickupLoc: String = ""
    var dropoffLoc: String = ""
    var CUid: String = ""
    var stp_id: String = ""
    var time: NSDate?
    var numRiders: String?
    var rideID: String?
    var name: String = "N/A"
    var fireStore: Firestore!
    var paymentIntentClientSecret: String!
    
    let statusTitleMessages = [ "Enroute to Rider", "Waiting at Pickup for Rider", "On Trip to Dropoff"]
    let statusButtonMessages = [ "I've Arrived", "Start Trip", "Finish Trip"]
    var statusPhase = 0
    
    
    var rideValue: Int = 0
    var user: User?
    
    var inRide: Bool = true
    
    let screenSize: CGRect = UIScreen.main.bounds
    let tableTop: CGFloat = 280
    var titleHeight = CGFloat(270)
    let titleY = CGFloat(-250)
    let offBottomBtn: CGFloat = -100
    let btnHeight: CGFloat = 60


    
    let customIndigo: UIColor = UIColor(red: 38/255.0, green: 61/255.0, blue: 66/255.0, alpha: 1)
    let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
    
    let rideLabels = ["Name", "Pickup", "Dropoff", "# riders", "Earn"]
    var rideInfo: Array<String> = Array()
    
    var customerContext = STPCustomerContext(keyProvider: MyAPIClient())
    var paymentContext: STPPaymentContext!

    
    let clientSecretHandeler: (Bool, ExecuteRideVC) -> Void = {
        print("IM HANDELING IT (_CSH)")
        /* if ride is created */
        if $0 {
            /* go to next vc */
            print("Requesting payment")
            $1.paymentContext.requestPayment()
        }
    }
    
    init() {
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        super.init(nibName: nil, bundle: nil)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        self.paymentContext.paymentAmount = 5000 //This is in cents, i.e. $50 USD
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // *** tableView declarataion:
    let tableview: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
              return CGFloat(heightOfCell)
       }
       
    override func viewWillAppear(_ animated: Bool) {
        rideInfo.append(name)
        rideInfo.append(pickupLoc)
        rideInfo.append(dropoffLoc)
        rideInfo.append(String(numRiders ?? "1"))
        rideInfo.append(String(rideValue))
        print(rideInfo)
        print("view will appear end")
    }
    
    override func viewDidLoad() {
        setupTableView()
        super.viewDidLoad()
        view.addSubview(titleStatusLabel)
       // titleStatusLabel.centerYAnchor = NSLayoutYAxisAnchor(coder: 200)
        view.addSubview(cancelPickupBtn)
        view.addSubview(updateStatusBtn)
        
        titleStatusLabel.widthAnchor.constraint(equalToConstant: self.screenSize.width).isActive = true
        titleStatusLabel.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        titleStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: titleY).isActive = true


        /* (DO I NEED THIS) -> all info can be passed in?
           //establishing current user
           
           CUid = user?.uid
           //Set up firestore reference
           fstore = Firestore.firestore()
        */
    }
    
    

    lazy var titleStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.statusTitleMessages[self.statusPhase]
        label.font = UIFont(name: "Copperplate", size: 54)
        label.textColor = self.customIndigo
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
   
    
    lazy var cancelPickupBtn: UIButton = {
        let buttonWidth: CGFloat = self.screenSize.width/2 - 30
        let button = UIButton(frame: CGRect(x: CGFloat(15), y: self.screenSize.height + self.offBottomBtn, width: buttonWidth, height: CGFloat(self.btnHeight)))
        button.setTitle("Cancel Pickup", for: .normal)
        button.setTitleColor(self.customIndigo, for: .normal)
        button.titleLabel!.font = UIFont(name: "Copperplate", size: 24)
        
        button.layer.cornerRadius = 5.0
        
        button.layer.masksToBounds = true
        button.layer.borderColor = customPink.cgColor
        button.layer.backgroundColor = self.customPink.cgColor
        button.layer.borderWidth = 1.0
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        button.addTarget(self, action: #selector(didCancelRide), for: .touchUpInside)
        return button
    }()
    
    @objc func didCancelRide() {
        print("Cancel ride pressed!!")
        let ride = Ride(pickUpLoc: pickupLoc, dropOffLoc: dropoffLoc, UId: CUid, riders: numRiders ?? "1", rideID: rideID ?? "NO RIDE", name: name, stp_id: stp_id )
        ride.time = time
        ride.value = rideValue
        
        //potentially add a warning for when this is the only ride in the list..
        if(inRide) {
            deleteDocFromWaitingList(ride: ride, collection: "WaitingForDriver")
            addToCollection(ride: ride, collection: "Ride List")
            performSegue(withIdentifier: "Return Home", sender: self)
        }
        else{
            print("the user has no ride... something is wrong - maybe the rider canceled")
        }
        
        //if the driver has a ride -- should always have one
            //cancel ride, add back to ride list (in the front..)
        //put driver back to the choose ride screen
    }
    
    lazy var updateStatusBtn: UIButton = {
         let buttonWidth: CGFloat = self.screenSize.width/2 - 30
        let button = UIButton(frame: CGRect(x: CGFloat(45 + buttonWidth), y: self.screenSize.height + self.offBottomBtn, width: buttonWidth, height: CGFloat(self.btnHeight)))
         button.setTitle("I've Arrived", for: .normal)
         button.setTitleColor(self.customIndigo, for: .normal)
         button.titleLabel!.font = UIFont(name: "Copperplate", size: 24)
         button.layer.cornerRadius = 5.0
         
         button.layer.masksToBounds = true
         button.layer.borderColor = customPink.cgColor
         button.layer.backgroundColor = self.customPink.cgColor
         button.layer.borderWidth = 1.0
         button.titleLabel?.adjustsFontSizeToFitWidth = true

         
         button.addTarget(self, action: #selector(updateStatus), for: .touchUpInside)
         return button
     }()
    
    @objc func updateStatus() {
        print("update status")
        if( self.statusPhase <= 1) {
            statusPhase += 1
            titleStatusLabel.text = statusTitleMessages[statusPhase]
            updateStatusBtn.setTitle(statusButtonMessages[statusPhase], for: .normal)
            if(self.statusPhase == 1){
                let ride = Ride(pickUpLoc: pickupLoc, dropOffLoc: dropoffLoc, UId: CUid, riders: numRiders ?? "1", rideID: rideID ?? "NO RIDE", name: name, stp_id: stp_id )
                
                //create paymentIntent
                if rideID != nil {
                    MyAPIClient.sharedClient.createPaymentIntent(CUid: CUid, stp_id: stp_id, rideTag: rideID!, vc: self, fStoreClient: fireStore )
                }
                else { print("Class: ExecuteRideVC;  func: UpdateStatus\n    error: no ride id")}

                
                addToCollection(ride: ride, collection: "InRide")
                deleteDocFromWaitingList(ride: ride, collection: "WaitingForDriver")
            }
        }
        else if(self.statusPhase == 2){
            //execute charge on the riders card at the end of the ride - DRIVER IS SOLLY RESPONSIBLE FOR THIS
                //based on the current structure I need to also create the charge - should happen in the ride object of the DB
            //should segue to a new page that lists their money earned and what not - offers them to go back to HPVC
            performSegue(withIdentifier: "Return Home", sender: self)
        }
        else {
            print("error -- driver has gone through the full ride process")
        }
        //change labels
        //update database
    }
    
    
    /*
     TableView Code:
     */
    
    let infoCells = 5 //number of "cells" that will be displayed
    let heightOfCell = 80

    func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        
        //general tableview settings
        tableview.separatorStyle = .none
        tableview.backgroundColor = customIndigo
        tableview.translatesAutoresizingMaskIntoConstraints = false
        
        tableview.register(InfoCell.self, forCellReuseIdentifier: "cellId")
        view.addSubview(tableview)
        
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: tableTop),
            tableview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 30),
            tableview.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableview.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! InfoCell //change this to an info cell.. label and
        cell.backgroundColor = customIndigo
        cell.selectionStyle = .none

        if(pickupLoc != nil && dropoffLoc != nil){
            cell.infoLabel.text = String(rideLabels[indexPath.row])
            print(indexPath.row)
            cell.rideInfo.text = String(rideInfo[indexPath.row])
        }
        else{
            cell.infoLabel.text = "SET BY ELSE"
            cell.rideInfo.text = "SET BY ELSE"
        }
        return cell
        //code for what to do
    }
    
    func deleteDocFromWaitingList(ride: Ride, collection: String) {
        let riderideID = ride.rideID
        
        print("RIDE DOC ID - delete from collection :", riderideID)
        fireStore.collection(collection).document(riderideID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("DELETEDOCFROMRIDELIST: Document successfully removed!")
                print("DOC ID: ", riderideID)
            }
        }
    }
    
    
    /*
     adds ride to specified location in DB
     */
    func addToCollection(ride: Ride, collection: String) {
        let pickupLoc = ride.pickUpLoc
        let dropoffLoc = ride.dropOffLoc
        let CUid = ride.UId
        let time: NSDate = ride.time ?? getTime()
        let riders = ride.riders
        let rideID = ride.rideID
        let name = ride.name
        
        fireStore.collection(collection).document(rideID).setData([
            "PickupLoc": pickupLoc ,
            "DropoffLoc": dropoffLoc,
            "currentUid": CUid,
            "Time": time,
            "Riders": riders,
            "rideID": rideID,
            "Name": name
            ])
        
    }
    
    /* navigation */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HomePageVC {
            print("Hello")
        }
    }
    
    /* additional helper methods */
    
    func getTime() -> NSDate {
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
        return time
    }
    

}

class InfoCell: UITableViewCell {
    
    //class wide details
    let infoLabels = ["Pickup", "@", "DropOff", "Earn"]
    let screenSize: CGRect = UIScreen.main.bounds

        
    //basic cell setup
    let cellView: UIView = {
        let view = UIView()
        let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
        view.backgroundColor = customPink
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //cell details
    //STAT_LABEL -- header
       let infoLabel: UILabel = {
           let label = UILabel()
           label.text = "Info 1"
           label.textColor = UIColor.black
           label.font = UIFont(name: "Copperplate", size: 30)
           label.translatesAutoresizingMaskIntoConstraints = false
           label.textAlignment = .center
           return label
       }()
    
    //DYN_LABEL: for ride info -- body
    let rideInfo: UILabel = {
        let label = UILabel()
        label.text = "000 riders"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Copperplate", size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpView()
    }
    
    func setUpView() {
        //alignment of cells:
        let cellBoarder = CGFloat(10)
        
        //general text align
        let textHeight = CGFloat(140)
        //let textCenterY = CGFloat(25) —- not used anymore

        //label:
        let textWidthLabel = CGFloat(130)
        let textLeftAnchorLabel = CGFloat(15)
        
        //info:
        let textLeftAnchorInfo = textWidthLabel + textLeftAnchorLabel
        let textWidthInfo = self.screenSize.width - textLeftAnchorInfo - (cellBoarder * 2)
        
        let toFromX = CGFloat(130) //x value of left bound for to and from labels
        let toFromWidth = UIScreen.main.bounds.width - toFromX - 24
        

        addSubview(cellView)
        cellView.addSubview(infoLabel)
        cellView.addSubview(rideInfo)

        self.selectionStyle = .blue
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor, constant: cellBoarder * 2),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1 * cellBoarder),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: cellBoarder),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        infoLabel.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        infoLabel.widthAnchor.constraint(equalToConstant: textWidthLabel).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor, constant: 0).isActive = true
        infoLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: textLeftAnchorLabel).isActive = true
        rideInfo.textAlignment = .center

        rideInfo.heightAnchor.constraint(equalToConstant: textHeight ).isActive = true
        rideInfo.widthAnchor.constraint(equalToConstant: textWidthInfo).isActive = true
        rideInfo.centerYAnchor.constraint(equalTo: cellView.centerYAnchor, constant: 0).isActive = true
        rideInfo.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: textLeftAnchorInfo).isActive = true
        rideInfo.numberOfLines = 2
        rideInfo.textAlignment = .center
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExecuteRideVC: STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        /* update UI here */
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        print("___IN DELEGATE___")
        //requesting payment intent from backend
        print("*delegate method* - client secret: ", self.paymentIntentClientSecret!)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: self.paymentIntentClientSecret ?? "NILL")
        paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
        
        // Confirm the PaymentIntent
        STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
            switch status {
            case .succeeded:
                // Your backend asynchronously fulfills the customer's order, e.g. via webhook
                print("Success!!")
                completion(.success, nil)
            case .failed:
                completion(.error, error) // Report error
                print("fail!!")
            case .canceled:
                print("canceled!!")
                completion(.userCancellation, nil) // Customer cancelled
            @unknown default:
                completion(.error, nil)
            }
        }
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
}

