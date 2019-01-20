//
//  ViewController.swift
//  Parse Foursquare Cln
//
//  Created by Erdo on 17.01.2019.
//  Copyright © 2019 Erdo. All rights reserved.
//

import UIKit
import Parse

class signInVC: UIViewController {

    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

     
    }

    @IBAction func signInClicked(_ sender: Any) {
        if usernameText.text != "" && passwordText.text != ""{
            PFUser.logInWithUsername(inBackground: usernameText.text!, password: passwordText.text!) { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    UserDefaults.standard.set(self.usernameText.text, forKey: "userLoggedIn") //buranın içine koyduğum değerin bir önemi yok herhangi birşey kayıt edip appdelegate remember user ile o değer varsa açılış ekranını değiştiririz.
                    UserDefaults.standard.synchronize()
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogIn()
                    
                    
                }
            }
            
        }else {
            let alert = UIAlertController(title: "Error", message: "Username or Password Needed!", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        }
            
        
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        if usernameText.text != "" && passwordText.text != "" {
            let user = PFUser() //parse user objesi oluşturduk
            user.username = usernameText.text
            user.password = passwordText.text
            user.signUpInBackground { (success, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert   )
                    let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else{ //kullanıcı yaratıldığında da diğer uygulamaya geçsin diye perform segue ile de olur.
                    UserDefaults.standard.set(self.usernameText.text, forKey: "userLoggedIn") //buranın içine koyduğum değerin bir önemi yok herhangi birşey kayıt edip appdelegate remember user ile o değer varsa açılış ekranını değiştiririz.
                    UserDefaults.standard.synchronize()
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogIn()
                }
            }
        
        }else {
            let alert = UIAlertController(title: "Error", message: "Username or Password Needed!", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}
       

/*
 if usernameText.text != "" && passwordText.text != ""{
 let user = PFUser() //parse user objesi oluşturduk
 user.username = usernameText.text
 user.password = passwordText.text
 user.signUpInBackground { (success, error) in
 if error != nil {
 let alert = UIAlertController(title: "Error", message: "Username or Password Needed!", preferredStyle: UIAlertController.Style.alert)
 let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
 alert.addAction(okButton)
 self.present(alert, animated: true, completion: nil)
 
 }else{
 
 }
 
 
 }} else{
 let alert = UIAlertController(title: "Error", message: "Username or Password Needed!", preferredStyle: UIAlertController.Style.alert)
 let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
 alert.addAction(okButton)
 self.present(alert, animated: true, completion: nil)
 }
 
 */


/*
 let object = PFObject(className: "Musician")
 object["name"] = "James"
 object["age"] = 50
 object["instrument"] = "Guitar"
 object.saveInBackground { (succes, error) in
 if error != nil {
 print("Sunucu Değer Okuma Hatası \(error)")
 }else{
 print("Succesfull")
 }
 }
 */
