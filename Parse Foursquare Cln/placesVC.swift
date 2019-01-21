//
//  placesVC.swift
//  Parse Foursquare Cln
//
//  Created by Erdo on 17.01.2019.
//  Copyright © 2019 Erdo. All rights reserved.
//

import UIKit
import Parse
class placesVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
   
    var chosenPlace = ""  //tableview den secilen yeri bu değişkene kayıt edip detail vcye aktarıyoz
    var placeNameArray = [String]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    func getData(){
        let query = PFQuery(className: "Places") //database ismi
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
                let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }else{
                self.placeNameArray.removeAll(keepingCapacity: false) //başka bir veri arrayde varsa kurtulmak için
                //error yoksa for döngüsüne ekle isimleri
                for object in objects! {
                    self.placeNameArray.append(object.object(forKey: "name") as! String)
                    
                }
                self.tableView.reloadData() //table viewi güncelle
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromplacesVCtodetailsVC" {
            let destinationVC = segue.destination as! detailsVC
            destinationVC.selectedPlace = self.chosenPlace //tableviewda seçilen ismi detailvc selectedplace aktardık
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenPlace = placeNameArray[indexPath.row]
        self.performSegue(withIdentifier: "fromplacesVCtodetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeNameArray[indexPath.row] //arrayde hangi veri varsa göstercez
        return cell
    }
    @IBAction func logoutClicked(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userLoggedIn")
        UserDefaults.standard.synchronize()
        //önce userdafulta kaydettiğmiz objeyi silip başa döüp sigınvc ye döncez
        let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! signInVC
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = signInVC
        //delegate.rememberLogIn()
        
    }
    @IBAction func addClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "fromplacesVCtoimageVC", sender: nil)
        
    }
}
