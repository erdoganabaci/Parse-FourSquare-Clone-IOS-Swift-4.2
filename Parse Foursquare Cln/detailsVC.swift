
//
//  detailsVC.swift
//  Parse Foursquare Cln
//
//  Created by Erdo on 17.01.2019.
//  Copyright © 2019 Erdo. All rights reserved.
//

import UIKit
import Parse
import MapKit
class detailsVC: UIViewController ,MKMapViewDelegate ,CLLocationManagerDelegate{ //haritayı kullanmak için delegete ediyoruz.
    
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeAtmosphereLabel: UILabel!
    var selectedPlace = ""
    var chosenLatitute = ""
    var chosenLongitute = ""
    //parsedan çekilcek veriler için arraylere eklicez
    
    var nameArray = [String]()
    var typeArray = [String]()
    var atmosphereArray = [String]()
    var latituteArray = [String]()
    var longituteArray = [String]()
    var imageArray = [PFFileObject]()
    
    var manager = CLLocationManager()
    var requestCLlocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        //manager.startUpdatingLocation() //ilk açılışta değilde veriler varken update etsin ki verileri göstersin
        findPlaceFromServer()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //selectedLocation dan gelen isimleri  bu isimlerin parse  daki karşılıklarını çekip kullanıcıya yeri ismini atmosferini ve resmini göstercez
        if self.chosenLatitute != "" && self.chosenLongitute != "" {
            let location = CLLocationCoordinate2D(latitude: Double(self.chosenLatitute)!, longitude: Double(self.chosenLongitute)!)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: true)
            manager.stopUpdatingLocation()
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = self.nameArray.last!
            annotation.subtitle = self.typeArray.last!
            self.mapView.addAnnotation(annotation)
            
        }
    }
   /*
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       
            if let annotationTitle = view.annotation?.title
            {
                print("Dokandın: \(annotationTitle!)")
            }
        
    }
     */
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //fonksiyonu override ediyruz ve harita pinlerini özelleştirebiliyoruz.
        if annotation is MKUserLocation { //lokasyonla ilgili anatasyonsa hiçbirşey yapma.
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true //yanına buton eklenebilir mi evet diyoruz
            let button = UIButton(type: .detailDisclosure)
            //let button1 = UIButton(type: .infoLight)
            pinView?.rightCalloutAccessoryView = button
            //pinView?.leftCalloutAccessoryView = button1
            
        }else{
            pinView?.annotation = annotation //böylece pinviewı customize ettik.
        }
        
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //pinlerin butonuna tıklayınca navigasyona yollucaz
        if self.chosenLatitute != "" && self.chosenLongitute != ""{
            self.requestCLlocation = CLLocation(latitude: Double(self.chosenLatitute)!, longitude: Double(self.chosenLongitute)!)
            CLGeocoder().reverseGeocodeLocation(requestCLlocation) { (placemarks, error) in
                if let placemark = placemarks{
                    if placemark.count > 0 { //diziden adres alabildiysem
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.nameArray[0] as! String
                        //navigyonu kullandığım kısım
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    
    func findPlaceFromServer(){
        let query = PFQuery(className: "Places")
        query.whereKey("name", equalTo: self.selectedPlace) //parsedaki name ile placesVC gelen tabloya tıklanılan isimler eşitse onunla ilgili dataları getir.
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
                let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else{
                self.nameArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.atmosphereArray.removeAll(keepingCapacity: false)
                self.imageArray.removeAll(keepingCapacity: false)
                self.latituteArray.removeAll(keepingCapacity: false)
                self.longituteArray.removeAll(keepingCapacity: false)
                
                for object in objects!{
                    self.nameArray.append(object.object(forKey: "name") as! String )
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.atmosphereArray.append(object.object(forKey: "atmosphere") as! String)
                    self.imageArray.append(object.object(forKey: "image") as! PFFileObject)
                    self.latituteArray.append(object.object(forKey: "latitute") as! String )
                    self.longituteArray.append(object.object(forKey: "longitute") as! String)
                    self.manager.startUpdatingLocation() //ilk açılışta update ediyor onun için veriler varken update etsin

                    self.placeName.text = "Name: \(self.nameArray.last!)"
                    self.placeTypeLabel.text = "Type: \(self.typeArray.last!)"
                    self.placeAtmosphereLabel.text = "Atmosphere: \(self.atmosphereArray.last!)"
                    self.chosenLatitute = self.latituteArray.last! //mapkitte gösterebilmek için başka değişkene atadık.Location managerda işimize yarıcaktı ondan.
                    self.chosenLongitute = self.longituteArray.last!
                    self.imageArray.last?.getDataInBackground(block: { (data, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
                            let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        }else{
                            self.placeImage.image = UIImage(data: data!)
                        }
                    })
                }
            }
        }
    }
    
}
