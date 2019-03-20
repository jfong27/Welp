//
//  CompassVC.swift
//  Welp
//
//  Created by Jason Fong on 3/19/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class CompassVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let locationManager = CLLocationManager()
    var locPassed : CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currLoc: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        guard let currHeading = manager.heading?.trueHeading else { return }
        
        let angle = doComputeAngleBetweenMapPoints(fromHeading: currHeading, currLoc, locPassed!)
        
        UIView.animate(withDuration: 0.5) {
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        }
        
    }
    

    private func getBearing(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var radiansBearing = atan2(y, x)
        if radiansBearing < 0 {
            radiansBearing += 2 * Double.pi
        }
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
    private func doComputeAngleBetweenMapPoints(
        fromHeading: CLLocationDirection,
        _ fromPoint: CLLocationCoordinate2D,
        _ toPoint: CLLocationCoordinate2D
        ) -> CLLocationDirection {
        let bearing = getBearing(point1: fromPoint, point2: toPoint)
        var theta = bearing - fromHeading
        if theta < 0 {
            theta += 360
        }
        return theta
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    @IBAction func doneButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
