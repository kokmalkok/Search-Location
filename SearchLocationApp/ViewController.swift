//
//  ViewController.swift
//  SearchLocationApp
//
//  Created by Константин Малков on 30.08.2022.
//задачи:
//несколько городов в списке
//камера при создании маршрута
//попробовать поиск по улице(но это не точно)
//добавление в избранное конкретную локацию
//добавить боковое меню для удобства навигации


//this is main class which show user location, set and show users custom direction from A point to B point, else setups visual view with or without some elements on user screen. And the main is searching for city (for streets and etc is in progress development)
import UIKit
import MapKit
import FloatingPanel
import CoreLocationUI

class ViewController: UIViewController{

    let mapView = MKMapView()
    let panel = FloatingPanelController()
    let searchVC = SearchViewController()
    let locationManager = CLLocationManager()
    var previosLocation: CLLocation?
    var lastLocation: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    let annotation = MKPointAnnotation()
    let geocoder = CLGeocoder()
    
    let pinImageView: UIImageView = {
       let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        image.sizeToFit()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(systemName: "mappin")
        image.tag = 1
        return image
    }()
    
    let labelText: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.tag = 1
        return label
    }()
    
    let setDirectionButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 8
        button.backgroundColor = .secondarySystemFill
        button.tintColor = .black
        button.setImage(UIImage(systemName: "figure.walk.circle",
                                withConfiguration: UIImage.SymbolConfiguration(
                                pointSize: 32,
                                weight: .medium)),
                                for: .normal)
        return button
    }()
    
    let hiddenButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.backgroundColor = .secondarySystemFill
        button.tintColor = .black
        button.setImage(UIImage(systemName: "mappin.circle",
                                withConfiguration: UIImage.SymbolConfiguration(
                                pointSize: 32,
                                weight: .medium)),
                                for: .normal)
        return button
    }()
    
    let favoriteButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 8
        button.backgroundColor = .secondarySystemFill
        button.setImage(UIImage(systemName: "star.circle",
                                withConfiguration: UIImage.SymbolConfiguration(
                                pointSize: 32,
                                weight: .medium)),
                                for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let locationButton: CLLocationButton = {
        let locationButton = CLLocationButton()
        locationButton.icon = .arrowOutline
        locationButton.isHighlighted = true
        locationButton.cornerRadius = 20
        locationButton.tintColor = .black
        locationButton.backgroundColor = .secondarySystemFill
        return locationButton
    }()
    
    let clearMapButton: UIButton = {
       let button = UIButton()
        button.setTitle("Clear map", for: .normal)
        button.titleLabel?.font = UIFont(name: "Zapf Dingbats", size: 16)
        button.layer.cornerRadius = 8
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .secondarySystemFill
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTrackingUserLocation()//all collected func for tracking user location
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let navBar = self.navigationController?.navigationBar {
            labelText.frame = CGRect(x: 0, y: 0, width: navBar.frame.width+20, height: navBar.frame.height)
            navBar.addSubview(labelText)
        }
        mapView.frame = view.bounds
        setDirectionButton.frame = CGRect(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top, width: 40, height: 40)
        hiddenButton.frame = CGRect(x: view.frame.size.width-40, y: view.safeAreaInsets.top, width: 40, height: 40)
        clearMapButton.frame = CGRect(x: view.frame.size.width-85, y: view.frame.size.height-150, width: 80, height: 40)
        pinImageView.frame = CGRect(x: view.center.x-20, y: view.center.y-20, width: 40, height: 40)
        locationButton.frame = CGRect(x: view.frame.size.width-40, y: view.safeAreaInsets.top+45, width: 40, height: 40)
        favoriteButton.frame = CGRect(x: view.frame.size.width-40, y: view.safeAreaInsets.top+90, width: 40, height: 40)
    }
    
    //MARK: - Objc methods
    //func for getting user location when user press on location button
    @objc private func didTapLocation(){
        useLocationManager()
        print("pressed")
    }
    //func for getting direction
    @objc private func didTapChooseDirection(){
        getDirectionWithoutInpot()
    }
    //add annotation on map
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer){
        if !labelText.isHidden {
            if gesture.state == .ended{
                streetName(location: gesture)
                let newGesture = gestureLocation(for: gesture)
                getDirection(locationDirection: newGesture)
            }
        } else if labelText.isHidden {
            if gesture.state == .ended {
                streetName(location: gesture)
            }
        }
    }
    //func for hide and show button. Neccesary for
    @objc private func didTapLabelHidden(){
        if labelText.tag == 1 {
            labelText.tag = 0
            labelText.isHidden = true
            pinImageView.isHidden = true
            setDirectionButton.isEnabled = false
            panel.removePanelFromParent(animated: true)
            hiddenButton.setImage(UIImage(systemName: "mappin.slash.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)), for: .normal)
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotation(annotation)
        } else if labelText.tag == 0 {
            labelText.tag = 1
            labelText.isHidden = false
            pinImageView.isHidden = false
            setDirectionButton.isEnabled = true
            panel.addPanel(toParent: self)
            hiddenButton.setImage(UIImage(systemName: "mappin.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)), for: .normal)
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotation(annotation)
        }
    }
    //func of cleaning view from directions and pins
    @objc private func didTapClearDirection(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotation(annotation)
    }
    //function of lift up view
    @objc func keyboardWillShow(notification: NSNotification){
        if let keyboardsize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardsize.height
            }
        }
    }
    //func of lift down view after using search bar
    @objc func keyboardWillHide(notification: NSNotification){
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    //targets for Favorite Button, which will work later
    @objc func didTapFavorite(){
        let vc = FavoriteTableViewController()
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        present(navVc, animated: true)
    }
    
    //MARK: - setup visual elements
    //settings for floating search panel
    func setupPanel(){
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
    }
    //add views in subview,targets and delegates
    func setupViewsTargetsAndDelegates(){
        //subview
        view.addSubview(mapView)
        view.addSubview(pinImageView)
        view.addSubview(setDirectionButton)
        view.addSubview(hiddenButton)
        view.addSubview(locationButton)
        view.addSubview(clearMapButton)
        view.addSubview(favoriteButton)
        //targets
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        setDirectionButton.addTarget(self, action: #selector(didTapChooseDirection), for: .touchUpInside)
        hiddenButton.addTarget(self, action: #selector(didTapLabelHidden), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        clearMapButton.addTarget(self, action: #selector(didTapClearDirection), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        //below two funcs which setup showing and hiding keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //delegates and secondary setups
        longGesture.minimumPressDuration = 1.0
        definesPresentationContext = true
        locationManager.delegate = self
        searchVC.delegate = self
        //mapview
        mapView.showsCompass = false
        mapView.delegate = self
        mapView.userTrackingMode = .followWithHeading
        mapView.addGestureRecognizer(longGesture)
    }
    //location manager settings
    func setupLocationManager(){
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    //func for getting user's location data
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
           let latitude = mapView.centerCoordinate.latitude
           let longitude = mapView.centerCoordinate.longitude
           return CLLocation(latitude: latitude, longitude: longitude)
    }
    //func with users location in cllocationcoordinate2d formatt
    func getCenterLocationCoordinate(for mapView: MKMapView) -> CLLocationCoordinate2D {
        let lat = mapView.centerCoordinate.latitude
        let lon = mapView.centerCoordinate.longitude
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    //func for gesture location and for output locations data
    func gestureLocation(for gesture: UILongPressGestureRecognizer) -> CLLocationCoordinate2D? {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        return coordinate
    }
    //func for  getting street name and number of buildings
    func streetName(location gesture: UILongPressGestureRecognizer){
        let center = gestureLocation(for: gesture)
        guard let center = center else {
            return
        }
        let locationData = CLLocation(latitude: center.latitude, longitude: center.longitude)
        geocoder.reverseGeocodeLocation(locationData) { [weak self] placemark, Error in
            guard let placemark = placemark?.first else {
                return
            }
            guard let self = self else {
                return
            }
            let streetName = placemark.thoroughfare ?? ""
            let streetNumber = placemark.subThoroughfare ?? ""
            DispatchQueue.main.async {
                self.annotation.coordinate = center
                self.annotation.title = "\(streetName), дом \(streetNumber)"
                self.mapView.addAnnotation(self.annotation)
            }
        }
    }
    //MARK: - Location Key methods
    //setup location for showing location by searching and press current location of user
    func useLocationManager(){
        LocationManager.shared.currentLocation { [weak self] location in
            DispatchQueue.main.async {
                self?.mapView.setRegion(MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)),
                                        animated: true)
            }
        }
    }
    //key func for collecting all funcs for working and showing first necessary information
    func startTrackingUserLocation(){
        setupLocationManager()
        setupViewsTargetsAndDelegates()
        useLocationManager()
        checkLocationServices()
        previosLocation = getCenterLocation(for: mapView) //collect last data with latitude and longitude
        setupPanel()
    }
    
    //MARK: - Direction Settings
    //func for starting showing direction. Func input user location and return polyline on map
    func getDirection(locationDirection: CLLocationCoordinate2D?){
        guard let checkLoc = locationDirection else {
            return
        }
        let request = createDirectionRequest(from: checkLoc)
        let directions = MKDirections(request: request)
        resetMap(withNew: directions)
        directions.calculate { [unowned self] response, error in
            //output alert if error
            guard let response = response, error == nil else {
                return
            }
            for route in response.routes {
                _ = route.steps
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    //same func as func above ,but without input data
    func getDirectionWithoutInpot(){
        let center = getCenterLocationCoordinate(for: mapView)
        let request = createDirectionRequest(from: center)
        let directions = MKDirections(request: request)
        resetMap(withNew: directions)
        directions.calculate { [unowned self] response, error in
            //output alert if error
            guard let response = response, error == nil else {
                return
            }
            for route in response.routes {
                _ = route.steps
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    //main setups for direction display. Input user location and output result of request by start and end location
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = coordinate
        let startingLocation      = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destination           = MKPlacemark(coordinate: destinationCoordinate)
        let request               = MKDirections.Request()
        request.source                       = MKMapItem(placemark: startingLocation)
        request.destination                  = MKMapItem(placemark: destination)
        request.transportType                = .walking
        request.requestsAlternateRoutes     = false
        
        annotation.coordinate = destinationCoordinate
        self.mapView.addAnnotation(annotation)
        return request
    }
    //func for clean direction
    func resetMap(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
   
    //MARK: - Error debagging and if statements
    //func checking if everything is work
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
    //check for error
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            useLocationManager()
            previosLocation = getCenterLocation(for: mapView)
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
            //show alert
        case .denied:
            break
            //show alert
        @unknown default:
            fatalError()
        }
    }
}
    //MARK: - Extensions
extension ViewController: SearchViewControllerDelegate {
    func searchViewController(_ vc: SearchViewController, didSeletLocationWith coordinates: CLLocationCoordinate2D?) {
        guard let coordinates = coordinates else {
            return
        }
        panel.move(to: .tip, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard  let locations = locations.last else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: locations.coordinate.latitude, longitude: locations.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate {
    //func for showing main adress data with centered pin on screen and show result on label in navigation bar
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        guard let previousLocation = self.previosLocation else {
            return
        }
        guard center.distance(from: previousLocation) > 50 else {
            return
        }
        previosLocation = center
        geocoder.reverseGeocodeLocation(center) { [weak self] placemark, error in
            guard let self = self else {
                return
            }
            if let _ = error {
                //add alert
                return
            }
            guard let placemark = placemark?.first else {
                //add alert
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            _ = placemark.areasOfInterest //info about places on map
            DispatchQueue.main.async {
                self.labelText.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    //polyline setups
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemIndigo
        return renderer
    }
}

