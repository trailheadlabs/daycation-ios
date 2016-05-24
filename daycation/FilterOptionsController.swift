import Foundation
import UIKit
import MapKit
import Eureka
import Alamofire
import p2_OAuth2
import PKHUD



public final class FilterOptionsRow : SelectorRow<Organization, PushSelectorCell<Organization>, FilterOptionsViewController>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return FilterOptionsViewController(){ _ in } }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
        displayValueFor = {
            if let value = $0 {
                return  value.name
            }else {
                return  ""
            }
            
        }
    }
}

public class FilterOptionsViewController : FormViewController, TypedRowControllerType {
    
    public var row: RowOf<Organization>!
    public var completionCallback : ((UIViewController) -> ())?
    
    public var section = Section()
    
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
        
        OuterspatialClient.sharedInstance.getPropertyDescriptor("species") {
            (result: PropertyDescriptor?,error: String?) in
            if let propertyDescriptor = result {
                print("got back: \(result)")
                HUD.hide(afterDelay: 0)
                
                self.form  +++=
                    self.section
                for value in propertyDescriptor.values! {
                    self.section
                        <<< CheckRow() {
                            $0.title = value
                            }.onCellSelection { cell,ce in
                                //self.completionCallback?(self)
                    }
                    
                }
                
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        button.title = "Done"
        
        self.navigationItem.rightBarButtonItem = button
        if let value = row.value {
        }
        else{
        }
        updateTitle()
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func tappedDone(sender: UIBarButtonItem){
        
        completionCallback?(self)
    }
    
    func updateTitle(){
        title = "Organization"
    }
}