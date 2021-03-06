import MapKit
import UIKit
import Eureka
import PKHUD


typealias PostCompletionHandler = (post: Post) -> Void
class  PostCreateViewController : FormViewController{
    
    var completion:PostCompletionHandler?
    
    convenience init( completionBlock: PostCompletionHandler) {
        self.init()
        self.completion=completionBlock
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = " Create Post"
        
        self.view.backgroundColor = UIColor.whiteColor()
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "tappedDone:")
        self.navigationItem.rightBarButtonItem = b
        
        let a = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "tappedCancel:")
        self.navigationItem.leftBarButtonItem = a
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRectMake(0, 0, 34, 34)
        }
        form  +++=
            
            Section(""){
                
                $0.header = HeaderFooterView<UIView>(.Class)
                let headerView = $0.header?.viewForSection($0, type: HeaderFooterType.Header, controller: self)
                headerView!.h = 1
                
                
                $0.footer = HeaderFooterView<UIView>(.Class)
                let FooterView = $0.header?.viewForSection($0, type: HeaderFooterType.Footer, controller: self)
                 FooterView!.h = 1
                let separatorImage=UIImageView(frame: CGRectMake( 0, 2, self.view.frame.size.width, 5))
                separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
                separatorImage.clipsToBounds = true
                separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
                FooterView!.addSubview(separatorImage)
            }
            
            <<< TextAreaRow("postText") {
                $0.placeholder = "Post text"
                
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                    cell.textView.font = UIFont(name:"Quicksand-Regular", size:20)
                    
                    cell.placeholderLabel.alpha = 0.5
                    cell.placeholderLabel.font = UIFont(name:"Quicksand-Regular", size:20)
                    cell.placeholderLabel.textColor = UIColor(hexString: "#8e8e8e")
                    cell.textView.textColor = UIColor(hexString: "#8e8e8e")
                    cell.textView.backgroundColor = UIColor(hexString: "#fff9e1")
                }
                .cellUpdate() {cell, row in
                    cell.textView.font = UIFont(name:"Quicksand-Regular", size:20)
                    cell.textView.textColor = UIColor(hexString: "#8e8e8e")
        }
        form  +++=
            
            Section(""){
                
                $0.header = HeaderFooterView<UIView>(.Class)
                let headerView = $0.header?.viewForSection($0, type: HeaderFooterType.Header, controller: self)
                headerView!.h = 1
                
                
                $0.footer = HeaderFooterView<UIView>(.Class)
                let FooterView = $0.header?.viewForSection($0, type: HeaderFooterType.Footer, controller: self)
                FooterView!.h = 1
                let separatorImage=UIImageView(frame: CGRectMake( 0, 2, self.view.frame.size.width, 5))
                separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
                separatorImage.clipsToBounds = true
                separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
                FooterView!.addSubview(separatorImage)
            }
            <<< LocationRow("location"){
                $0.title = "Location"
                if let locValue =  LocationData.locValue {
                    $0.value = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
                }
                }.cellSetup() {cell, row in
                     cell.detailTextLabel!.hidden=true
                    let markerImage=UIImageView(frame: CGRectMake(cell.w-5, 12, 20, 20))
                    markerImage.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Map_marker@3x.png")!, w: 20, h: 20)
                    cell.addSubview(markerImage)

                    self.formatCell(cell)
                    cell.indentationLevel = Int(3)
                } .cellUpdate() {cell, row in
                    cell.textLabel?.alpha = 0.5
                    cell.textLabel?.font = UIFont(name:"Quicksand-Regular", size:20)
                    cell.textLabel?.textColor = UIColor(hexString: "#8e8e8e")
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#8e8e8e")
                    
                    cell.detailTextLabel!.hidden=true
                    self.formatCell(cell)
            }
        form  +++=
            
            Section(""){
                
                $0.header = HeaderFooterView<UIView>(.Class)
                let headerView = $0.header?.viewForSection($0, type: HeaderFooterType.Header, controller: self)
                headerView!.h = 1
                
                
            }
            <<< CustomImageRow("image"){
                $0.title = ""
                }.cellSetup() {cell, row in
                    cell.height =  {return CGFloat(150)}
                    
                    cell.chosenImage=UIImageView(frame: CGRectMake(50, 30, 40, 40))
                    cell.addSubview( cell.chosenImage!)
                    cell.chooseLabel = UILabel(frame: CGRect(x: 0, y:  cell.chosenImage!.bottomOffset(10), width: self.view.w, height: 40))
                    
                    cell.chooseLabel!.text = "Add Photo"
                    cell.chooseLabel!.textColor = UIColor(hexString: "#8e8e8e")
                    cell.chooseLabel!.font = UIFont(name: "Quicksand-Regular", size: 14)
                    cell.chooseLabel!.fitSize()
                    cell.chooseLabel!.x = ( cell.chosenImage!.right - cell.chosenImage!.w/2)-cell.chooseLabel!.w/2
                    cell.addSubview(cell.chooseLabel!)
                    self.formatCell(cell)
                    cell.indentationLevel = Int(3)
                    cell.accessoryView = nil
                } .cellUpdate() {cell, row in
                    
                    cell.accessoryView = nil
                    if let chosenImage = row.baseValue as? UIImage {
                        cell.chooseLabel!.text = "Change Photo"
                        cell.chooseLabel!.fitSize()
                        cell.chooseLabel!.x = ( cell.chosenImage!.right - cell.chosenImage!.w/2)-cell.chooseLabel!.w/2
                        cell.chosenImage!.image = chosenImage
                    } else {
                        
                        cell.chooseLabel!.text = "Add Photo"
                        cell.chooseLabel!.fitSize()
                        cell.chooseLabel!.x = ( cell.chosenImage!.right - cell.chosenImage!.w/2)-cell.chooseLabel!.w/2
                        
                        cell.chosenImage!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Add_photo@3x.png")!, w: 40, h: 40)
                    }
                    cell.textLabel?.alpha = 0.5
                    cell.textLabel?.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel?.textColor = UIColor(hexString: "#8e8e8e")
                    cell.textLabel?.highlightedTextColor = UIColor(hexString: "#8e8e8e")
                    
                    self.formatCell(cell)
        }
        
        self.tableView!.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tableView!.separatorInset = UIEdgeInsetsZero
        self.tableView!.layoutMargins = UIEdgeInsetsZero
        self.tableView!.separatorColor = UIColor(hexString: "#fff9e1")
        
        
    }

    public final class CustomImageRow : _ImageRow<CustomPushSelectorCell<UIImage>>, RowType {
        public required init(tag: String?) {
            super.init(tag: tag)
        }
    }

    func formatCell(cell:BaseCell){
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.contentView.layoutMargins.left = 30
        cell.backgroundColor = UIColor(hexString: "#fff9e1")
    }
    
    
    func tappedDone(sender: UIBarButtonItem){
        
        let post:Post = Post()
        var valid:Bool = true
        if let postText =  self.form.values()["postText"] as? String {
            post.postText=postText
        }else{
            valid = false
        }
        if let location = self.form.values()["location"]  as? CLLocation {
            post.location=location
        }
        if let image = self.form.values()["image"]  as? UIImage {
            post.image=image
        }
        HUD.show(.Progress)
        OuterspatialClient.sharedInstance.createPost(post){
            (result: Post?, error: String?) in
            print("got back: \(result)")
            self.completion!(post: result!)
            HUD.hide(afterDelay: 0)
            self.dismissViewControllerAnimated(false, completion: nil)
            
            
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        
    }
    
    
    func tappedCancel(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        let backgroundImage = UIImage(named:"DAYC_BLUE_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage,
                                                                    forBarMetrics: .Default)
    }
}

public class CustomImageSelectorCell<T: Equatable> : Cell<T>, CellType {
    public var chosenImage:UIImageView?
    
    public var chooseLabel:UILabel?
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func update() {
        super.update()
        
        selectionStyle =  .None
    }
}


public class CustomPushSelectorCell<T: Equatable> : Cell<T>, CellType {
    
    public var chooseLabel:UILabel?
    public var chosenImage:UIImageView?
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func update() {
        super.update()
        
        accessoryType = .None
        editingAccessoryType = accessoryType
        selectionStyle =  .None
    }
}

public final class LocationRow : SelectorRow<CLLocation, CustomPushSelectorCell<CLLocation>, MapViewController>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return MapViewController(){ _ in } }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NSNumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.stringFromNumber(location.coordinate.latitude)!
            let longitude = fmt.stringFromNumber(location.coordinate.longitude)!
            return  "\(latitude), \(longitude)"
        }
    }
}

public class MapViewController : UIViewController, TypedRowControllerType, MKMapViewDelegate {
    
    public var row: RowOf<CLLocation>!
    public var completionCallback : ((UIViewController) -> ())?
    
    lazy var mapView : MKMapView = { [unowned self] in
        let v = MKMapView(frame: self.view.bounds)
        v.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        return v
        }()
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        v.image = UIImage(named: "map_pin", inBundle: NSBundle(forClass: MapViewController.self), compatibleWithTraitCollection: nil)
        v.image = v.image?.imageWithRenderingMode(.AlwaysTemplate)
        v.tintColor = self.view.tintColor
        v.backgroundColor = .clearColor()
        v.clipsToBounds = true
        v.contentMode = .ScaleAspectFit
        v.userInteractionEnabled = false
        return v
        }()
    
    let width: CGFloat = 10.0
    let height: CGFloat = 5.0
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalInRect: CGRectMake(0 , 0, self.width, self.height))
        return ellipse
        }()
    
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRectMake(0, 0, self.width, self.height)
        layer.path = self.ellipse.CGPath
        layer.fillColor = UIColor.grayColor().CGColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.grayColor().CGColor
        return layer
        }()
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        button.title = "Done"
        navigationItem.rightBarButtonItem = button
        
        if let value = row.value {
            let region = MKCoordinateRegionMakeWithDistance(value.coordinate, 400, 400)
            mapView.setRegion(region, animated: true)
        }
        else{
            mapView.showsUserLocation = true
        }
        updateTitle()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        let center = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: pinView)
        pinView.center = CGPointMake(center.x, center.y - (CGRectGetHeight(pinView.bounds)/2))
        ellipsisLayer.position = center
        
        let backgroundImage = UIImage(named:"DAYC_BLUE_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage,
                                                                    forBarMetrics: .Default)
    }
    
    
    func tappedDone(sender: UIBarButtonItem){
        let target = mapView.convertPoint(ellipsisLayer.position, toCoordinateFromView: mapView)
        row.value? = CLLocation(latitude: target.latitude, longitude: target.longitude)
        completionCallback?(self)
    }
    
    func updateTitle(){
        let fmt = NSNumberFormatter()
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 4
        let latitude = fmt.stringFromNumber(mapView.centerCoordinate.latitude)!
        let longitude = fmt.stringFromNumber(mapView.centerCoordinate.longitude)!
        title = "\(latitude), \(longitude)"
    }
    
//    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        
//        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
//        pinAnnotationView.pinColor = MKPinAnnotationColor.Red
//        pinAnnotationView.draggable = false
//        pinAnnotationView.animatesDrop = true
//        return pinAnnotationView
//    }
//    
    public func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.pinView.center = CGPointMake(self!.pinView.center.x, self!.pinView.center.y - 10)
            })
    }
    
    public func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.pinView.center = CGPointMake(self!.pinView.center.x, self!.pinView.center.y + 10)
            })
        updateTitle()
    }
}
