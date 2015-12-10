//
//  MapViewController.swift
//  Voyage
//
//  Created by Joe E. on 11/14/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit
import MapKit

private let REGION_RADIUS:Double = 1000

private let CITY = "city"
private let EGYPT = "Egypt"
private let LONDON = "London"
private let VEGAS = "Vegas"
private let TOKYO = "Tokyo"

private let COORDINATES = "coordinates"
private let _co1 = [26.000, 30.000] //Egypt
private let _co2 = [51.5072,  0.1275] // London
private let _co3 = [36.1215, -115.1739] // Las Vegas
private let _co4 = [35.6833, 139.6833] // Tokyo

private let journeys:[String:AnyObject] = [
        CITY : [EGYPT,LONDON, VEGAS, TOKYO],
        COORDINATES :[_co1,_co2,_co3,_co4]
    ]

class MapViewController: UIViewController {
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = REGION_RADIUS

    var animationIsOccuring = false
    
    var timer: NSTimer?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var journeyPickerView: UIPickerView!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    //MARK - @IBOutlets
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func mapViewPressedAndHeld(sender: UILongPressGestureRecognizer) {
        print("worked")
        
        if animationIsOccuring == false {
            UIView.animateWithDuration(0.50) { () -> Void in
                self.animationIsOccuring = true
                self.journeyPickerView.alpha = 0
                self.journeyPickerView.hidden = false
                self.journeyPickerView.alpha = 1
                
            }
            
        }

        print(journeyPickerView.hidden)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(journeyPickerView)
        view.bringSubviewToFront(cameraButton)
        setLocationManager(locationManager)
        
        mapView.delegate = self
        longPressGestureRecognizer.delegate = self
        journeyPickerView.delegate = self
        
        mapView.showsUserLocation = true
        journeyPickerView.hidden = true
        cameraButton.hidden = false
        
        setInitialMap()

        guard let coordinatesArray = journeys[COORDINATES] else { return }
        print(coordinatesArray)
        guard let coordinates = coordinatesArray[0] else { return }
        print(coordinates)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}

extension MapViewController : MKMapViewDelegate {
    func setInitialMap() {
        let userLocation = locationManager.location?.coordinate
        let delta = 0.01
        
        let latDelta = delta
        let longDelta = delta
        
        guard let latitude = userLocation?.latitude else { return }
        guard let longitude = userLocation?.longitude else { return }
        
        let center = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
        
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isMemberOfClass(MKUserLocation) {
            return nil
        } else {

        }
        
        return MKAnnotationView()
    }
    
    func setUpMapView(mapView:MKMapView) {
        mapView.delegate = self
    
    }
    
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        setLocationManager(locationManager)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
    }


    func setLocationManager(locationManager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
    }
    
}

extension MapViewController : UIGestureRecognizerDelegate {
    
    
    
}

extension MapViewController : UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return journeys.count //pickerDataSource.count
        return journeys[CITY]!.count as Int
        
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return journeys[CITY]![row] as? String
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UIView.animateWithDuration(0.50, animations: { () -> Void in
            pickerView.alpha = 0
            
            guard let coordinatesArray = journeys[COORDINATES] else { return }
            guard let coordinates = coordinatesArray[row] else { return }
            guard let latitude = coordinates[0] as? Double else { return }
            guard let longitude = coordinates[1] as? Double else { return }
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            let delta = 0.01
            
            let latDelta = delta
            let longDelta = delta
            
            let center = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
            let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
            print(latitude)
            print(longitude)
            
            self.mapView.setRegion(region, animated: true)
            
            }) { (Bool) -> Void in
                pickerView.hidden = true
                self.animationIsOccuring = false
                
        }
        
    }
    
}