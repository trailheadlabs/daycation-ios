import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD
import ICSPullToRefresh
import DOFavoriteButton
import Haneke
import SnapKit
import MapKit

class  PostDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate{
    
    var tableView: UITableView = UITableView()
    var userTableView: UITableView!
    var postText: UILabel!
    var postImage: UIImageView!
    var tableHeader: UILabel!
    var mapView: MKMapView!
    var likeCountLabel: UILabel!
    var post: Post!
    var heartButton: DOFavoriteButton!
    var heartImage: DOFavoriteButton!
    var scrollView: UIScrollView!
    var contentView: UIView!
    var likeView: UIView!
    let cache = Shared.imageCache
    var completion:PostCompletionHandler?
    var owned: Bool = false
    
    convenience init(post: Post, completionBlock: PostCompletionHandler) {
        self.init()
        self.post = post
        self.completion=completionBlock
        self.owned = post.user.id==OuterspatialClient.currentUser?.id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Stream Post"
        
        likeView = UIView(frame: CGRectMake(0,  0, 44, 44))
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = likeView
        self.navigationItem.rightBarButtonItem = rightBarButton
        likeCountLabel = UILabel(frame: CGRectMake(0,  0, 44, 44))
        likeCountLabel.font=UIFont(name:"Quicksand-Bold", size:14)
        likeCountLabel.textColor=UIColor(hexString: "#fff9e1")
        
        likeView.addSubview(likeCountLabel!)
        
        
        heartButton = DOFavoriteButton(frame: CGRectMake(0,  0, 44, 44), image: UIImage(named: "Daycation_Heart_icon.png"))
        heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        heartButton.addTarget(self, action: Selector("tappedButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        likeView.addSubview(heartButton!)
        scrollView = UIScrollView()
        scrollView.userInteractionEnabled = true
        self.view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.userInteractionEnabled = true
        userTableView = UITableView(frame: CGRectMake(3,8,self.view.w,70))
        userTableView.dataSource = self
        userTableView.delegate = self
        userTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        userTableView.separatorInset = UIEdgeInsetsZero
        userTableView.backgroundColor = UIColor(hexString: "#fff9e1")
        // tableView.rowHeight = 100.0
        //  self.tableView.estimatedRowHeight = 88.0
        //  self.tableView.rowHeight = UITableViewAutomaticDimension
        self.userTableView.registerClass(UserView.self, forCellReuseIdentifier: "user")
        
        contentView.addSubview(userTableView)
        
        let separatorImage=UIImageView(frame: CGRectMake( 0, userTableView.bottomOffset(5), self.view.frame.size.width, 5))
        separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        separatorImage.clipsToBounds = true
        separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(separatorImage)
        
        postText = UILabel(frame: CGRectMake(30, 0, self.view.frame.size.width-60, 44))
        contentView.addSubview(postText)
        
        postText.font = UIFont(name: "Quicksand-Regular", size: 14)
        setTextWithLineSpacing(postText,text: (post.postText)!,lineSpacing: 9)
        postText.numberOfLines = 1000;
        postText.sizeToFit()
        postText.y = separatorImage.bottomOffset(5)
        let button = UIButton(type: UIButtonType.System) as UIButton
        contentView.addSubview(button)
        if  self.owned {
            button.setImage(UIImage(named: "DAYC_delete_button@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
            button.userInteractionEnabled = true
            button.addTarget(self, action: "tappedDelete:", forControlEvents: UIControlEvents.TouchUpInside)
            button.frame = CGRectMake(0, postText.bottomOffset(2), self.view.frame.size.width, 50)
      
        }
        
        let bottomSeparatorImage=UIImageView(frame: CGRectMake( 0, self.owned ? button.bottomOffset(2) : postText.bottomOffset(5), self.view.frame.size.width, 5))
        bottomSeparatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        bottomSeparatorImage.clipsToBounds = true
        bottomSeparatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(bottomSeparatorImage)
        
        postImage=UIImageView(frame: CGRectMake(0, bottomSeparatorImage.bottomOffset(5), self.view.frame.size.width, post.imageUrl == nil ? 0 : 200))
        contentView.addSubview(postImage!)
        postImage.contentMode = UIViewContentMode.ScaleAspectFit
        postImage.clipsToBounds = true
        postImage.alpha = 0.5
        if let url = post.imageUrl{
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(PostDetailViewController.imageTapped(_:)))
            postImage.userInteractionEnabled = true
            postImage.addGestureRecognizer(tapGestureRecognizer)

            postImage.hnk_setImageFromURL(url, placeholder: nil, success: { (UIImage) -> Void in
                UIView.animateWithDuration(1.0, animations: {
                    self.postImage.alpha = 1
                })
                self.postImage.image = UIImage
                self.cache.set(value: UIImage, key: url.URLString)
                }, failure: { (Error) -> Void in
                    
            })
        }
        self.postImage.layer.borderWidth = 1
        self.postImage.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).CGColor
        mapView=MKMapView(frame: CGRectMake(0, postImage.bottomOffset(5), self.view.frame.size.width,  200))
        contentView.addSubview(mapView)
        mapView.userInteractionEnabled = true
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.delegate =  self
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PostDetailViewController.mapTapped(_:))))
     
        
        let coordinate = post.location != nil ? post.location!.coordinate : CLLocationCoordinate2D(latitude: 45.523064, longitude: -122.676483)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,
                                                                  2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = CustomPointAnnotation()

        annotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude)
        mapView.addAnnotation(annotation)
        let markerImage=UIImageView(frame: CGRectMake(15, mapView.bottomOffset(5), 30, 30))
        markerImage.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Heart_liked@3x.png")!, w: 20, h: 20)
        contentView.addSubview(markerImage)
        
        
        tableHeader = UILabel(frame: CGRectMake(markerImage.rightOffset(5), mapView.bottomOffset(5), self.view.frame.size.width-10,  32))
        tableHeader.font = UIFont(name:"Quicksand-Bold", size:14)
        tableHeader.textColor = UIColor(hexString: "#8e8e8e")
        tableHeader.numberOfLines = 1;
        contentView.addSubview(tableHeader)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        contentView.addSubview(tableView)
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.scrollEnabled = false
        tableView.backgroundColor = UIColor(hexString: "#fff9e1")
        //  self.tableView.layer.borderWidth = 1
        //  self.tableView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).CGColor
        
        tableView.frame = CGRectMake(0, tableHeader.bottomOffset(2), self.view.frame.size.width, 50)
        tableView.snp_makeConstraints {make in
            make.top.equalTo(markerImage.snp_bottom);
            make.left.equalTo(0);
            make.width.equalTo(self.view.frame.size.width);
            make.height.equalTo((self.post.likers.count*50));
        }
        scrollView.addSubview(contentView)
        
        scrollView.snp_makeConstraints {make in
            make.edges.equalTo(view)
            //make.edges.equalTo(view).inset(UIEdgeInsetsMake(69, 69, 49, 69))
        }
        contentView.h = tableView.bottom
        
        
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")
    }
    
    func mapTapped(gestureRecognizer: UIGestureRecognizer) {
        
        let navigationViewController = MapDetailViewController(annotations: mapView.annotations)
        self.navigationController?.pushViewController(navigationViewController, animated: true)
    }
    func imageTapped(img: AnyObject)
    {
        
        let navigationViewController = PostPhotoDetailViewController(post: post)
        self.navigationController?.pushViewController(navigationViewController, animated: true)
        
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableView == userTableView{
            return 1
        } else {
            return self.post.likers.count
        }
    }
    
      func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
          return 70;
      }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if tableView == userTableView{
            
            var cell:UserView = UserView()
            cell.setUser(post.user)
            cell.setDate(post)
            
            return cell
            
        } else {
            
            var cell:UserView = UserView()
            cell.setUser(self.post.likers[indexPath.row])
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        print("You selected cell #\(indexPath.row)!")
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    func tappedAdd(sender: UIBarButtonItem){
        scrollView.contentSize = contentView.bounds.size
        print("contentView.bounds.size: \(contentView.bounds.size)")
        print("tableView: \(tableView.frame.height)")
    }
    
    
    
    
    
    func tappedDelete(sender: UIBarButtonItem){
        
        HUD.show(.Progress)
        OuterspatialClient.sharedInstance.deletePost(post.id!){
            (error: String?) in
            self.completion!(post: self.post)
            HUD.hide(afterDelay: 0)
            self.navigationController?.popViewControllerAnimated(true)
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        print(contentView.frame.width)
        print(contentView.frame.height)
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
        }
        else {
            pinView!.annotation = annotation
        }
        
        pinView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Map_marker@3x.png")!, w: 25, h: 25)
        pinView!.centerOffset = CGPointMake(0, -25 / 2);

        return pinView
    }
    
    func tappedButton(sender: DOFavoriteButton) {
        if sender.selected {
            OuterspatialClient.sharedInstance.setPostLikeStatus(self.post.id!,likeStatus: false) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            //            for liker in self.post.likers{
            //                if  liker.id == OuterspatialClient.currentUser!.id{
            //                    self.post.likers.
            //                }
            //            }
            self.post.likers = self.post.likers.filter({
                $0.id != OuterspatialClient.currentUser!.id
            })
            self.post.likes!--
            self.post.liked = false
            updateLikeCount()
            sender.deselect()
        } else {
            OuterspatialClient.sharedInstance.setPostLikeStatus(self.post.id!,likeStatus: true) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            self.post.likers.append(OuterspatialClient.currentUser!)
            
            self.post.liked = true
            self.post.likes!++
            updateLikeCount()
            sender.select()
        }
    }
    
    func  updateLikeCount() {
        print("contentView.bounds.size1: \(contentView.bounds.size)")
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        print("height1: \( self.tableView.bounds.size)")
        print("calculated: \( (self.post.likers.count*50))")
        // self.tableView.frame.size.height=CGFloat(self.post.likers.count)*50.0
        self.tableView.snp_updateConstraints{ make in
            make.height.equalTo((self.post.likers.count*70)+5);
        }
        self.contentView.snp_updateConstraints {make in
            make.bottom.equalTo(self.tableView.snp_bottom);
            make.right.equalTo(self.tableView.snp_right);
            make.top.equalTo(0);
        }
        //self.scrollView.contentSize = self.contentView.bounds.size
        print("height: \((self.post.likers.count*50))")
        print("contentView.bounds.size2: \(contentView.bounds.size)")
        likeCountLabel.text = String(self.post.likes!)
        likeCountLabel.sizeToFit()
        // likeCountLabel.x = heartButton.rightOffset(2)
        // likeCountLabel.y = heartButton.top
        likeCountLabel.x = 40
        likeCountLabel.y = 12
        // heartButton.x = likeCountLabel.left-heartButton.w-5
        self.heartButton.selected = self.post.liked!
        self.tableHeader.text = "\(self.post.likes!) people like this post"
        self.viewDidLayoutSubviews()
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            self.scrollView.contentSize = self.contentView.bounds.size
        })
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.scrollView.contentSize = self.contentView.bounds.size
        if(indexPath.row == tableView.indexPathsForVisibleRows!.last!.row){
            self.viewDidLayoutSubviews()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       // contentView.w = self.view.frame.size.width
        scrollView.contentSize = contentView.bounds.size
        print("contentView.bounds.size: \(contentView.bounds.size)")
        print("tableView: \(tableView.frame.height)")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        updateLikeCount()
        OuterspatialClient.sharedInstance.getPost(post.id!) {
            (result: Post?,error: String?) in
            print("got back: \(result)")
            
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
                return
            }
            self.tableView.dataSource = self
            self.post.likers = result!.likers
            self.updateLikeCount()
            
        }
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        
        let backgroundImage = UIImage(named:"DAYC_BLUE_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage,
                                                                    forBarMetrics: .Default)
        self.navigationController?.navigationBar.translucent = false
        contentView.w = self.view.frame.size.width
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}