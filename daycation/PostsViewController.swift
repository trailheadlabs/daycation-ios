import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD
import ICSPullToRefresh

class  PostsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    
    var posts = [Post]()
    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Stream"
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        actInd.startAnimating()
        let b = UIBarButtonItem(title: "Post", style: .Plain, target: self, action:#selector(PostsViewController.tappedAdd(_:)))
        
        b.setTitlePositionAdjustment(UIOffset.init(horizontal: -15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.rightBarButtonItem = b
        tableView = UITableView(frame: CGRectMake( 0, 64, self.view.frame.size.width, self.view.frame.size.height-(44+20+49)))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.backgroundColor = UIColor(hexString: "#fff9e1")
       // tableView.rowHeight = 100.0
      //  self.tableView.estimatedRowHeight = 88.0
      //  self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerClass(PostsViewCell.self, forCellReuseIdentifier: "cell")
        
        OuterspatialClient.sharedInstance.getPosts(page,parameters: [:]) {
            (result: [Post]?,error: String?) in
            if let posts = result {
                print("got back: \(result)")
                self.posts = posts
                self.view.addSubview(self.tableView)
                actInd.stopAnimating()
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        
        self.tableView.addPullToRefreshHandler {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    OuterspatialClient.sharedInstance.getPosts(1,parameters: [:]) {
                        (result: [Post]?,error: String?) in
                        if let posts = result {
                            print("got back: \(result)")
                            var latestPostId = self.posts[0].id
                            for post in posts {
                                if post.id>latestPostId {
                                    self.posts.insert(post, atIndex: 0)
                                    latestPostId=post.id
                                }
                                
                            }
                            
                            self.tableView.reloadData()
                            self.tableView.pullToRefreshView?.stopAnimating()
                        }
                        if let error = error{
                            HUD.flash(.Label(error), delay: 2.0)
                        }
                    }
                    })
            })
        }
        
        self.tableView.addInfiniteScrollingWithHandler {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.page++
                    OuterspatialClient.sharedInstance.getPosts(self.page,parameters: [:]) {
                        (result: [Post]?,error: String?) in
                        if let posts = result {
                            print("got back: \(result)")
                            
                            self.posts.appendContentsOf(posts)
                            
                            self.tableView.reloadData()
                            self.tableView.infiniteScrollingView?.stopAnimating()
                        }
                        if let error = error{
                            HUD.flash(.Label(error), delay: 2.0)
                        }
                    }
                    })
            })
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:PostsViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as! PostsViewCell
        let post:Post = self.posts[indexPath.row]
        cell.loadItem(post)
        
        return cell
    }
    
    func addNewPost(post: Post) {
        self.posts.insert(post, atIndex: 0)
        self.tableView.reloadData()
    }
    
    func removePost(post: Post) {
        self.posts = self.posts.filter({
            $0.id != post.id
        })
        self.tableView.reloadData()
    }

    func tappedAdd(sender: UIBarButtonItem){
       let navigationController = UINavigationController(rootViewController: PostCreateViewController(completionBlock: addNewPost))
       self.presentViewController( navigationController, animated: true, completion: nil)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let post = posts[indexPath.row]
        let navigationViewController = PostDetailViewController(post: post, completionBlock: removePost)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.navigationController?.pushViewController(navigationViewController, animated: true)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        
        self.navigationController?.navigationBar.translucent = true
        
        let backgroundImage = UIImage(named:"DAYC_BLUE_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage,
                                                                    forBarMetrics: .Default)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tableView.pullToRefreshView?.stopAnimating()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}