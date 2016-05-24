
import UIKit
import Eureka
import PKHUD


class ProfileEditViewController : FormViewController{
    var isCreating:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isCreating = OuterspatialClient.currentUser==nil
        
        self.title = "Profile"
        self.tableView!.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tableView!.separatorInset = UIEdgeInsetsZero
        self.tableView!.layoutMargins = UIEdgeInsetsZero
        self.tableView!.separatorColor = UIColor(hexString: "#fff9e1")
        if (self.isCreating == false)  {
            let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "tappedCancel:")
            self.navigationItem.leftBarButtonItem = b
        }
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "tappedDone:")
        self.navigationItem.rightBarButtonItem = b
        ImageRow.defaultCellUpdate = { cell, row in
            
            if let iView = cell.accessoryView as? UIImageView{
                let view = UIView(frame: CGRectMake(0, 0, 90, 44))
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                let imageView = UIImageView(frame: CGRectMake(20, 0, 44, 44))
                imageView.image = iView.image
                imageView.layer.borderWidth = 1
                imageView.layer.borderColor = UIColor(hexString: "#8e8e8e")?.CGColor
                imageView.layer.cornerRadius = imageView.frame.height/2
                imageView.clipsToBounds = true
                label.textColor = UIColor(hexString: "#8e8e8e")
                label.font = UIFont(name: "Quicksand-Regular", size: 20)
                label.text = "Change"
                
                label.fitSize()
                label.y = imageView.bottomOffset(10)
                view.addSubview(imageView)
                view.addSubview(label)
                cell.accessoryView = view
                
            }
        }
        form  +++=
            
            Section(footer: "") {
                $0.header = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
                let headerView = $0.header?.viewForSection($0, type: HeaderFooterType.Header, controller: self)  as! EurekaLogoView
                headerView.setTitle("REQUIRED INFO")
                $0.footer = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
                let FooterView = $0.header?.viewForSection($0, type: HeaderFooterType.Footer, controller: self)  as! EurekaLogoView
                
                let separatorImage=UIImageView(frame: CGRectMake( 0, 25, self.view.frame.size.width, 5))
                separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
                separatorImage.clipsToBounds = true
                separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
                FooterView.addSubview(separatorImage)
        }
            <<< NameRow("first_name") {
                $0.placeholder = "First Name"
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.firstName != nil) {
                    $0.value=user.profile!.firstName
                }
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textField.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textField.textColor = UIColor(hexString: "#8e8e8e")
            }

            <<< NameRow("last_name") {
                $0.placeholder = "Last Name"
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.lastName != nil) {
                    $0.value=user.profile!.lastName
                }
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textField.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textField.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< EmailRow("email") {
                $0.placeholder = "Email"
                if (self.isCreating == false)  {
                    $0.value=OuterspatialClient.currentUser!.email
                    $0.disabled=true
                }
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textField.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textField.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< PasswordRow("password") {
                $0.placeholder = "Password"
                if (self.isCreating == false)  {
                    $0.hidden=true
                }
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textField.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textField.textColor = UIColor(hexString: "#8e8e8e")
        }
        form  +++=
            
            Section(footer: "") {
                $0.header = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
                let headerView = $0.header?.viewForSection($0, type: HeaderFooterType.Header, controller: self)  as! EurekaLogoView
                headerView.setTitle("MORE ABOUT YOU")
                $0.footer = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
        }
            <<< ImageRow("image"){
                $0.title = "Avatar"
                if let user = OuterspatialClient.currentUser  where (user.profile != nil && user.profile!.image != nil) {
                    $0.value=user.profile!.image
                }
                }.cellSetup() {cell, row in
                    cell.height =  {return CGFloat(150)}
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.indentationLevel = Int(3)
                    cell.textLabel?.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel?.textColor = UIColor(hexString: "#8e8e8e")
                    self.formatCell(cell)
                    cell.textLabel?.sizeToFit()
                    cell.textLabel?.y = 0
                    

            }
            
            <<< LoctionRow("organization") {
                $0.title = "Organization"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
                }.cellSetup() {cell, row in
                    
                    self.formatCell(cell)
                    cell.indentationLevel = Int(3)
                } .cellUpdate() {cell, row in
                    cell.textLabel?.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel?.textColor = UIColor(hexString: "#8e8e8e")
                    self.formatCell(cell)
            }
            
            <<< TextRow("location") {
                $0.placeholder = "Location"
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.location != nil) {
                    $0.value=user.profile!.location
                }
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textField.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textField.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< TextAreaRow("bio") {
                $0.placeholder = "Your connection to nature"
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.bio != nil) {
                    $0.value=user.profile!.bio
                }
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                    cell.textView.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textView.textColor = UIColor(hexString: "#8e8e8e")
                    cell.textView.backgroundColor = UIColor(hexString: "#f7f1da")
        }
                .cellUpdate() {cell, row in
                    cell.textView.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textView.textColor = UIColor(hexString: "#8e8e8e")
        }
    }
    
    func formatCell(cell:BaseCell){
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.contentView.layoutMargins.left = 30
        cell.backgroundColor = UIColor(hexString: "#f7f1da")
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
                            if self.isCreating == true {
                                self.presentViewController(loggedInViewController, animated: true, completion: nil)
                            } else {
                                self.navigationController?.pushViewController(loggedInViewController, animated: true)
                            }
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
    
    
    override func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath)
    {
        guard tableView == self.tableView else { return }
        form[indexPath].updateCell()
        cell.textLabel?.frame = CGRectMake(0,
                                      0,
                                      cell.frame.size.width,
                                      20)
        let additionalSeparatorThickness = CGFloat(3)
        let additionalSeparator = UIView(frame: CGRectMake(0,
            cell.frame.size.height - additionalSeparatorThickness,
            cell.frame.size.width,
            additionalSeparatorThickness))
        additionalSeparator.backgroundColor = UIColor(hexString: "#fff9e1")
        cell.addSubview(additionalSeparator)
    }
    class EurekaLogoView: UIView {
        var label:UILabel!
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor(hexString: "#fff9e1")
            self.frame = CGRect(x: 0, y: 0, width: 320, height: 30)
            label = UILabel(frame: CGRect(x: 30, y: 5, width: 40, height: 40))
            label.textColor = UIColor(hexString: "#f0bb52")
            label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 20)
            
            self.addSubview(label)
        }
        func setTitle(title: String) {
            label.text = title
            label.sizeToFit()
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func tappedCancel(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
        if let organization = form.rowByTag("organization")?.baseValue as? Organization where (form.rowByTag("organization") != nil && form.rowByTag("organization")?.baseValue != nil) {
            form.rowByTag("organization")!.title=organization.name
        }
    }
}