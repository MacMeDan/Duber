//
//  ViewController.swift
//  Duber
//
//  Created by P D Leonard on 1/20/17.
//  Copyright © 2017 MacMeDan. All rights reserved.
//

import UIKit
import Material
import SnapKit
import CoreLocation
import UberRides

class ViewController: UIViewController {
    let brandLabel          = UILabel()
    var fetchARideButton    = Button()
    var useMyLocationButton = Button()
    var showCard            = Button()
    let ridesClient         = RidesClient()
    var button              = RideRequestButton()
    
    //Login
    var uberScopes: [RidesScope]?
    var uberLoginManager: LoginManager?
    var uberLoginButton: LoginButton?
    
    var card            = UIView()
    let locationManager = CLLocationManager()
    var pickupLocation  = CLLocation()
    var dropoffLocation = CLLocation()
    var address         = String()
    var countryField    = TextField()
    var streetField     = TextField()
    var cityField       = TextField()
    var locationLabel   = UILabel()
    lazy var geocoder   = CLGeocoder()
    var findLocationBtn = Button()
    
    private let constant: CGFloat = 34
    private let margin: CGFloat = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        prepareNavigatonController()
        hideKeyboardWhenTappedAround()
        prepareBrandLabel()
        prepareFetchARideButton()
        prepareCardButton()
        prepareCard()
        prepareFindLocationBtn()
        prepareLocationLabel()
        prepareCountryTextField()
        prepareStreetField()
        prepareCityField()
        findUsersCurrentLocation()
    }
    
    func prepareView() {
        view.backgroundColor = Color.grey.darken4
    }
    
    func prepareNavigatonController() {
        navigationController?.navigationBar.barTintColor = Color.blue.darken4
        navigationController?.navigationBar.tintColor = Color.white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = Color.blue.lighten2
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: Color.white,
            NSFontAttributeName: Font.systemFontWithSize(size: 18)
        ]
    }
    
    //MARK: Style Helpers
    // This is where you can adjust values to effect multiple componets in the view
    func getButton() -> Button {
        let button = Button()
        button.backgroundColor = Color.black
        button.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
        button.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }
    
    func getStyledField() -> TextField {
        let textField = TextField()
        textField.textColor = Color.white
        textField.dividerNormalColor = Color.grey.darken4
        textField.placeholderNormalColor = Color.grey.darken4
        textField.snp.makeConstraints { (make) in
            make.width.equalTo(view.frame.width * 0.6)
        }
        return textField
    }

    func prepareLocationLabel() {
        locationLabel.text = "Enter Destination"
        locationLabel.font = RobotoFont.regular(with: 20)
        locationLabel.textColor = Color.white
        locationLabel.textAlignment = .center
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width * 0.6)
            make.top.equalTo(card.snp.top).offset(20)
            make.height.equalTo(20)
        }
    }
    
    func prepareBrandLabel() {
        brandLabel.text = "Duber"
        brandLabel.font = RobotoFont.bold(with: 40)
        brandLabel.textColor = Color.white
        view.addSubview(brandLabel)
        brandLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(40)
        }
    }
    // MARK: Fields Setup
    func prepareCountryTextField() {
        countryField = getStyledField()
        countryField.placeholder = "Country"
        //countryField.text = "USA"
        view.layout(countryField).top(6 * constant).horizontally(left: margin, right: margin)
    }
    
    func prepareStreetField() {
        streetField = getStyledField()
        streetField.placeholder = "Street"
        //streetField.text = "265S 900E"
        view.layout(streetField).top(8 * constant).horizontally(left: margin, right: margin)
    }
    
    func prepareCityField() {
        cityField = getStyledField()
        cityField.placeholder = "City"
        //cityField.text = "Provo"
        view.layout(cityField).top(10 * constant).horizontally(left: margin, right: margin)
        }
    
    
    // MARK: Buttons Setup
    func prepareFetchARideButton() {
        fetchARideButton = getButton()
        fetchARideButton.title = "Get estimate on trip?"
        fetchARideButton.addTarget(self, action: #selector(fetchARideAction), for: .touchUpInside)
        view.addSubview(fetchARideButton)
        fetchARideButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(brandLabel.snp.bottom).offset(180)
            make.width.equalTo(view.bounds.width * 0.6)
        }
    }
    
    func prepareFindLocationBtn() {
        findLocationBtn = getButton()
        findLocationBtn.addTarget(self, action: #selector(geocodeAction), for: .touchUpInside)
        findLocationBtn.setTitle("Find Location", for: .normal)
        
        view.addSubview(findLocationBtn)
        findLocationBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(card.snp.bottom).offset(-30)
            make.width.equalTo(view.frame.width * 0.6)
        }
    }
    
    func prepareUseMyCurrentLocationButton() {
        useMyLocationButton = getButton()
        useMyLocationButton.title = "Use Current Location"
        useMyLocationButton.addTarget(self, action: #selector(findUsersCurrentLocation), for: .touchUpInside)
        view.addSubview(useMyLocationButton)
        useMyLocationButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(fetchARideButton.snp.bottom).offset(40)
            make.width.equalTo(view.bounds.width * 0.6)
            make.height.equalTo(40)
        }
    }

    func prepareCardButton() {
        showCard = getButton()
        showCard.title = "Enter New Destination"
        showCard.addTarget(self, action: #selector(cardVisibility), for: .touchUpInside)
        view.addSubview(showCard)
        showCard.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(brandLabel.snp.bottom).offset(100)
            make.width.equalTo(view.bounds.width * 0.6)
            make.height.equalTo(40)
        }
    }
    
    // MARK: Button Actions
    func fetchARideAction() {
        prepareUberButton()
    }
    
    func prepareUberButton() {
        button.delegate = self
        var builder = RideParametersBuilder().setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation, nickname: address)
        ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: {
            product, response in
            if let productID = product?.productID {
                builder = builder.setProductID(productID)
                self.button.rideParameters = builder.build()
                self.button.loadRideInformation()
            }
        })
    }
    
    func geocodeAction() {
        guard let country = countryField.text, let street = streetField.text, let city = cityField.text else {
            assertionFailure("Could not get valid data for Country, Street or City")
            return
        }
        
        address = "\(country), \(city), \(street)"
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        dismissKeyboard()
        cardVisibility()
    }

    //MARK: Helper functions
    func cardVisibility(){
        let hideOrUnhide = !card.isHidden
        card.isHidden = hideOrUnhide
        countryField.isHidden = hideOrUnhide
        cityField.isHidden = hideOrUnhide
        streetField.isHidden = hideOrUnhide
        locationLabel.isHidden = hideOrUnhide
        findLocationBtn.isHidden = hideOrUnhide
    }
    
    
    func findUsersCurrentLocation() {
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func prepareCard() {
        card.backgroundColor = Color.grey.darken3
        view.addSubview(card)
        card.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(350)
            make.width.equalTo(view.bounds.width * 0.8)
            make.centerY.equalToSuperview().offset(-60)
        }
        card.cornerRadius = 8
        card.clipsToBounds = true
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            locationLabel.isHidden = false
            locationLabel.text = "Find Address"
            
        } else {
            var location: CLLocation?
            var placemark: CLPlacemark?
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
                placemark = placemarks.first
            }
            
            if let location = location {
                let coordinate = location.coordinate
                if let placemark = placemark, let number = placemark.subThoroughfare, let street = placemark.thoroughfare, let town = placemark.locality, let zip = placemark.administrativeArea {
                    address = number + street + " " + town + zip
                }
                
                dropoffLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                locationLabel.text = "Lat:\(coordinate.latitude), long: \(coordinate.longitude)"
            } else {
                locationLabel.text = "No Matching Location Found"
            }
        }
    }
    
}

extension ViewController: LoginButtonDelegate {
    func prepareLogin(){
        let scopes: [RidesScope] = [.Profile, .Places, .Request]
        let loginManager = LoginManager(loginType: .native)
        let loginButton = LoginButton(frame: CGRect(x: 0, y: 0, width: 300, height: 40), scopes: scopes, loginManager: loginManager)
        loginButton.presentingViewController = self
        loginButton.delegate = self
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-80)
            make.centerX.equalToSuperview()
        }
    }
    
    // #MARK: LoginButtonDelegate
    public func loginButton(_ button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?) {
        if let _ = accessToken {
            print("success getting AccessToken")
        } else if let error = error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    func loginButton(_ button: LoginButton, didLogoutWithSuccess success: Bool) {
        print(success)
    }
    
}

extension ViewController: TextFieldDelegate {
    /// Executed when the 'return' key is pressed when using the emailField.
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = true
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? ErrorTextField)?.isErrorRevealed = false
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        return true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension ViewController: RideRequestButtonDelegate {
    
    func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        view.addSubview(button)
        button.sizeToFit()
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(fetchARideButton.snp.bottom).offset(40)
        }
    }
    
    func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        let alert = UIAlertController(title: "Error", message: "Check that you have a destination set" , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Location has updated")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                assertionFailure()
                return
            }
            
            if (placemarks?.count)! > 0 {
                if let pm = placemarks?[0] {
                    self.displayLocationInfo(placemark: pm)
                }
            } else {
                print("Problem with the data received from geocoder")
            }
        })
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop the updating of users location to save battery life
            locationManager.stopUpdatingLocation()
            self.pickupLocation = containsPlacemark.location!
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
        assertionFailure()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status = status
        switch status {
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
        case.denied:
            alertIssueOfLocation()
        default:
            break
        }
    }
    
    func alertIssueOfLocation() {
        let alert = UIAlertController(title: "Warning", message: "Your Locations settings are not allowing Duber to locate you. You can fix this by going to your settings > location Services, and enabiling location for Duber", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
}
