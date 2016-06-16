import Foundation
import UIKit
import MapKit
import Eureka
import Alamofire
import p2_OAuth2
import PKHUD



public final class MultiSelectFilterRow : SelectorRow<PropertyDescriptor, PushSelectorCell<PropertyDescriptor>, MultiSelectFilterViewController>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback { return MultiSelectFilterViewController(){ _ in } }, completionCallback: {
            vc in vc.navigationController?.popViewControllerAnimated(true)
        })
        displayValueFor = {
            
            if let value = $0 {
                return  value.values?.joinWithSeparator(",")
            }else {
                return  ""
            }
            
        }
    }
}

public class MultiSelectFilterViewController : FormViewController, TypedRowControllerType, UISearchBarDelegate {
    
    public var row: RowOf<PropertyDescriptor>!
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
    
    //    public override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //         let emptyView = EmptyView()
    //        emptyView.h=1
    //        return EmptyView()
    //    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        searchBar = UISearchBar(frame: CGRectMake(0, 0, self.tableView!.frame.size.width, 44.0));
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        
        let searchHeaderView = UIView()
        let headerImage=UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        headerImage.image = UIImage(named:"DAYC_bar_bg.png")
        headerImage.contentMode = UIViewContentMode.ScaleAspectFill
        headerImage.clipsToBounds = true
        searchHeaderView.addSubview(headerImage)
        
        let magnifyingImage=UIImageView(frame: CGRectMake(25, 9, 20, 20))
        
        magnifyingImage.image = UIImage.scaleTo(image: UIImage(named:"Daycation_Magnifying_gla.png")!, w: 20, h: 20)
        magnifyingImage.contentMode = UIViewContentMode.ScaleAspectFill
        magnifyingImage.clipsToBounds = true
        searchHeaderView.addSubview(magnifyingImage)
        self.view.addSubview(searchHeaderView)
        
        searchBar.x = 50
        searchBar.y = 0
        searchBar.w = self.view.frame.size.width-100
        let searchBarBackground = UIImage.roundedImage(UIImage.imageWithColor(UIColor(hexString: "#fff9e1")!, size: CGSize(width: 28, height: 28)),cornerRadius: 0)
        searchBar.setSearchFieldBackgroundImage(searchBarBackground, forState: .Normal)
        searchBar.searchTextPositionAdjustment = UIOffsetMake(8.0, 0.0)
        searchBar.barTintColor = UIColor.clearColor()
        searchBar.backgroundColor = UIColor.clearColor()
        searchBar.backgroundImage = UIImage()
        searchBar.translucent = true
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as! UITextField
        textFieldInsideSearchBar.font = UIFont(name: "Quicksand-Bold", size: 12)
        textFieldInsideSearchBar.textColor = UIColor(hexString: "#979796")
        
        searchBar.searchBarStyle = .Prominent
        searchBar.showsCancelButton = false
        searchBar.showsSearchResultsButton = false
        
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.Never
        textFieldInsideSearchBar.w = 20
        // Give some left padding between the edge of the search bar and the text the user enters
        searchBar.searchTextPositionAdjustment = UIOffsetMake(10, 0)
        
        self.view.addSubview(searchBar)
        
        self.tableView!.y = 40
        self.tableView!.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tableView!.separatorInset = UIEdgeInsetsZero
        self.tableView!.layoutMargins = UIEdgeInsetsZero
        self.tableView!.separatorColor = UIColor(hexString: "#fff9e1")
        
        
        
        OuterspatialClient.sharedInstance.getPropertyDescriptor(row.tag!) {
            (result: PropertyDescriptor?,error: String?) in
            if let propertyDescriptor = result {
                let sortedItems = propertyDescriptor.values!.sort
                print("got back: \(result)")
                HUD.hide(afterDelay: 0)
                var header = HeaderFooterView<UIView>(.Class) // most flexible way to set up a header using any view type
                header.height = {1 }
                self.section.header = header
                self.form  +++=
                    self.section
                
                for item  in sortedItems()  as [String]{
                    self.section
                        
                        <<< CheckRow() {
                            $0.title = item
                            if (self.row.value?.values?.contains(item) == true) {
                                $0.value=true
                            }
                            }.cellSetup() {cell, row in
                                
                                self.formatCell(cell)
                                cell.indentationLevel = Int(3)
                            } .cellUpdate() {cell, row in
                                cell.textLabel?.font = UIFont(name:"Quicksand-Bold", size:20)
                                cell.textLabel?.textColor = UIColor(hexString: "#8e8e8e")
                                cell.textLabel?.highlightedTextColor = UIColor(hexString: "#8e8e8e")
                                cell.tintColor = UIColor(hexString: "#8e8e8e")
                                self.formatCell(cell)
                            }.onCellSelection { cell,row in
                                if let checked = row.baseValue  as? Bool {
                                    if checked == true {
                                        self.row.value?.values?.append(row.title!)
                                        print(self.row.value?.values)
                                    } else {
                                        
                                        self.row.value?.values? = (self.row.value?.values?.filter{$0 != row.title!})!
                                    }
                                }

                                
                    }
                    
                }
                
                
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
            self.section.reload()
        }
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        button.title = "Done"
        
        //    self.navigationItem.rightBarButtonItem = button
        updateTitle()
        
    }
    
    func formatCell(cell:BaseCell){
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.contentView.layoutMargins.left = 30
        cell.backgroundColor = UIColor(hexString: "#f7f1da")
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
        //   self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
    }
    
    func tappedDone(sender: UIBarButtonItem){
        
        for (key, value) in form.values() {
            if let property = value as? PropertyDescriptor {
                print (property)
                
                if let checked = value  as? Bool {
                    if checked == true {
                        self.row.value?.values?.append(key)
                    }
                }
            }
        }
        completionCallback?(self)
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
    class EmptyView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    func updateTitle(){
        title = row.tag!.stringByReplacingOccurrencesOfString("_", withString:" ")
    }
}