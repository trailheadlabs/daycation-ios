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
    var postText: UILabel!
    var userImage: UIImageView!
    var postImage: UIImageView!
    var nameText: UILabel!
    var dateText: UILabel!
    var tableHeader: UILabel!
    var mapView: MKMapView!
    var likeCountLabel: UILabel!
    var post: Post!
    var heartButton: DOFavoriteButton!
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
        likeView.addSubview(likeCountLabel!)
        
        heartButton = DOFavoriteButton(frame: CGRectMake(0,  0, 44, 44), image: UIImage(named: "Daycation_Heart_icon.png"))
        heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        heartButton.addTarget(self, action: Selector("tappedButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        likeView.addSubview(heartButton!)
        
        scrollView = UIScrollView()
       //// let deTap = UITapGestureRecognizer(target: self, action: "tappedAdd:")
      // deTap.cancelsTouchesInView = false;
       // scrollView.addGestureRecognizer(deTap)
       scrollView.userInteractionEnabled = true
        //scrollView.userInteractionEnabled = false;
        //scrollView.exclusiveTouch = false;
      //  scrollView.canCancelContentTouches = false;
        //scrollView.delaysContentTouches = false;
        self.view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.userInteractionEnabled = true
        
        userImage=UIImageView(frame: CGRectMake(3,8,50,50))
        contentView.addSubview(userImage!)
        userImage.contentMode = UIViewContentMode.ScaleAspectFill
        userImage.clipsToBounds = true
        userImage.alpha = 0.5
        if let url = post.user.profile?.imageUrl{
            userImage.hnk_setImageFromURL(url, placeholder: nil, success: { (UIImage) -> Void in
                UIView.animateWithDuration(1.0, animations: {
                    self.userImage.alpha = 1
                })
                self.userImage.image = UIImage.circleMask
                self.cache.set(value: UIImage, key: url.URLString)
                }, failure: { (Error) -> Void in
                    
            })
        }
        
        nameText = UILabel(frame: CGRectMake(55,8,50,50))
        contentView.addSubview(nameText!)
        nameText.textColor = UIColor.lightGrayColor()
        nameText.font = UIFont.systemFontOfSize(10)
        nameText.text = post.user.profile?.abbreviatedName
        
        dateText = UILabel(frame: CGRectMake(55,20,250,50))
        contentView.addSubview(dateText!)
        dateText.textColor = UIColor.lightGrayColor()
        dateText.font = UIFont.systemFontOfSize(10)
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .ShortStyle
        dateText.text = formatter.stringFromDate(post.createdAt!)
        
        postText = UILabel()
        contentView.addSubview(postText)
        postText.font = UIFont(name: postText.font.fontName, size: 14)
        setTextWithLineSpacing(postText,text: (post.postText)!,lineSpacing: 9)
        postText.numberOfLines = 2;
        postText.snp_makeConstraints {make in
            make.top.equalTo(dateText.snp_bottom);
            make.left.equalTo(5);
            make.width.equalTo(self.view.frame.size.width-10);
            make.height.equalTo(50);
        }
        postText.sizeToFit()
        
        let button = UIButton(type: UIButtonType.System) as UIButton
        
        contentView.addSubview(button)
        if  self.owned {
        button.addTarget(self, action: "tappedDelete:", forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle("Delete Post", forState: UIControlState.Normal)
        button.titleLabel!.font  = UIFont.boldSystemFontOfSize(16.0)
        button.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        button.userInteractionEnabled = true
        //button.frame = CGRectMake(0, 0, self.view.frame.size.width, 50)
        button.snp_makeConstraints {make in
            make.top.equalTo(postText.snp_bottom);
            make.left.equalTo(0);
            make.width.equalTo(self.view.frame.size.width);
            make.height.equalTo(50);
            // make.height.equalTo(self.owned ? 0 : 50);
            
        }
            
        }
        postImage=UIImageView()
        contentView.addSubview(postImage!)
        postImage.contentMode = UIViewContentMode.ScaleAspectFill
        postImage.clipsToBounds = true
        postImage.alpha = 0.5
        postImage.snp_makeConstraints {make in
            make.top.equalTo(self.owned ? button.snp_bottom : postText.snp_bottom);
            // make.top.equalTo( button.snp_bottom );
            make.left.equalTo(0);
            make.width.equalTo(self.view.frame.size.width);
            make.height.equalTo(post.imageUrl == nil ? 0 : 200);
        }
        if let url = post.imageUrl{
            self.postImage.frame = CGRectMake(0, 0, self.view.frame.size.width, 200)
            
            postImage.hnk_setImageFromURL(url, placeholder: nil, success: { (UIImage) -> Void in
                UIView.animateWithDuration(1.0, animations: {
                    self.postImage.alpha = 1
                })
                self.viewDidLayoutSubviews()
                self.postImage.image = UIImage
                self.cache.set(value: UIImage, key: url.URLString)
                }, failure: { (Error) -> Void in
                    
            })
        }
        
        mapView=MKMapView()
        contentView.addSubview(mapView)
        mapView.userInteractionEnabled = true
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.delegate =  self
        mapView.snp_makeConstraints {make in
            make.top.equalTo(postImage.snp_bottom);
            make.left.equalTo(0);
            make.width.equalTo(self.view.frame.size.width);
            make.height.equalTo(250);
        }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(post.location!.coordinate,
            2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(post.location!.coordinate.latitude,post.location!.coordinate.longitude)
        mapView.addAnnotation(annotation)
        
        tableHeader = UILabel()
        contentView.addSubview(tableHeader)
        tableHeader.font = UIFont(name: postText.font.fontName, size: 14)
        tableHeader.numberOfLines = 1;
        tableHeader.snp_makeConstraints {make in
            make.top.equalTo(mapView.snp_bottom);
            make.left.equalTo(5);
            make.width.equalTo(self.view.frame.size.width-10);
            make.height.equalTo(50);
        }
        tableHeader.sizeToFit()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        contentView.addSubview(tableView)
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.scrollEnabled = false
      //  self.tableView.layer.borderWidth = 1
      //  self.tableView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).CGColor
        tableView.snp_makeConstraints {make in
            make.top.equalTo(tableHeader.snp_bottom);
            make.left.equalTo(0);
            make.width.equalTo(self.view.frame.size.width);
            make.height.equalTo((self.post.likers.count*50));
        }
        scrollView.addSubview(contentView)
        
        scrollView.snp_makeConstraints {make in
            make.edges.equalTo(view)
            //make.edges.equalTo(view).inset(UIEdgeInsetsMake(69, 69, 49, 69))
        }
        contentView.snp_makeConstraints {make in
            make.bottom.equalTo(tableView.snp_bottom);
            make.width.equalTo(self.view.frame.size.width);
            
            make.top.equalTo(0);
        }
        
    }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        
        return self.post.likers.count
    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 65.0;
//    }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("myCell")! as UITableViewCell
        
        cell.textLabel!.text = self.post.likers[indexPath.row].profile?.abbreviatedName
        let fetcher = NetworkFetcher<UIImage>(URL: (self.post.likers[indexPath.row].profile?.imageUrl)!)
        
        let cache = Shared.imageCache
        cell.imageView!.frame = CGRectMake(3,8,50,50)
        cache.fetch(fetcher: fetcher).onSuccess { image in
            cell.imageView!.image = image.circleMask
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        return cell
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
                HUD.flash(.Label(error), withDelay: 2.0)
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
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Purple
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func tappedButton(sender: DOFavoriteButton) {
        if sender.selected {
            OuterspatialClient.sharedInstance.setPostLikeStatus(self.post.id!,likeStatus: false) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), withDelay: 2.0)
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
                    HUD.flash(.Label(error), withDelay: 2.0)
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
            make.height.equalTo((self.post.likers.count*50));
        }
        self.contentView.snp_updateConstraints {make in
            make.bottom.equalTo(self.tableView.snp_bottom);
            make.top.equalTo(0);
        }
        //self.scrollView.contentSize = self.contentView.bounds.size
        print("height: \((self.post.likers.count*50))")
        print("contentView.bounds.size2: \(contentView.bounds.size)")
        likeCountLabel.text = String(self.post.likes!)
        self.heartButton.selected = self.post.liked!
        self.tableHeader.text = "\(self.post.likes!) people like this"
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
        scrollView.contentSize = contentView.bounds.size
        print("contentView.bounds.size: \(contentView.bounds.size)")
        print("tableView: \(tableView.frame.height)")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        updateLikeCount()
        OuterspatialClient.sharedInstance.getPost(post.id!) {
            (result: Post?,error: String?) in
            print("got back: \(result)")
            
            if let error = error{
                HUD.flash(.Label(error), withDelay: 2.0)
                return
            }
            self.tableView.dataSource = self
            self.post.likers = result!.likers
            self.updateLikeCount()
            
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.setNavigationBarHidden(false, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}