import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import iCarousel
import PKHUD
import EZSwiftExtensions
import DOFavoriteButton

class HomeViewController : UIViewController, iCarouselDataSource, iCarouselDelegate, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate  {
    var pageControl : UIPageControl!
    var carousel : iCarousel!
    var headerImage : UIImageView!
    var logoImageView : UIImageView!
    var postsTableView : UITableView!
    var featureBundles : [FeatureBundle] = []
    var highlightedFeatures : [Feature] = []
    var posts : [Post] = []
    var contentView: UIView!
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerImage=UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width,60))
        headerImage.image = UIImage(named:"Daycation_home_bar.png")
        headerImage.contentMode = UIViewContentMode.ScaleAspectFill
        headerImage.clipsToBounds = true
        self.view.addSubview(headerImage!)
        
        logoImageView=UIImageView(frame: CGRectMake(headerImage.w/2-15, headerImage.h/2-8, 30,30))
        logoImageView.image = UIImage.scaleTo(image: UIImage(named: "home_selected@3x.png")!, w: 30, h: 30)

        self.view.addSubview(logoImageView!)
        
        scrollView = UIScrollView()
        scrollView.y = 60
        scrollView.w = view.w
        scrollView.h = view.bottomOffset(-110)
        scrollView.userInteractionEnabled = true
        self.view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.w = view.w
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")
        contentView.userInteractionEnabled = true
        scrollView.addSubview(contentView)
        
        carousel = iCarousel(frame: CGRectMake(100, 0, self.view.frame.size.width, 195))
        carousel.center = view.center
        carousel.frame.origin.y = 0
        carousel.type = .Linear
        carousel.dataSource = self
        carousel.delegate = self
        carousel.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).CGColor
        
        pageControl = UIPageControl(frame: CGRectMake(0, 0, 0, 20))
        pageControl.center =  view.center
        pageControl.y = carousel.bottomOffset(-30)
        pageControl.layer.borderColor = UIColor(red:222/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.redColor()
        pageControl.pageIndicatorTintColor = UIColor(hexString: "#cecece")
        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "#f67535")
        pageControl.userInteractionEnabled = false
        contentView.addSubview(carousel)
        contentView.addSubview(pageControl)
        
        postsTableView = UITableView(frame: CGRectMake( 0, carousel.bottom, self.view.frame.size.width, (3*50)+31.0))
        postsTableView.backgroundColor = UIColor(hexString: "#fff9e1")
        postsTableView.dataSource = self
        postsTableView.delegate = self
        postsTableView.scrollEnabled = false
        postsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        postsTableView.separatorInset = UIEdgeInsetsZero
        postsTableView.registerClass(PostsViewCell.self, forCellReuseIdentifier: "HomePostCell")
        contentView.addSubview(postsTableView)
        
        let separatorImage=UIImageView(frame: CGRectMake( 0, postsTableView.bottomOffset(2), self.view.frame.size.width, 5))
        separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        separatorImage.clipsToBounds = true
        separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(separatorImage)
        
        contentView.h=separatorImage.bottom
        
        OuterspatialClient.sharedInstance.getPosts(1, parameters: [:]) {
            (result: [Post]?,error: String?) in
            if let posts = result {
                print("got back: \(result)")
                var topPosts = [Post]()
                topPosts += posts.prefix(3)
                self.posts = topPosts
                self.postsTableView.reloadData()
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        
        OuterspatialClient.sharedInstance.getApplication() {
            (result: Application?,error: String?) in
            print("got back: \(result)")
            self.featureBundles = (result?.featureBundles)!
            self.highlightedFeatures = self.featureBundles[0].features
            self.pageControl.numberOfPages = self.highlightedFeatures.count
            self.carousel.reloadData()
            var bottom = self.postsTableView.bottomOffset(7)
            for (index, featureBundle) in self.featureBundles.enumerate(){
                if index > 0 {
                    let tableView = UITableView(frame: CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height-(44+20+49)))
                    tableView.backgroundColor = UIColor(hexString: "#fff9e1")
                    tableView.dataSource = self
                    tableView.delegate = self
                    tableView.scrollEnabled = false
                    tableView.backgroundColor = UIColor(hexString: "#fff9e1")
                    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                    tableView.separatorInset = UIEdgeInsetsZero
                    tableView.sectionHeaderHeight = 70
                    tableView.registerClass(TripsViewCell.self, forCellReuseIdentifier: "BundleCell")
                    tableView.tag=index
                    tableView.top=bottom
                    tableView.left=0
                    tableView.w=self.view.w
                    tableView.h=CGFloat((featureBundle.features.count*50)+70)
                    self.contentView.addSubview(tableView)
                    bottom = tableView.bottom
                    self.contentView.h=bottom
                    self.scrollView.contentSize = self.contentView.bounds.size
                }
            }
            
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
                return
            }
            
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return self.highlightedFeatures.count
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel){
        self.pageControl.currentPage = Int(self.carousel.currentItemIndex);
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        var likeCountLabel: UILabel
        var heartButton: DOFavoriteButton
        
        //create new view if no view is available for recycling
        if (view == nil) {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:self.view.frame.width, height:195))
            itemView.userInteractionEnabled = true
            //    itemView.layer.borderWidth = 1
            itemView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:0/255.0, alpha: 1.0).CGColor
            
            itemView.clipsToBounds = true
            itemView.contentMode = .ScaleAspectFill
            
            label = UILabel(frame:CGRect(x:0, y:0, width:self.view.frame.width, height:195))
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.numberOfLines = 2
            label.font = UIFont(name: "TrueNorthRough3D-Regular", size: 50)
            label.textColor = UIColor(hexString: "#fcfbea")
            label.tag = 1
            itemView.addSubview(label)
            
            likeCountLabel = UILabel()
            likeCountLabel.textColor = UIColor.whiteColor()
            likeCountLabel.backgroundColor = UIColor.clearColor()
            likeCountLabel.font = UIFont(name: "Quicksand-Bold", size: 14)
            likeCountLabel.tag = 2
            //  likeCountLabel.layer.borderWidth = 1
            likeCountLabel.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
            //likeCountLabel.fitSize()
            itemView.addSubview(likeCountLabel)
            
            heartButton = DOFavoriteButton()
            heartButton.tag = 3
            //   heartButton.layer.borderWidth = 1
            heartButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
            heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
            heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
            heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
            heartButton.addTarget(self, action: Selector("tappedButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            itemView.addSubview(heartButton)
        }
        else {
            itemView = view as! UIImageView;
            label = itemView.viewWithTag(1) as! UILabel!
            likeCountLabel = itemView.viewWithTag(2) as! UILabel!
        }
        
        let trip:Trip = self.highlightedFeatures[index] as! Trip
        
        label.text = "\(trip.name!)"
        label.setLineHeight(0.7)
        likeCountLabel.text = "\(trip.likes!)"
        likeCountLabel.fitSize()
        likeCountLabel.x = itemView.rightOffset(-22)-likeCountLabel.w
        likeCountLabel.y = itemView.bottomOffset(-30)
        likeCountLabel.text = String(trip.likes!)
        
        
        heartButton = itemView.viewWithTag(3) as! DOFavoriteButton!
        heartButton.frame = CGRectMake(likeCountLabel.rightOffset(-35), itemView.bottomOffset(-35), 30, 30)
        
        let image = UIImage(named: "Daycation_Heart_icon.png")!
        heartButton.image =  image
        heartButton.selected = trip.liked
        
        
        itemView.hnk_setImageFromURL(trip.featuredImage!.largeUrl!, placeholder: nil, success: { (image) -> Void in
            // Get the original image and set up the CIExposureAdjust filter
            guard
                let inputImage = CIImage(image: image),
                let filter = CIFilter(name: "CIExposureAdjust") else { return }
            
            // The inputEV value on the CIFilter adjusts exposure (negative values darken, positive values brighten)
            filter.setValue(inputImage, forKey: "inputImage")
            filter.setValue(-2.0, forKey: "inputEV")
            
            // Break early if the filter was not a success (.outputImage is optional in Swift)
            guard let filteredImage = filter.outputImage else { return }
            
            let context = CIContext(options: nil)
            itemView.image = UIImage(CGImage: context.createCGImage(filteredImage, fromRect: filteredImage.extent))
            
            
            }, failure: { (Error) -> Void in
                
        })
        return itemView
    }
    
    func updateLikeCount() {
        let trip:Trip = self.highlightedFeatures[carousel.currentItemIndex] as! Trip
        let itemView = carousel.itemViewAtIndex(carousel.currentItemIndex) as! UIImageView
        let likeCountLabel = itemView.viewWithTag(2) as! UILabel!
        let heartButton = itemView.viewWithTag(3) as! DOFavoriteButton!
        likeCountLabel.text = String(trip.likes!)
        likeCountLabel.fitSize()
        heartButton.selected = trip.liked
    }
    
    
    func tappedButton(sender: DOFavoriteButton) {
        let trip:Trip = self.highlightedFeatures[carousel.currentItemIndex] as! Trip
        if sender.selected {
            OuterspatialClient.sharedInstance.setTripLikeStatus(trip.id!,likeStatus: false) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            trip.likes! -= 1
            trip.liked=false
            updateLikeCount()
            sender.deselect()
        } else {
            OuterspatialClient.sharedInstance.setTripLikeStatus(trip.id!,likeStatus: true) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            
            trip.likes! += 1
            trip.liked=true
            updateLikeCount()
            sender.select()
        }
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .Spacing) {
            return value
        }
        return value
    }
    
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex: Int) -> Void {
        let trip:Trip = self.highlightedFeatures[didSelectItemAtIndex] as! Trip
        openTrip(trip)
    }
    
    
    func openTrip(trip:Trip) {
        let tabBar: UITabBarController = self.parentViewController?.parentViewController as! UITabBarController
        let tripsViewNavigationController: UINavigationController = tabBar.viewControllers![1] as! UINavigationController
        let tripsViewController: TripsViewController = tripsViewNavigationController.viewControllers[0] as! TripsViewController
        tripsViewController.selectTrip(trip)
        tabBar.selectedIndex = 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.postsTableView){
            return self.posts.count
        } else {
            return self.featureBundles[tableView.tag].features.count
        }
    }
    //
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0;
    }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if(tableView == self.postsTableView){
            let cell:PostsViewCell = self.postsTableView.dequeueReusableCellWithIdentifier("HomePostCell")! as! PostsViewCell
            let post:Post = self.posts[indexPath.row]
            cell.loadItem(post)
            
            return cell
        } else {
            var cell:TripsViewCell = tableView.dequeueReusableCellWithIdentifier("BundleCell")! as! TripsViewCell
            let trip:Trip = self.featureBundles[tableView.tag].features[indexPath.row] as! Trip
            cell.loadItem(trip)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(tableView == self.postsTableView){
            
            let label = UILabel(frame: CGRect(x: 0, y: 7,  width: tableView.frame.size.width, height: 18))
            label.text = "STREAM"
            label.textAlignment = NSTextAlignment.Center
            
            label.textColor = UIColor(hexString: "#fc763a")
            label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 22)
            label.fitHeight()
            return label
        } else {
            
            let label = UILabel(frame: CGRect(x: 0, y: 7,  width: tableView.frame.size.width, height: 18))
            label.text = self.featureBundles[tableView.tag].name!.uppercaseString
            label.textAlignment = NSTextAlignment.Center
            
            label.textColor = UIColor(hexString: "#92d462")
            label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 22)
            label.fitHeight()
            return label
            
        }
        
    }
    
    func removePost(post: Post) {
        self.posts = self.posts.filter({
            $0.id != post.id
        })
        self.postsTableView.reloadData()
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if(tableView == self.postsTableView){
            let post = posts[indexPath.row]
            let navigationViewController = PostDetailViewController(post: post, completionBlock: removePost)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.navigationController?.pushViewController(navigationViewController, animated: true)
        } else {
                let trip:Trip = self.featureBundles[tableView.tag].features[indexPath.row] as! Trip
                openTrip(trip)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        print("You selected cell #\(indexPath.row)!")
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 31.0
    }
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(true, animated:false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}