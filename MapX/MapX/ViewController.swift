//
//  ViewController.swift
//  MapX
//
//  Created by Kabir Swain on 2/12/20.
//  Copyright © 2020 Kabir Swain. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import JJFloatingActionButton


class ViewController: UIViewController, MGLMapViewDelegate {
    
    /*
    private var world: MGLCoordinateBounds!
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/kabirswain/ck6li1ss508h81im3yv5d1ykf")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 37.4275, longitude: -122.1697), zoomLevel: 7, animated: false)
        mapView.delegate = self
        
        view.addSubview(mapView)
        
        // Remove MapBox Attributions
        mapView.attributionButton.alpha = 0
        mapView.logoView.alpha = 0
        
        // Allow the map view to display the user's location
        mapView.showsUserLocation = true
        
        
        /* World bounds
        let northeast = CLLocationCoordinate2D(latitude: 80, longitude: 190)
        let southwest = CLLocationCoordinate2D(latitude: -80, longitude: -169)
        world = MGLCoordinateBounds(sw: southwest, ne: northeast)
        */
        
        
        // Floating button
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = .black

        actionButton.addItem(title: "Settings", image: UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)) { item in
          // do something
            
            /* Adding Globe View
            super.viewDidLoad()
            let mapFlyover = MKMapView(frame: self.view.bounds)
            mapFlyover.mapType = MKMapType.satelliteFlyover
            self.view.addSubview(mapFlyover)
            */
        
        }
        actionButton.addItem(title: "Layers", image: UIImage(named: "layers")?.withRenderingMode(.alwaysTemplate)) { item in
          // do something
        }
        actionButton.addItem(title: "Satellites", image: UIImage(named: "satellite")?.withRenderingMode(.alwaysTemplate)) { item in
          // do something
        }

        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        
        // Default Action Button apperance
        actionButton.configureDefaultItem { item in

            item.titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
            item.titleLabel.textColor = .white
            item.buttonColor = .black
            item.buttonImageColor = .white

            item.layer.shadowColor = UIColor.black.cgColor
            item.layer.shadowOffset = CGSize(width: 0, height: 1)
            item.layer.shadowOpacity = Float(0.4)
            item.layer.shadowRadius = CGFloat(2)
        }
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
    // Wait for the map to load before initiating the first camera movement.
     
    // Create a camera that rotates around the same center point, rotating 180°.
    // `fromDistance:` is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
    let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, altitude: 300000, pitch: 15, heading: 0)
     
    // Animate the camera movement over 5 seconds.
    mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    /*
    // This example uses worlds boundaries to restrict the camera movement.
    func mapView(_ mapView: MGLMapView, shouldChangeFrom oldCamera: MGLMapCamera, to newCamera: MGLMapCamera) -> Bool {
     
    // Get the current camera to restore it after.
    let currentCamera = mapView.camera
     
    // From the new camera obtain the center to test if it’s inside the boundaries.
    let newCameraCenter = newCamera.centerCoordinate
     
    // Set the map’s visible bounds to newCamera.
    mapView.camera = newCamera
    let newVisibleCoordinates = mapView.visibleCoordinateBounds
     
    // Revert the camera.
    mapView.camera = currentCamera
     
    // Test if the newCameraCenter and newVisibleCoordinates are inside self.colorado.
    let inside = MGLCoordinateInCoordinateBounds(newCameraCenter, self.world)
    let intersects = MGLCoordinateInCoordinateBounds(newVisibleCoordinates.ne, self.world) && MGLCoordinateInCoordinateBounds(newVisibleCoordinates.sw, self.world)
     
    return inside && intersects
    }
    */
    
    // Heat Map Function
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    // Parse GeoJSON data. This example uses all M1.0+ earthquakes from 12/22/15 to 1/21/16 as logged by USGS' Earthquake hazards program.
    guard let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson") else { return }
    let source = MGLShapeSource(identifier: "earthquakes", url: url, options: nil)
    style.addSource(source)
     
    // Create a heatmap layer.
    let heatmapLayer = MGLHeatmapStyleLayer(identifier: "earthquakes", source: source)
     
    // Adjust the color of the heatmap based on the point density.
    let colorDictionary: [NSNumber: UIColor] = [
    0.0: .clear,
    0.01: .white,
    0.15: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0),
    0.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
    1: .yellow
    ]
    heatmapLayer.heatmapColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($heatmapDensity, 'linear', nil, %@)", colorDictionary)
     
    // Heatmap weight measures how much a single data point impacts the layer's appearance.
    heatmapLayer.heatmapWeight = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)",
    [0: 0,
    6: 1])
     
    // Heatmap intensity multiplies the heatmap weight based on zoom level.
    heatmapLayer.heatmapIntensity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
    [0: 1,
    9: 3])
    heatmapLayer.heatmapRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
    [0: 4,
    9: 30])
     
    // The heatmap layer should be visible up to zoom level 9.
    heatmapLayer.heatmapOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0.75, %@)", [0: 0.75, 9: 0])
    style.addLayer(heatmapLayer)
     
    // Add a circle layer to represent the earthquakes at higher zoom levels.
    let circleLayer = MGLCircleStyleLayer(identifier: "circle-layer", source: source)
     
    let magnitudeDictionary: [NSNumber: UIColor] = [
    0: .white,
    0.5: .yellow,
    2.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
    5: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0)
    ]
    circleLayer.circleColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)", magnitudeDictionary)
     
    // The heatmap layer will have an opacity of 0.75 up to zoom level 9, when the opacity becomes 0.
    circleLayer.circleOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0, %@)", [0: 0, 9: 0.75])
    circleLayer.circleRadius = NSExpression(forConstantValue: 20)
    style.addLayer(circleLayer)
    }
    
    


}

