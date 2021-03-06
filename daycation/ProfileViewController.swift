import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD
import Foundation
import Haneke


class ProfileViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var profileImageView:UIImageView?
    var selectedButton:UIButton?
    var likesTableView: UITableView!
    var streamTableView: UITableView!
    var tripTableView: UITableView!
    var selectedTableView: UITableView!
    var likeTrips = [Trip]()
    var trips = [Trip]()
    var posts = [Post]()
    var page = 1
    var scrollView: UIScrollView!
    var contentView: UIView!
    var backgroundView: UIView!
    var nameLabel: UILabel!
    var bioLabel: UILabel!
    var organizationLabel: UILabel!
    var locationLabel: UILabel!
    var createdLabel: UILabel!
    var streamactInd : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Me"
        
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "tappedEdit:")
        b.title = "Edit"
        b.setTitlePositionAdjustment(UIOffset.init(horizontal: -15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        let a = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action:"tappedDone:")
        a.setTitlePositionAdjustment(UIOffset.init(horizontal: 15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        
        self.navigationItem.leftBarButtonItem = a
        self.navigationItem.rightBarButtonItem = b
        
        scrollView = UIScrollView()
        scrollView.userInteractionEnabled = true
        self.view.addSubview(scrollView)
        scrollView.snp_makeConstraints {make in
            make.edges.equalTo(view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        contentView = UIView(frame: CGRectMake(0, 0, 180, 3000))
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")
        contentView.userInteractionEnabled = true
        scrollView.addSubview(contentView)
        
        self.profileImageView=UIImageView(frame: CGRectMake(20, 20, 100, 100))
        self.profileImageView!.layer.borderWidth = 1
        self.profileImageView!.layer.masksToBounds = false
        self.profileImageView!.layer.borderColor = UIColor.blackColor().CGColor
        self.profileImageView!.layer.cornerRadius = self.profileImageView!.frame.height/2
        self.profileImageView!.clipsToBounds = true
        self.contentView.addSubview(profileImageView!)
        
        
        nameLabel = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:25, width:self.view.w-profileImageView!.rightOffset(5)-5, height:10))
        nameLabel.font = UIFont(name: "Quicksand-Bold", size: 14)
        nameLabel.textColor = UIColor(hexString: "#e09b1b")
        nameLabel.numberOfLines = 1
        nameLabel.text=OuterspatialClient.currentUser!.profile?.abbreviatedName
        nameLabel.fitHeight()
        self.contentView.addSubview(nameLabel)
        
        
        if let organization = OuterspatialClient.currentUser!.profile?.organization?.name {
            organizationLabel = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:nameLabel.bottomOffset(5), width:self.view.w-profileImageView!.rightOffset(5)-5, height:10))
            organizationLabel.font = UIFont(name: "Quicksand-Bold", size: 12)
            organizationLabel.textColor = UIColor(hexString: "#504f4f")
            organizationLabel.numberOfLines = 1
            organizationLabel.text=organization.uppercaseString
            organizationLabel.fitHeight()
            self.contentView.addSubview(organizationLabel)
        }
        
        if let location = OuterspatialClient.currentUser!.profile?.location {
            locationLabel = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:nameLabel.bottomOffset(35), width:self.view.w-profileImageView!.rightOffset(5)-5, height:10))
            locationLabel.font = UIFont(name: "Quicksand-Bold", size: 12)
            locationLabel.textColor = UIColor(hexString: "#504f4f")
            locationLabel.numberOfLines = 1
            locationLabel.text=location
            locationLabel.fitHeight()
            self.contentView.addSubview(locationLabel)
        }
        
        if let created = OuterspatialClient.currentUser!.createdAt {
            createdLabel = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:nameLabel.bottomOffset(50), width:self.view.w-profileImageView!.rightOffset(5)-5, height:10))
            createdLabel.font = UIFont(name: "Quicksand-Regular", size: 12)
            createdLabel.textColor = UIColor(hexString: "#504f4f")
            createdLabel.numberOfLines = 1
            let dayTimePeriodFormatter = NSDateFormatter()
            dayTimePeriodFormatter.dateFormat = "M/yyyy"
            
            let dateString = dayTimePeriodFormatter.stringFromDate(created)
            createdLabel.text=("User since \(dateString)")
            createdLabel.fitHeight()
            self.contentView.addSubview(createdLabel)
        }
        
        self.bioLabel=UILabel(frame: CGRectMake(20, self.profileImageView!.bottomOffset(20), self.view.w-40, 100))
        bioLabel.font = UIFont(name: "Quicksand-Regular", size: 12)
        bioLabel.textColor = UIColor(hexString: "#504f4f")
        bioLabel.text=OuterspatialClient.currentUser!.profile?.bio
        bioLabel.numberOfLines = 1000
        bioLabel.fitHeight()
        self.contentView.addSubview(bioLabel!)
        
        
        let separatorImage=UIImageView(frame: CGRectMake( 0, bioLabel.bottomOffset(5), self.view.frame.size.width, 5))
        separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        separatorImage.clipsToBounds = true
        separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(separatorImage)
        
        let button   = UIButton(type: UIButtonType.Custom) as UIButton
        button.setTitle("LIKED", forState: .Normal)
        button.frame = CGRectMake(20,separatorImage.bottomOffset(5), 80, 60)
        
        button.backgroundColor = UIColor(patternImage:UIImage(named:"likedbar")!)
        button.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        button.titleLabel!.font = UIFont(name:"Quicksand-Bold", size:14)!
        button.tag = 1
        self.contentView.addSubview(button)
        selectedButton = button
        
        let daybutton   = UIButton(type: UIButtonType.Custom) as UIButton
        daybutton.setTitle("DAYCATIONS", forState: .Normal)
        daybutton.frame = CGRectMake(button.right, separatorImage.bottomOffset(25), self.view.w-220, 40)
        daybutton.backgroundColor = UIColor(patternImage:UIImage(named: "daycationbar")!)
        daybutton.titleLabel!.font = UIFont(name:"Quicksand-Bold", size:14)!
        daybutton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        daybutton.tag = 2
        self.contentView.addSubview(daybutton)
        
        let streambutton   = UIButton(type: UIButtonType.Custom) as UIButton
        streambutton.setTitle("STREAM", forState: .Normal)
        streambutton.frame = CGRectMake(daybutton.right, separatorImage.bottomOffset(25), 100, 40)
        streambutton.backgroundColor = UIColor(patternImage:UIImage(named: "streambar")!)
        streambutton.titleLabel!.font = UIFont(name:"Quicksand-Bold", size:14)!
        streambutton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        streambutton.tag = 3
        self.contentView.addSubview(streambutton)
        
        
        backgroundView = UIView(frame: CGRectMake(0, daybutton.bottom, self.view.frame.size.width, 100))
        backgroundView.backgroundColor = UIColor(patternImage:UIImage(named: "likedbar")!)
        self.contentView.addSubview(backgroundView!)
        
        
        likesTableView = UITableView(frame: CGRectMake(10,streambutton.bottomOffset(10), self.view.frame.size.width-20, 80))
        likesTableView.dataSource = self
        likesTableView.delegate = self
        likesTableView.alwaysBounceVertical = false
        likesTableView.scrollEnabled = false
        likesTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        likesTableView.separatorInset = UIEdgeInsetsZero
        likesTableView.backgroundColor = UIColor(hexString: "#fff9e1")
        self.likesTableView.registerClass(TripsViewCell.self, forCellReuseIdentifier: "tripCell")
        likesTableView.layer.borderColor = UIColor(patternImage:UIImage(named: "likedbar")!).CGColor
        selectedTableView = likesTableView
        //tableView.layer.borderWidth = 10
        
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(likesTableView.w/2-25,likesTableView.h/2-25, 50, 50)) as UIActivityIndicatorView
        
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
     //  actInd.startAnimating()
        self.likesTableView.addSubview(actInd)
        self.contentView.addSubview(self.likesTableView)
        
        contentView.snp_makeConstraints {make in
            make.bottom.equalTo(likesTableView.snp_bottom);
            make.width.equalTo(self.view.frame.size.width);
            
            make.top.equalTo(0);
        }
        
        streamTableView = UITableView(frame: CGRectMake(10,streambutton.bottomOffset(10), self.view.frame.size.width-20, 80))
        streamTableView.dataSource = self
        streamTableView.delegate = self
        streamTableView.alwaysBounceVertical = false
        streamTableView.scrollEnabled = false
        streamTableView.hidden = true
        streamTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        streamTableView.separatorInset = UIEdgeInsetsZero
        streamTableView.backgroundColor = UIColor(hexString: "#fff9e1")
        self.streamTableView.registerClass(PostsViewCell.self, forCellReuseIdentifier: "PostCell")
        streamTableView.layer.borderColor = UIColor(patternImage:UIImage(named: "Daycation_daycations_bar.png")!).CGColor
        
     
        
        streamactInd = UIActivityIndicatorView(frame: CGRectMake(likesTableView.w/2-25,likesTableView.h/2-25, 50, 50)) as UIActivityIndicatorView
        streamactInd.hidesWhenStopped = true
        streamactInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
      //  streamactInd.startAnimating()
     //   self.streamTableView.addSubview(actInd)
        self.contentView.addSubview(self.streamTableView)
        
        
        tripTableView = UITableView(frame: CGRectMake(10,streambutton.bottomOffset(10), self.view.frame.size.width-20, 80))
        tripTableView.dataSource = self
        tripTableView.delegate = self
        tripTableView.alwaysBounceVertical = false
        tripTableView.scrollEnabled = false
        tripTableView.hidden = true
        tripTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tripTableView.separatorInset = UIEdgeInsetsZero
        tripTableView.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tripTableView.registerClass(TripsViewCell.self, forCellReuseIdentifier: "tripCell")
        self.contentView.addSubview(self.tripTableView)
          
        
        loadLikeTrips()
      
    }
    
    func loadStream(){
        OuterspatialClient.sharedInstance.getPosts(page,parameters: ["liked":"true"]) {
            (result: [Post]?,error: String?) in
            if let posts = result {
                print("got back: \(result)")
                self.posts = posts
                self.streamTableView.reloadData()
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0.5, options: [], animations: {
                                            
                                            self.streamTableView.h = CGFloat(self.posts.count * 50)
                                            self.backgroundView.h = CGFloat((self.posts.count * 50) + 20)
                                           // self.contentView.h = self.backgroundView.h
                    }, completion: nil)
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
    }
    
    func loadLikeTrips(){
        OuterspatialClient.sharedInstance.getTrips(page,parameters: ["liked":"true"]) {
            (result: [Trip]?,error: String?) in
            if let trips = result {
                print("got back: \(result)")
                self.likeTrips = trips
                self.likesTableView.reloadData()
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0.5, options: [], animations: {
                                            
                                            self.likesTableView.h = CGFloat(self.likeTrips.count * 50)
                                            self.backgroundView.h = CGFloat((self.likeTrips.count * 50) + 20)
                    }, completion: nil)
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
    }
    
    
    func loadTrips(){
        OuterspatialClient.sharedInstance.getTrips(page,parameters: ["finished":"true"]) {
            (result: [Trip]?,error: String?) in
            if let trips = result {
                print("got back: \(result)")
                self.trips = trips
                self.tripTableView.reloadData()
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0.5, options: [], animations: {
                                            
                                            self.tripTableView.h = CGFloat(self.trips.count * 50)
                                            self.backgroundView.h = CGFloat((self.trips.count * 50) + 20)
                    }, completion: nil)
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
   
        //    if(ViewindexPath.row == selectedTableView.indexPathsForVisibleRows!.last!.row){
                self.viewDidLayoutSubviews()
         //   }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.h = selectedTableView.bottom+10
        scrollView.contentSize = contentView.bounds.size
        print("contentView.bounds.size: \(contentView.bounds.size)")
        print("tableView: \(backgroundView.frame.height)")
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 50.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == self.streamTableView){
            return self.posts.count
        } else if(tableView == self.tripTableView){
            return self.trips.count
        } else {
            return self.likeTrips.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(tableView == self.streamTableView){
            let cell:PostsViewCell = self.streamTableView.dequeueReusableCellWithIdentifier("PostCell")! as! PostsViewCell
            let post:Post = self.posts[indexPath.row]
            cell.loadItem(post)
            
            return cell
        } else if(tableView == self.likesTableView) {
            
            let cell:TripsViewCell = self.likesTableView.dequeueReusableCellWithIdentifier("tripCell")! as! TripsViewCell
            let trip:Trip = self.likeTrips[indexPath.row]
            cell.loadItem(trip)
            cell.selectionCallback = {
                print("\(self.likeTrips[indexPath.row]) at \(indexPath.row) on \(tableView) selected")
                self.likeTrips.removeAtIndex(indexPath.row)
                //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                self.likesTableView.reloadData()
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0.5, options: [], animations: {
                                            
                                            self.likesTableView.h = CGFloat(self.likeTrips.count * 50)
                                            self.backgroundView.h = CGFloat((self.likeTrips.count * 50) + 20)
                    }, completion: nil)
            }
            return cell
        }else {
            
            let cell:TripsViewCell = self.likesTableView.dequeueReusableCellWithIdentifier("tripCell")! as! TripsViewCell
            let trip:Trip = self.trips[indexPath.row]
            cell.loadItem(trip)
            cell.selectionCallback = {
                self.trips.removeAtIndex(indexPath.row)
                //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                self.tripTableView.reloadData()
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0.5, options: [], animations: {
                                            
                                            self.tripTableView.h = CGFloat(self.trips.count * 50)
                                            self.backgroundView.h = CGFloat((self.trips.count * 50) + 20)
                    }, completion: nil)
            }
            return cell
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
       
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if(tableView == self.likesTableView){
            let trip = likeTrips[indexPath.row]
            let tabBar: UITabBarController = self.parentViewController?.parentViewController as! UITabBarController
            let tripsViewNavigationController: UINavigationController = tabBar.viewControllers![1] as! UINavigationController
            let tripsViewController: TripsViewController = tripsViewNavigationController.viewControllers[0] as! TripsViewController
            tripsViewController.selectTrip(trip)
            tabBar.selectedIndex = 1
            
        } else if(tableView == self.tripTableView){
            let trip = trips[indexPath.row]
            let tabBar: UITabBarController = self.parentViewController?.parentViewController as! UITabBarController
            let tripsViewNavigationController: UINavigationController = tabBar.viewControllers![1] as! UINavigationController
            let tripsViewController: TripsViewController = tripsViewNavigationController.viewControllers[0] as! TripsViewController
            tripsViewController.selectTrip(trip)
            tabBar.selectedIndex = 1
            
        }
        else{
            
            let post = posts[indexPath.row]
            let tabBar: UITabBarController = self.parentViewController?.parentViewController as! UITabBarController
            let postsViewNavigationController: UINavigationController = tabBar.viewControllers![2] as! UINavigationController
            let postsViewController: PostsViewController = postsViewNavigationController.viewControllers[0] as! PostsViewController
            postsViewController.selectPost(post)
            tabBar.selectedIndex = 2
        }
       // tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    func btnTouched(sender: UIButton){
        selectedTableView.hidden = true
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.5, options: [], animations: {
                                    if let selectedButton = self.selectedButton {
                                        selectedButton.h = 40
                                        selectedButton.y = selectedButton.y+20
                                    }
            }, completion: nil)
        selectedButton = sender
        
        if(sender.tag == 1){
            selectedTableView = likesTableView
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        self.backgroundView.backgroundColor = UIColor(patternImage:UIImage(named:"likedbar")!)
                                        sender.h = 60
                                        sender.y = sender.y-20
                                        self.backgroundView.h = self.likesTableView.h+20
                                        self.likesTableView.hidden = false
                }, completion: nil)
            loadLikeTrips()
        }else if(sender.tag == 2) {
            selectedTableView = tripTableView
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        self.backgroundView.backgroundColor = UIColor(patternImage:UIImage(named: "daycationbar")!)
                                        sender.h = 60
                                        sender.y = sender.y-20
                                        self.backgroundView.h = self.tripTableView.h+20
                                        self.tripTableView.hidden = false
                }, completion: nil)
            loadTrips()
        }else if(sender.tag == 3) {
            
            selectedTableView = streamTableView
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        self.backgroundView.backgroundColor = UIColor(patternImage:UIImage(named: "streambar")!)
                                        sender.h = 60
                                        sender.y = sender.y-20
                                        self.backgroundView.h = self.streamTableView.h+20
                                        self.streamTableView.hidden = false
                }, completion: nil)
            loadStream()
        }
        
    }
    
    
    func tappedDone(sender: UIBarButtonItem){
        OuterspatialClient.sharedInstance.logout()
        let navigationController = UINavigationController(rootViewController: EntryViewController())
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func tappedEdit(sender: UIBarButtonItem){
        OuterspatialClient.currentUser!.profile!.image = self.profileImageView!.image
        let navigationController = UINavigationController(rootViewController: ProfileEditViewController())
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        //   self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:"MY PROFILE")
        let cache = Shared.imageCache
        cache.fetch(key: "PROFILE").onSuccess { data in
            self.profileImageView!.image = data
            }.onFailure { data in
               self.profileImageView!.hnk_setImageFromURL(OuterspatialClient.currentUser!.profile!.imageUrl!)
        }
        
        if let organization = OuterspatialClient.currentUser!.profile?.organization?.name {
            organizationLabel.text=organization.uppercaseString
            organizationLabel.fitHeight()
        }
       
        if ((selectedButton) != nil) {
            btnTouched(selectedButton!)
        }
        
    }
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}