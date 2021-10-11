//
//  ViewController.swift
//  GoogleAPI
//
//  Created by UmarFarooq on 02/06/2021.
//  Copyright © 2021 UmarFarooq. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


class ViewController: UIViewController {

    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        drawGoogleApiDirection()
        self.getTotalDistance()
    }
    
    func drawGoogleApiDirection(){
        //google direction api
        
        let origin = "\(24.871941),\(66.988060)"
        let destination = "\(24.885950),\(67.026744)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(googleApiKey)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                
                DispatchQueue.main.async {
                    self.mapView.clear()
                    self.addSourceDestinationMarkers()
                    
                }
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    
                    //self.mapView.clear()
                    
                    
                    OperationQueue.main.addOperation({
                        for route in routes {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let path = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = UIColor(red: 50/255, green: 165/255, blue: 102/255, alpha: 1.0)
                            
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            
                            polyline.map = self.mapView
                            
                        }
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
    }
    
    func addSourceDestinationMarkers(){
        let markerSource = GMSMarker()
        //markerSource.position = CLLocationCoordinate2D(latitude: 24.9216774, longitude: 67.0914983)
        markerSource.position = CLLocationCoordinate2D(latitude: 24.871941, longitude: 66.988060)
        markerSource.icon = UIImage(named: "markera")
        markerSource.title = "Point A"
        //markerSource.snippet = "Desti"
        
        markerSource.map = mapView
        
        let markertDestination = GMSMarker()
        //markertDestination.position = CLLocationCoordinate2D(latitude: 24.9623483, longitude: 67.0463966)
        markertDestination.position = CLLocationCoordinate2D(latitude: 24.885950, longitude: 67.026744)
        markertDestination.icon = UIImage(named: "markerb")
        markertDestination.title = "Point B"
        //markertDestination.snippet = "General Store"
        markertDestination.map = mapView
    }
    
    func getTotalDistance(){
        
        //distance api matrix
        let origin = "\(24.871941),\(66.988060)"
        let destination = "\(24.885950),\(67.026744)"

        let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(origin)&destinations=\(destination)&units=imperial&mode=driving&language=en-EN&sensor=false&key=\(googleApiKey)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
                //showToast(viewControl: self, titleMsg: "", msgTitle: "The Internet connection appears to be offline.")
            }else{
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let rows = json["rows"] as! NSArray
                    print(rows)
                    
                    let dic = rows[0] as! Dictionary<String, Any>
                    let elements = dic["elements"] as! NSArray
                    let dis = elements[0] as! Dictionary<String, Any>
                    let distanceMiles = dis["distance"] as! Dictionary<String, Any>
                    let miles = distanceMiles["text"]! as! String
                    
                    let TimeRide = dis["duration"] as! Dictionary<String, Any>
                    let finalTime = TimeRide["text"]! as! String
                    
                    DispatchQueue.main.async {
                        self.lblDistance.text = "Total Distance = \(miles)"//.replacingOccurrences(of: " mi", with: "")
                        self.lblTime.text = "Total Ride Time = \(finalTime)"
                        print("\(String(describing: self.lblDistance.text))")
                    }
                    
                    
                    
                    
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
        
        
    }


}

