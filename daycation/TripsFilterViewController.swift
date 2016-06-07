
import UIKit
import Eureka
import PKHUD


class TripsFilterViewController : FormViewController{
    var isCreating:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isCreating = OuterspatialClient.currentUser==nil
        
        self.title = "Filter"
        
        self.view.backgroundColor = UIColor.whiteColor()
            let a = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "tappedCancel:")
            self.navigationItem.rightBarButtonItem = a
      
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        self.navigationItem.leftBarButtonItem = b
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRectMake(0, 0, 34, 34)
        }
        
        form  +++=
            
            Section("DAYCATION FEATURES")
            
            
            <<< FilterOptionsRow("species") {
                $0.title = "Related Species"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
            }
            
            <<< OrganizationRow("activities") {
                $0.title = "Related Activities"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
            }
            <<< SwitchRow("park") {
                $0.title = "Park"
            }
            <<< SwitchRow("trail") {
                $0.title = "Trail"
            }
            <<< SwitchRow("natural_area") {
                $0.title = "Natural Area"
            }
            <<< SwitchRow("body_of_water") {
                $0.title = "Body of Water"
            }
            <<< SwitchRow("business") {
                $0.title = "Business"
        }
            
            <<< OrganizationRow("difficulty") {
                $0.title = "Difficulty"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
        }
            
            <<< OrganizationRow("duration") {
                $0.title = "Duration"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
            }
            <<< OrganizationRow("best_time_to_go") {
                $0.title = "Best Time to Go"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
        }
            
            <<< OrganizationRow("suitable_for_kids") {
                $0.title = "Suitable for Kids"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
            }
            <<< SwitchRow("great_for_groups") {
                $0.title = "Great for Groups"
            }
            <<< SwitchRow("includes_food_and_beverage") {
                $0.title = "Includes Food and Beverage"
            }
            <<< SwitchRow("accessible") {
                $0.title = "Accessible"
        }
    }
    
    
    func tappedDone(sender: UIBarButtonItem){
        
        let profile:Profile = self.isCreating! == true ? Profile() : OuterspatialClient.currentUser!.profile!
        var valid:Bool = true
        if let firstName =  self.form.values()["first_name"] as? String {
            profile.firstName=firstName
        }else{
            valid = false
        }
        if let lastName = self.form.values()["last_name"]  as? String {
            profile.lastName=lastName
        }else{
            valid = false
        }
        if let location = self.form.values()["location"]  as? String {
            profile.location=location
        }
        if let bio = self.form.values()["bio"]  as? String {
            profile.bio=bio
        }
        if let organization = self.form.values()["organization"]  as? Organization {
            profile.organization=organization
        }
        if let image = self.form.values()["image"]  as? UIImage {
            if profile.image==image {
                profile.image=nil
            }else {
                profile.image=image
            }
        }
        
        HUD.show(.Progress)
        if (self.isCreating == true)  {
            let user:User = User()
            user.profile = profile
            
            if let email = self.form.values()["email"]  as? String {
                user.email = email
            }else{
                valid = false
            }
            if let password = self.form.values()["password"]  as? String {
                user.password = password
            }else{
                valid = false
            }
            if !valid {
                HUD.flash(.Label("Fix the errors 😃"), delay: 2.0)
                return
            }
            
            HUD.show(.Progress)
            OuterspatialClient.sharedInstance.createUser(user){
                (result: User?,error: String?) in
                print("got back: \(result)")
                if let user = result {
                    OuterspatialClient.sharedInstance.loginWithEmailAndPassword(user.email!, password: user.password!) {
                        (result: User?,error: String?) in
                        if let user = result {
                            print("got back: \(user)")
                            HUD.hide(afterDelay: 0)
                            let loggedInViewController = LoggedInViewController()
                            self.navigationController?.pushViewController(loggedInViewController, animated: true)
                        }
                        if let error = error{
                            HUD.flash(.Label(error), delay: 2.0)
                        }
                        
                    }
                }
                
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
        }else{
            
            if !valid {
                HUD.flash(.Label("Fix the errors 😃"), delay: 2.0)
                return
            }
            OuterspatialClient.sharedInstance.updateProfile(profile) {
                (result: Profile) in
                print("got back: \(result)")
                HUD.hide(afterDelay: 0)
                OuterspatialClient.currentUser!.profile=result
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
        
    }
    
    
    func tappedCancel(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
}