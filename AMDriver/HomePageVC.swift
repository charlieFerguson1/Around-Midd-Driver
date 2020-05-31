//
//  HomePageVC.swift
//  AMDriver
//
//  Created by Charlie Ferguson on 8/27/19.
//  Copyright © 2019 cferguson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseUI
import CoreLocation
import MapKit

class HomePageVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    let codeWords = [ "King", "Queen", "Wolf", "Fish", "Yeti", "Surf", "Wave", "Santa", "Door", "Tiger", "Cat"]
    let codeNum = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    var CUid: String!
    var rideList: [Ride] = [Ride]()
    var rideListEmpty = true
    let screenSize: CGRect = UIScreen.main.bounds
    var user: User?
    var rideId: String?
    var rideFstId: String?
    
    var visableRides = 4
    
    //spacing values
    var driverSwitchSpacingY = 200 as CGFloat
    var driverSwitchSpacingX = 25 as CGFloat
    
    var ScreenTitleY = 100 as CGFloat
    
    var logoutButtonX = 8 as CGFloat
    var logoutButtonY = 40 as CGFloat
    
    //location setup
    let locationManager = CLLocationManager()
    var driverLocation: CLLocationCoordinate2D?
    
    //arrival time setup
    private var currentRoute: MKRoute?
    
    var isDriving = true
    var onRide = false
    var passPickup = "No Ride"
    var passDropoff = "No Ride"
    var passName = "no name - HPVC"
    var passTime: NSDate?
    var passRideValue = 000
    var passRideID = ""
    var passStp_id = ""
    var rideCode = ""
    
    var numRiders = "1"
    var listener: ListenerRegistration!
    
    let customPink : UIColor = UIColor(red: 220/255.0, green: 191/255.0, blue: 255/255.0, alpha: 1)
    let customIndigo: UIColor = UIColor(red: 38/255.0, green: 61/255.0, blue: 66/255.0, alpha: 1)
    let customPurple : UIColor = UIColor(red: 166/255.0, green: 217/255.0, blue: 247/255.0, alpha: 1)
    
    
    // *** tableView declarataion:
    let tableview: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorColor = UIColor.white
        return tv
    }()
    
    /*
     driveing switch
     */
    lazy var driveSwitch: UISwitch = {
        let driveSwitch = UISwitch()
        driveSwitch.translatesAutoresizingMaskIntoConstraints = false
        driveSwitch.addTarget(self, action: #selector(didChangeRideSwitch), for: .valueChanged)
        driveSwitch.setOn(true, animated: true)
        return driveSwitch
    }()
    
    /*
     driving switch label
     */
    lazy var driveSwitchLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: self.screenSize.width - 170, y: self.driverSwitchSpacingY + 8, width: 120, height: 100))
        
        driveSwitch.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Driving"
        label.font = UIFont(name: "Copperplate", size: 24)
        label.textColor = self.customPurple
        return label
    }()
    
    /*
     button for logging out
     */
    lazy var logoutButton: UIButton = {
        let logoutBtn = UIButton(frame: CGRect(x: self.logoutButtonX, y: self.logoutButtonY, width: 100, height: 40))
        logoutBtn.setTitle( "Logout", for: .normal)
        logoutBtn.setTitleColor( self.customPink, for: .normal)
        logoutBtn.titleLabel!.font = UIFont(name: "Copperplate", size: 24)
        logoutBtn.layer.cornerRadius = 5.0
        
        logoutBtn.layer.masksToBounds = true
        logoutBtn.layer.borderColor = customPink.cgColor
        logoutBtn.layer.borderWidth = 1.0
        
        logoutBtn.addTarget(self, action: #selector(didLogout), for: .touchUpInside)
        return logoutBtn
    }()
    
    /*
     screen label
     */
    lazy var ScreenTitle: UILabel = {
        let screenTitle = UILabel(frame: CGRect(x: 0, y: self.ScreenTitleY, width: self.screenSize.width, height: 100))
        screenTitle.text = "Select a Ride to Pick Up"
        screenTitle.font = UIFont(name: "Copperplate-Bold", size: 42)
        screenTitle.textAlignment = .center
        screenTitle.textColor = self.customPurple
        screenTitle.numberOfLines = 2
        return screenTitle
    }()
    
    /*
     amount earned by driver.. needs to be created on the backend
     */
    lazy var AmountEarned: UILabel = {
        let label = UILabel(frame: CGRect(x: self.logoutButtonX, y: self.driverSwitchSpacingX + 5, width: 50, height: 50))
        
        return label
    }()
    
    /* END OF VIEW INITS */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = customIndigo
        setupTableView()
        view.addSubview(driveSwitch)
        view.addSubview(driveSwitchLabel)
        view.addSubview(ScreenTitle)
        view.addSubview(logoutButton)
        
        driveSwitch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(driverSwitchSpacingY)).isActive = true
        driveSwitch.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: CGFloat(-driverSwitchSpacingX)).isActive = true
        
        //establishing current user
        user = Auth.auth().currentUser
        CUid = user?.uid
        //Set up firestore reference
        fstore = Firestore.firestore()
        
        
        //location setup
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        startMySignificantLocationChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //attatch listener for labels
        listener = labelListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //detatch listener for labels
        listener.remove()
    }
    
    
    /*
     TableView Code:
     */
    func setupTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.separatorStyle = .none
        tableview.backgroundColor = customIndigo
        tableview.register(RideCell.self, forCellReuseIdentifier: "cellId")
        view.addSubview(tableview)
        
        NSLayoutConstraint.activate([
            tableview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300),
            tableview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
            tableview.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableview.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visableRides
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! RideCell
        cell.backgroundColor = self.customIndigo
        cell.selectionStyle = .none
        cell.rideLabel.text = "Ride \(indexPath.row+1)"
        //if index is higher than number of rides
        if(indexPath.row >= rideList.count){
            //set values to null
            cell.numRidersLabel.text = "Waiting for ride requests"
            cell.fromLabel.text = ""
            cell.toLabel.text = ""
            cell.rideValueLabel.text = ""
        }
        else{
            if(Int(rideList[indexPath.row].riders) ?? 1 > 1){
                cell.numRidersLabel.text = String(rideList[indexPath.row].riders) + " Riders"
            }
            else {
                cell.numRidersLabel.text = String(rideList[indexPath.row].riders) + " Rider"
            }
            cell.fromLabel.text = "From: " + String(rideList[indexPath.row].pickUpLoc)
            cell.toLabel.text = "To: " + String(rideList[indexPath.row].dropOffLoc)
            cell.rideValueLabel.text = "$10"
            //cell.rideValueLabel = "$" + String(rideList[indexPath.row].rideValue)
            
        }
        //let tap = UITapGestureRecognizer(target: self, action: #selector(self.tableDidTap(sender:)))
        
        cell.textLabel?.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.tableDidSwipeLeft(sender:)))
        cell.textLabel?.addGestureRecognizer(swipeLeft)
        return cell
    }
    
    /*
     size of table view -
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    /*
     swiping on table ~ not currently working
     */
    @objc func tableDidSwipeLeft(sender: UITapGestureRecognizer) {
        print("swipe right")
    }
    
    /*
     ride selection/assignment note:
     there should potentially be different queues for the various pickup locations
     - if a driver is dropping off at a certain location then they should be able to pick up in locations near by if there are available rides
     - ** this is a next step for optimization.. but should only be added once things are up
     and running.
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if(rideList.count > indexPath.row)
        {
            if(isDriving) {
                //should also check to see if the driver is already driving
                didPickupRide(row: indexPath.row) //updates database
                
                passPickup = rideList[indexPath.row].pickUpLoc
                passDropoff = rideList[indexPath.row].dropOffLoc
                numRiders = rideList[indexPath.row].riders
                passName = rideList[indexPath.row].name
                passTime = rideList[indexPath.row].time
                passRideID = rideList[indexPath.row].rideID
                passStp_id = rideList[indexPath.row].stp_id
                rideFstId = rideList[indexPath.row].UId
                
                /* update DB to refelct the fact that the ride has been picked up and has a TTPU
                 - maybe this should be just a passed value that is then sent to the DB n the next VC*/
                
                
                performSegue(withIdentifier: "PickedUp", sender: self)
            }
            else {
                presentWarning(title: "Warning", message: "You are not currently in driving mode. Please switch on driving to select a ride")
            }
        }
        else {
            presentWarning(title: "Warning", message: "Please select a ride that has valid information. If there are no valid rides, check back later")
        }
    }
    
    /*
     updates firestore database to be concurrent with the state of things
     - moves doc to driverEnRoute
     */
    func didPickupRide(row: Int) {
        moveRideToClaimed(ride: rideList[row])
        deleteDocFromRideList(row: row)
        setInDrive(inDrive: true)
    }
    
    
    //MARK: Location related functions
    
    /// Adds a listener to the users current location. If the device is able to provide location
    /// updates, it activates the listener.
    func startMySignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            print("The device does not support this kind of monitoring.")
            return
        }
        print("Class: HPVC  location changes activated")
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    
    /// Sets the time till pick up for up to the first 4 rides in the array
    func setTTPU() {
        let rideCount = self.rideList.count
        var loopCount = rideCount - 1
        if rideCount > 4 {
            loopCount = 3
        }
        print("Class: HPVC      Func: setTTPU\n   >loopCount: ", loopCount)
        while loopCount >= 0 {
            let ride = self.rideList[loopCount]
            if driverLocation != nil {
                constructRoute(userLocation: driverLocation!, ride: ride)
            }
            
            loopCount = loopCount - 1
        }
    }
    
    
    func constructRoute(userLocation: CLLocationCoordinate2D, ride: Ride)  {
        print("Class: HPVC      Func: ConstructRoute")
        print(" >ride.pickUpLoc: ", ride.pickUpLoc)
        let pickupLocation = UD.location(forKey: ride.pickUpLoc) as! CLLocation
        let pickupCordninates = pickupLocation.coordinate
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        print("userlocations:\n >", userLocation)
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: pickupCordninates))
        print("pickupcordinates:\n >", pickupCordninates)
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate(completionHandler: {(directionsResponse, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let response = directionsResponse, response.routes.count > 0 {
                self.currentRoute = response.routes[0]
                let travelTime = self.currentRoute?.expectedTravelTime
                print("Travel Time: ", travelTime?.description ?? "travel Time failed")
                ride.timeTillPickup = travelTime?.description as! String
            }
            else {print("Class: HPVC      Func: ConstructRoute --- in else")}
        })
    }
    
    
    func createCode() -> String{
        let randWord = codeWords[Int.random(in: 0 ... 10)]
        let randNum = codeNum[Int.random(in: 0 ... 10)]
        
        return randWord + randNum
    }
    /*
     can this be moved to an external class?
     */
    func moveRideToClaimed(ride: Ride) {
        let time: NSDate = ride.time ?? getTime()
        rideCode = createCode()
        fstore.collection("ClaimedRides").document(ride.rideID).setData([
            "PickupLoc": ride.pickUpLoc,
            "DropoffLoc": ride.dropOffLoc,
            "currentUid": ride.UId,
            "Time": time,
            "Riders": ride.riders,
            "rideID": ride.rideID,
            "Name": ride.name,
            "stp_id": ride.stp_id,
            "driverName": UD.string(forKey: "name")! ,
            "carMake" : UD.string(forKey: "car_maker")!,
            "carModel" : UD.string(forKey: "car_model")!,
            "color" : UD.string(forKey: "car_color")!,
            "carSeats" : String(UD.string(forKey: "car_seats")!),
            "code" : rideCode
        ])
    }
    
    func presentWarning(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    /*
     responds to changes of the ride switch
     */
    @objc func didChangeRideSwitch() {
        if isDriving == false { isDriving = true }
        else { isDriving = false }
        print("isDriving val: ", isDriving)
        /*
         potentially add a color setting where the table cells would turn gray
         */
    }
    
    func labelListener() -> ListenerRegistration {
        let listener = fstore.collection("Ride List").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("************ADDING************")
                    print(" New ride: \(diff.document.data())")
                    if diff.document.data()["rideID"] != nil {
                        let rideIDData = diff.document.data()["rideID"] as! String
                        if rideIDData != "" {
                            self.rideFromData(data: diff.document.data())
                            print("RIDE LIST (listner):", self.rideList)
                            self.updateTableFromListner()
                        }
                    }
                }
                if (diff.type == .modified) {
                    print("************MOD************")
                    print(" Modified ride: \(diff.document.data())")
                    self.rideFromData(data: diff.document.data())
                    print("RIDE LIST (listner):", self.rideList)
                    self.updateTableFromListner()
                }
                if (diff.type == .removed) {
                    print("************REMOVING************")
                    print(" Removed ride: \(diff.document.data())")
                    if(diff.document.data()["rideID"] as? String != nil)
                    {
                        let RID = diff.document.data()["rideID"] as! String
                        self.removeSpecificRide(rideID: RID)
                        print("RIDELIST in remove: ", self.rideList)
                        self.updateTableFromListner()
                    }
                    else {
                        print("Ride not on database")
                    }
                }
            }
        }
        return listener
    }
    
    func updateTableFromListner() {
        tableview.reloadData()
    }
    
    /// Removes a ride specified by the ride tag string from the local array.
    /// this does nothing to the database. Sets the rideListEmpty bool at the end.
    /// - Parameter rideID: a string describing the ride to be removed
    func removeSpecificRide(rideID: String) {
        print("RIDELIST IN REMOVE SPECIFIC RIDE (START):", rideList)
        
        let ride = rideList.first(where: { $0.rideID == rideID})! 
        let index = rideList.firstIndex(of: ride) ?? 0
        rideList.remove(at: index)
        print("RIDELIST IN REMOVE SPECIFIC RIDE (END):", rideList)
        setRideListEmptyBool()
    }
    
    /// Creates a ride from the data and adds it to the local array.
    /// This array is predominantly used to disply rides to the driver
    /// if the ride is in the first 4 rides in the array it sets the value of TTPU
    /// - Parameter data: data description from a firestore query
    func rideFromData(data: [String : Any])  {
        let pickup = data["PickupLoc"] as! String
        let drop = data["DropoffLoc"] as! String
        let id = data["currentUid"] as! String
        let riders = data["Riders"]as! String
        let rideID = data["rideID"] as! String
        let name = data["Name"] as! String
        let stp_id = data["stp_id"] ?? "this is an old ride"
        
        let ride = Ride(pickUpLoc: pickup, dropOffLoc: drop, UId: id, riders: riders, rideID: rideID, name: name, stp_id: stp_id as! String)
        self.rideList.append(ride)
        let rideCount = self.rideList.count
        if rideCount <= 4 {
            let ride = rideList[rideCount - 1]
            if driverLocation != nil {
                constructRoute(userLocation: driverLocation!, ride: ride)
            }
        }
    }
    
    /*
     can probably move this to an external class
     */
    func setInDrive(inDrive: Bool) {
        var ref: DocumentReference? = nil
        ref = fstore.collection("DriverAccounts").document(CUid)
        ref?.updateData([
            "InRide" : inDrive
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated -- set in drive")
            }
        }
    }
    
    /*
     this may not have any callers... should go if so
     */
    func updateRideTable(){
        setRideListEmptyBool()
        if rideListEmpty {
            print("NOTE: Ride list empty")
        }
        else{
            print("RIDE TO DISPLAY: ", self.rideList[rideList.count - 1])
        }
    }
    
    
    func setRideListEmptyBool() {
        if rideList.count > 0 {
            rideListEmpty = false
        }
        else {
            rideListEmpty = true
        }
    }
    
    /*
     can I move this to an external class (firestore queires)?
     - if I move this, pass a rideId instead of the row
     */
    func deleteDocFromRideList(row: Int) {
        let ride = rideList[row]
        let riderideID = ride.rideID
        
        print("RIDE DOC ID - DELETEDOCFROMRIDELIST:", riderideID)
        fstore.collection("Ride List").document(riderideID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("DELETEDOCFROMRIDELIST: Document successfully removed!")
                print("DOC ID: ", riderideID)
            }
        }
    }
    
    
    func getTime() -> NSDate {
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
        return time
    }
    
    
    @objc func didLogout() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut() // logs out the user or prints the errors
                performSegue(withIdentifier: "LogoutFromHome", sender: self)
                print("LOGGED OUT")
            } catch { print(error) } //in a real version this should be better accounted for
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ExecuteRideVC {
            vc.pickupLoc = passPickup
            vc.dropoffLoc = passDropoff
            vc.CUid = rideFstId ?? "no ride FstID"
            vc.stp_id = passStp_id
            vc.time = passTime
            vc.numRiders = numRiders
            vc.name = passName
            vc.rideID = passRideID
            vc.rideValue = passRideValue
            vc.user = self.user
            vc.fireStore = fstore
            vc.rideCode = self.rideCode
        }
    }
}



class RideCell: UITableViewCell{
    
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
    let rideLabel: UILabel = {
        let label = UILabel()
        label.text = "Ride 1"
        label.textColor = UIColor.black
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let numRidersLabel: UILabel = {
        let label = UILabel()
        label.text = "00 riders"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Copperplate", size: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let rideValueLabel: UILabel = {
        let label = UILabel()
        label.text = "$000"
        label.textColor = UIColor.white
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let fromLabel: UILabel = {
        let label = UILabel()
        label.text = "From: "
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let toLabel: UILabel = {
        let label = UILabel()
        label.text = "To: "
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "Copperplate", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpView()
    }
    
    func setUpView() {
        
        let toFromX = CGFloat(130) //x value of left bound for to and from labels
        let toFromWidth = UIScreen.main.bounds.width - toFromX - 24
        
        addSubview(cellView)
        cellView.addSubview(rideLabel)
        cellView.addSubview(numRidersLabel)
        cellView.addSubview(rideValueLabel)
        cellView.addSubview(toLabel)
        cellView.addSubview(fromLabel)
        
        self.selectionStyle = .blue
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            cellView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
        ])
        
        rideLabel.heightAnchor.constraint(equalToConstant: 140).isActive = true
        rideLabel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        rideLabel.centerYAnchor.constraint(equalTo: cellView.topAnchor, constant: 15).isActive = true
        rideLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 15).isActive = true
        
        numRidersLabel.heightAnchor.constraint(equalToConstant: 140).isActive = true
        numRidersLabel.widthAnchor.constraint(equalToConstant: 400).isActive = true
        numRidersLabel.centerYAnchor.constraint(equalTo: cellView.topAnchor, constant: 40).isActive = true
        numRidersLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 10).isActive = true
        
        rideValueLabel.heightAnchor.constraint(equalToConstant: 140).isActive = true
        rideValueLabel.widthAnchor.constraint(equalToConstant: 135).isActive = true
        rideValueLabel.centerYAnchor.constraint(equalTo: cellView.topAnchor, constant: 80).isActive = true
        rideValueLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 10).isActive = true
        
        fromLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fromLabel.widthAnchor.constraint(equalToConstant: toFromWidth).isActive = true
        fromLabel.centerYAnchor.constraint(equalTo: cellView.topAnchor, constant: 80).isActive = true
        fromLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: toFromX).isActive = true
        
        toLabel.heightAnchor.constraint(equalToConstant: 140).isActive = true
        toLabel.widthAnchor.constraint(equalToConstant: toFromWidth).isActive = true
        toLabel.centerYAnchor.constraint(equalTo: cellView.topAnchor, constant: 40).isActive = true
        toLabel.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: toFromX).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}//end of ride cell

extension HomePageVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updated from HPVC!\n    >adding to the UD")
        /* record the first update to this persons location */
        if let currentLoc = locations.last {
            print(" >currentLoc: ", currentLoc)
            self.driverLocation = currentLoc.coordinate
            let latitude = currentLoc.coordinate.latitude
            let longitude = currentLoc.coordinate.longitude
            UD.set(latitude, forKey: "current_latitude")
            UD.set(longitude, forKey: "current_longitude")
            setTTPU()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to deliver location data")
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopMonitoringSignificantLocationChanges()
            print(error)
            return
        }
    }
}
