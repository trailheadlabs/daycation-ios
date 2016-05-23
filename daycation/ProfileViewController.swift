import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD
import Foundation

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
    var bioLabel: UILabel!
    var streamactInd : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Me"
        
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "tappedEdit:")
        b.title = "Edit"
        let a = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action:"tappedDone:")

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
        
        self.bioLabel=UILabel(frame: CGRectMake(20, self.profileImageView!.bottomOffset(20), 100, 100))
        bioLabel.text=OuterspatialClient.currentUser!.profile?.bio
        bioLabel.fitSize()
        self.contentView.addSubview(bioLabel!)
        
        
        var image:UIImage = UIImage(named:"Image-1")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 80))!
        let button   = UIButton(type: UIButtonType.Custom) as UIButton
        button.setTitle("LIKED", forState: .Normal)
        button.frame = CGRectMake(20, self.bioLabel!.bottomOffset(20), 80, 40)
        
        button.backgroundColor = UIColor(patternImage:UIImage(named: "Image-1")!)
        button.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        button.tag = 1
        self.contentView.addSubview(button)
        
        let daybutton   = UIButton(type: UIButtonType.Custom) as UIButton
        daybutton.setTitle("DAYCATIONS", forState: .Normal)
        daybutton.frame = CGRectMake(button.right, self.bioLabel!.bottomOffset(20), self.view.w-220, 40)
        daybutton.backgroundColor = UIColor(patternImage:UIImage(named: "Image-2")!)
        daybutton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        daybutton.tag = 2
        self.contentView.addSubview(daybutton)
        
        let streambutton   = UIButton(type: UIButtonType.Custom) as UIButton
        streambutton.setTitle("STREAM", forState: .Normal)
        streambutton.frame = CGRectMake(daybutton.right, self.bioLabel!.bottomOffset(20), 100, 40)
        streambutton.backgroundColor = UIColor(patternImage:UIImage(named: "Image-3")!)
        streambutton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        streambutton.tag = 3
        self.contentView.addSubview(streambutton)
        
        
        backgroundView = UIView(frame: CGRectMake(0, daybutton.bottom, self.view.frame.size.width, 100))
        backgroundView.backgroundColor = UIColor(patternImage:UIImage(named: "Image-1")!)
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
        likesTableView.layer.borderColor = UIColor(patternImage:UIImage(named: "Image-1")!).CGColor
        selectedTableView = likesTableView
        //tableView.layer.borderWidth = 10
        
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(likesTableView.w/2-25,likesTableView.h/2-25, 50, 50)) as UIActivityIndicatorView
        
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        actInd.startAnimating()
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
        streamTableView.layer.borderColor = UIColor(patternImage:UIImage(named: "Image-1")!).CGColor
        
        self.streamTableView.addInfiniteScrollingWithHandler {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.page++
                    OuterspatialClient.sharedInstance.getPosts(self.page,parameters: [:]) {
                        (result: [Post]?,error: String?) in
                        if let posts = result {
                            print("got back: \(result)")
                            
                            self.posts.appendContentsOf(posts)
                            
                            self.streamTableView.reloadData()
                            self.streamTableView.infiniteScrollingView?.stopAnimating()
                        }
                        if let error = error{
                            HUD.flash(.Label(error), withDelay: 2.0)
                        }
                    }
                    })
            })
        }
        
        streamactInd = UIActivityIndicatorView(frame: CGRectMake(likesTableView.w/2-25,likesTableView.h/2-25, 50, 50)) as UIActivityIndicatorView
        streamactInd.hidesWhenStopped = true
        streamactInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        streamactInd.startAnimating()
        self.streamTableView.addSubview(actInd)
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
        OuterspatialClient.sharedInstance.getPosts(page,parameters: [:]) {
            (result: [Post]?,error: String?) in
            if let posts = result {
                print("got back: \(result)")
                self.streamactInd.stopAnimating()
                self.posts = posts
                self.streamTableView.reloadData()
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0.5, options: [], animations: {
                                            
                                            self.streamTableView.h = CGFloat(self.posts.count * 50)
                                            self.backgroundView.h = CGFloat((self.posts.count * 50) + 20)
                                            self.contentView.h = self.backgroundView.h
                    }, completion: nil)
            }
            if let error = error{
                HUD.flash(.Label(error), withDelay: 2.0)
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
                HUD.flash(.Label(error), withDelay: 2.0)
            }
        }
    }
    
    
    func loadTrips(){
        OuterspatialClient.sharedInstance.getTrips(page,parameters: [:]) {
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
                HUD.flash(.Label(error), withDelay: 2.0)
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
                                        self.backgroundView.backgroundColor = UIColor(patternImage:UIImage(named: "Image-1")!)
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
                                        self.backgroundView.backgroundColor = UIColor(patternImage:UIImage(named: "Image-2")!)
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
                                        self.backgroundView.backgroundColor = UIColor(patternImage:UIImage(named: "Image-3")!)
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
        self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:"MY PROFILE")
        self.profileImageView!.hnk_setImageFromURL(OuterspatialClient.currentUser!.profile!.imageUrl!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}