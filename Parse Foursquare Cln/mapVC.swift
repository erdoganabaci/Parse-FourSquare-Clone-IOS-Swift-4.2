//
//  mapVC.swift
//  Parse Foursquare Cln
//
//  Created by Erdo on 17.01.2019.
//  Copyright © 2019 Erdo. All rights reserved.
//

import UIKit
import MapKit
import Parse
class mapVC: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate{ //map delegate etmek için tanımlamaları yapıyoruz
    @IBOutlet weak var mapView: MKMapView!
    var manager = CLLocationManager() //locasyonlarla yapılacak tüm şlemlere olanak sağlıyor.
    var chosenLatitute = ""
    var chosenLongitute = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //kullanıcıının yerini en iyi göster pili çok yer
        manager.requestWhenInUseAuthorization() //sadece kullanırken kullanıcının lokasyonunu güncelle
        manager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapVC.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(recognizer )
        mapView.showsUserLocation = true
        //mapView.mapType = .hybrid
    }
    override func viewWillAppear(_ animated: Bool) {
        //her açılışta bir önceki koordinatı kaydetmesin güvenlik için
        self.chosenLatitute = ""
        self.chosenLongitute = ""
    }
    @objc func chooseLocation (gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            //o anki durumumla gelen tıklama aynımı yani tıkladığım yer mi orası diye ondan eşitlik yaptık
            let touches = gestureRecognizer.location(in: self.mapView) //haritadan al dokunduğum yeri
            let coordinates = self.mapView.convert(touches, toCoordinateFrom: self.mapView) //dokunduğum yeri koordinata çevir.
            let annotation = MKPointAnnotation() //harita pini oluşturma
            annotation.coordinate = coordinates
            annotation.title = globalName
            annotation.subtitle = globalType
            self.mapView.addAnnotation(annotation)
            self.chosenLatitute = String(coordinates.latitude)
            self.chosenLongitute = String(coordinates.longitude)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locasyonlar update edilince ne yapmamaız lazım onu söylüyoruz.
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) //böylece kullanıcının anlık locasyonunu aldık.
        manager.stopUpdatingLocation()
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //haritanın odağını ayarladık
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        
        
    }
    @IBAction func saveClicked(_ sender: Any) {
        let object = PFObject(className: "Places")
        object["name"] = globalName
        object["type"] = globalType
        object["atmosphere"] = globalAtmosphere
        object["latitute"] = self.chosenLatitute
        object["longitute"] = self.chosenLongitute
        if let imageData = globalImage.jpegData(compressionQuality: 0.5){
            object["image"] = PFFileObject(name: "image.jpg", data: imageData)
        }
        object.saveInBackground { (success, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
                let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else{ //hata yoksa table view götürdük
                self.performSegue(withIdentifier: "frommapVCtoplacesVC", sender: nil)
            }
        }
        
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil) //bir önceki navigatina geçmek için performsegue de olurdu
    }
}
