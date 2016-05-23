import Foundation
import UIKit
import MapKit
import Eureka
import Alamofire
import p2_OAuth2
import PKHUD



public final class LoctionRow : SelectorRow<Organization, PushSelectorCell<Organization>, OrganizationViewController>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return OrganizationViewController(){ _ in } }, completionCallback: { vc in vc.navigationController?.popViewControllerAnimated(true) })
        displayValueFor = {
            if let value = $0 {
              return  value.name
           }else {
               return  ""
            }
            
        }
    }
}

public class OrganizationViewController : FormViewController, TypedRowControllerType, UISearchBarDelegate {
    
    public var row: RowOf<Organization>!
    public var completionCallback : ((UIViewController) -> ())?
    
    var searchBar: UISearchBar!
    var searchActive : Bool = false
    var organizations = [Organization]()
    var filtered = [Organization]()
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
        searchBar = UISearchBar(frame: CGRectMake(0, 0, self.tableView!.frame.size.width, 44.0));
        searchBar.placeholder = "Search Intertwine Partner Organizations"
        searchBar.delegate = self
        self.view.addSubview(searchBar)
        self.tableView!.y = 40
        self.tableView!.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tableView!.separatorInset = UIEdgeInsetsZero
        self.tableView!.layoutMargins = UIEdgeInsetsZero
        self.tableView!.separatorColor = UIColor(hexString: "#fff9e1")
        OuterspatialClient.sharedInstance.getOrganizations() {
            (result: [Organization]?,error: String?) in
            if let organizations = result {
                print("got back: \(result)")
                HUD.hide(afterDelay: 0)
                
                self.form  +++=
                    self.section
                for organization in organizations {
                    self.section
                        <<< CheckRow() {
                            $0.title = organization.name
                            if (self.row.value?.id == organization.id){
                                $0.value = true
                                
                            }
                            }.onCellSelection { cell,ce in print( " 3 ")
                                self.row.value = organization
                                self.completionCallback?(self)
                    }
                    
                }

            }
            if let error = error{
                HUD.flash(.Label(error), withDelay: 2.0)
            }
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        button.title = "Done"
        
        self.navigationItem.rightBarButtonItem = button
        updateTitle()
        
    }
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.characters.count == 0) {
            
            for row in form.allRows {
                
                row.hidden = false
                row.evaluateHidden()
            }
        } else {
            for row in form.allRows {
                let tmp: NSString = row.title!
                let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                if  range.location != NSNotFound {
                    row.hidden = false
                    row.evaluateHidden()
                } else {
                    row.hidden = true
                    row.evaluateHidden()
                }
            }
        }
    }
    override public func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:true)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
    }
    
    func tappedDone(sender: UIBarButtonItem){

        completionCallback?(self)
    }
    
    func updateTitle(){
        title = "Organization"
    }
}