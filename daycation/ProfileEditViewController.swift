
import UIKit
import Eureka
import PKHUD

public class AvatarCell : Cell<UIImage>, CellType {
    
    public var addButton:UIButton?
   
    public override func update() {
        row.title = nil
        super.update()
        let value = row.value

    }
}

//MARK: WeekDayRow

public final class AvatarRow: Row<UIImage, AvatarCell>, RowType  {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<AvatarCell>()
    }
}

class ProfileEditViewController : FormViewController{
    var isCreating:Bool?
    public var completionCallback : ((UIViewController) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isCreating = OuterspatialClient.currentUser==nil
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.tableView!.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tableView!.separatorInset = UIEdgeInsetsZero
        self.tableView!.layoutMargins = UIEdgeInsetsZero
        self.tableView!.separatorColor = UIColor(hexString: "#fff9e1")
        if (self.isCreating == false)  {
            self.title = "PROFILE"
            let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "tappedCancel:")
            self.navigationItem.leftBarButtonItem = b
        } else {
            self.title = "MY ACCOUNT"
        }
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "tappedDone:")
        self.navigationItem.rightBarButtonItem = b
        ImageRow.defaultCellUpdate = { cell, row in
            
           // if let iView = cell.accessoryView as? UIImageView{
            let view = UIView(frame: CGRectMake(0, 0, 190, 44))
            let addLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 40, height: 40))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                let imageView = UIImageView(frame: CGRectMake(20, 0, 44, 44))
               // imageView.image = iView.image
                imageView.layer.borderWidth = 1
                imageView.layer.borderColor = UIColor(hexString: "#8e8e8e")?.CGColor
                imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
            

            label.textColor = UIColor(hexString: "#8e8e8e")
            label.font = UIFont(name: "Quicksand-Regular", size: 20)
            label.text = "Choose"
            label.fitSize()
            label.y = imageView.bottomOffset(10)
            view.addSubview(label)
            
            addLabel.textColor = UIColor(hexString: "#8e8e8e")
            addLabel.font = UIFont(name: "Quicksand-Regular", size: 20)
            addLabel.text = "Add a photo"
            addLabel.fitSize()
            addLabel.y = imageView.bottomOffset(10)
            view.addSubview(addLabel)
                view.addSubview(imageView)
                cell.accessoryView = view
                
           // }
        }
        form  +++=
            
            Section(footer: "") {
                $0.header = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
                let headerView = $0.header?.viewForSection($0, type: HeaderFooterType.Header, controller: self)  as! EurekaLogoView
                headerView.setTitle("REQUIRED INFO")
                      if (isCreating == false)  {
                    headerView.label.textColor = UIColor(hexString: "#f0bb52")
                    
                } else  {
                    headerView.label.textColor = UIColor(hexString: "#5dbedf")
                }
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
                if (isCreating == false)  {
                    headerView.label.textColor = UIColor(hexString: "#f0bb52")
                    
                } else  {
                    headerView.label.textColor = UIColor(hexString: "#5dbedf")
                }
                $0.footer = HeaderFooterView<EurekaLogoView>(HeaderFooterProvider.Class)
        }
            <<< AvatarRow("image"){
                $0.title = "Avatar"
                if let user = OuterspatialClient.currentUser  where (user.profile != nil && user.profile!.image != nil) {
                    $0.value=user.profile!.image
                }
            }
                .cellSetup() { cell, row in
                    cell.indentationLevel = Int(3)
                    cell.textLabel?.font = UIFont(name:"Quicksand-Bold", size:20)
                    self.formatCell(cell)
                    cell.textLabel?.sizeToFit()
                    cell.textLabel?.y = 0
                    cell.height =  {return CGFloat(150)}
                    cell.setup()
                    cell.selectionStyle = .None
                    self.formatCell(cell)
                    // if let iView = cell.accessoryView as? UIImageView{
                    let view = UIView(frame: CGRectMake(0, 0, 250, 44))
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))

                    let chooseAvatarButton = UIButton(type: UIButtonType.System)
                    //chooseAvatarButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
                    chooseAvatarButton.userInteractionEnabled = true
                    chooseAvatarButton.frame = CGRectMake(20, 0, 44, 44)
                    
                    chooseAvatarButton.layer.borderWidth = 1
                    chooseAvatarButton.layer.borderColor = UIColor(hexString: "#8e8e8e")?.CGColor
                    chooseAvatarButton.layer.cornerRadius = chooseAvatarButton.frame.height/2
                    chooseAvatarButton.clipsToBounds = true
                    chooseAvatarButton.addTarget(self, action: #selector(self.tappedAvatar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    
                    view.addSubview(chooseAvatarButton)
     
                    let addAvatarButton   = UIButton(type: UIButtonType.System) as UIButton
                    addAvatarButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
                    addAvatarButton.userInteractionEnabled = true
                    addAvatarButton.frame = CGRectMake(130, 0, 44, 44)
                    
                    view.addSubview(addAvatarButton)
                    
                    addAvatarButton.addTarget(self, action: #selector(self.tappedAvatar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    
                    label.textColor = UIColor(hexString: "#8e8e8e")
                    label.font = UIFont(name: "Quicksand-Regular", size: 20)
                    label.text = "Choose"
                    label.fitSize()
                    label.y = chooseAvatarButton.bottomOffset(10)
                    view.addSubview(label)
                    
                    let addLabel = UILabel(frame: CGRect(x: label.rightOffset(15), y: 0, width: 40, height: 40))
                    addLabel.textColor = UIColor(hexString: "#8e8e8e")
                    addLabel.font = UIFont(name: "Quicksand-Regular", size: 20)
                    addLabel.text = "Add a photo"
                    addLabel.fitSize()
                    addLabel.y = chooseAvatarButton.bottomOffset(10)
                    view.addSubview(addLabel)
                    
                    let orLabel = UILabel(frame: CGRect(x: chooseAvatarButton.rightOffset(15), y: 0, width: 40, height: 18))
                    orLabel.textColor = UIColor(hexString: "#8e8e8e")
                    orLabel.font = UIFont(name: "Quicksand-Regular", size: 20)
                    orLabel.text = "or"
                    orLabel.fitSize()
                    orLabel.x = addAvatarButton.right+((chooseAvatarButton.left-addAvatarButton.right)/2)-(orLabel.w/2)
                    orLabel.y = chooseAvatarButton.bottomOffset(-35)
                    view.addSubview(orLabel)
                  //  view.addSubview(imageView)
                    cell.accessoryView = view
                    
                    // }
                } .cellUpdate() {cell, row in
                    cell.textLabel?.textColor = UIColor(hexString: "#8e8e8e")
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#8e8e8e")
                    cell.textLabel?.alpha = 0.5
                     if let addButton = cell.accessoryView?.subviews[0] as? UIButton{
                        if let image = row.baseValue as? UIImage{
                        addButton.setImage(image.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
                        }

        }
                  
            }
            <<< OrganizationRow("organization") {
                $0.title = "Organization"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    $0.value = user.profile!.organization
                }
                
                }.cellSetup() {cell, row in
                    
                    self.formatCell(cell)
                    cell.indentationLevel = Int(3)
                } .cellUpdate() {cell, row in
                    cell.textLabel?.alpha = 0.5
                    cell.textLabel?.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel?.textColor = UIColor(hexString: "#8e8e8e")
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#8e8e8e")
                   
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
                    
                    cell.placeholderLabel.alpha = 0.5
                    cell.placeholderLabel.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.placeholderLabel.textColor = UIColor(hexString: "#8e8e8e")
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
    
    func tappedAvatar(sender: UIButton){
        var selectedImage:UIImage?
        if let avatarImage = self.form.rowByTag("image")?.baseValue  as? UIImage {
            selectedImage=avatarImage
        }else{
            selectedImage = nil
        }
        self.navigationController?.pushViewController(AvatarViewController({ image in
            self.form.rowByTag("image")?.baseValue = image
            self.form.rowByTag("image")?.reload()
            },avatarImage:selectedImage), animated: true)
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
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        let backgroundImage = UIImage(named:"DAYC_BLUE_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage,
                                                                    forBarMetrics: .Default)
       //  self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
      //  if let organization = form.rowByTag("organization")?.baseValue as? Organization where (form.rowByTag("organization") != nil && form.rowByTag("organization")?.baseValue != nil) {
       //     form.rowByTag("organization")!.title=organization.name
      //  }
    }
}