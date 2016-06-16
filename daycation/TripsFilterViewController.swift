
import UIKit
import Eureka
import PKHUD


class TripsFilterViewController : FormViewController{
    
    var filters: [PropertyDescriptor]?
    var completion: FilterSelectionCompletionHandler?
    convenience init(filters: [PropertyDescriptor]?,completion:FilterSelectionCompletionHandler) {
        self.init()
        self.filters = filters
        self.completion = completion
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Filter"
        
        self.view.backgroundColor = UIColor.whiteColor()
            let a = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "tappedCancel:")
            self.navigationItem.rightBarButtonItem = a
      
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        self.navigationItem.leftBarButtonItem = b
        self.tableView!.backgroundColor = UIColor(hexString: "#f7f1da")
        self.tableView!.separatorInset = UIEdgeInsetsZero
        self.tableView!.layoutMargins = UIEdgeInsetsZero
        self.tableView!.separatorStyle = .None
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRectMake(0, 0, 34, 34)
        }
        
        form  +++=
            
            Section(footer: "") {
                $0.header = HeaderFooterView<UIView>(.Class)
                $0.header!.height = {1 }
            }
            
            
            <<< MultiSelectFilterRow("species") {
                $0.title = "Related Species"
                
                if let user = OuterspatialClient.currentUser where (user.profile != nil && user.profile!.organization != nil) {
                    
                    let property=PropertyDescriptor ()
                    property.values=[]
                    $0.value = property                }
                
                }.cellSetup() {cell, row in
                    cell.selectionStyle = .None
                   
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    self.formatCell(cell)
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            
            <<< MultiSelectFilterRow("activities") {
                $0.title = "Related Activities"
                let property=PropertyDescriptor ()
                
                 $0.value = property
                
                }.cellSetup() {cell, row in
                    cell.selectionStyle = .None
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    self.formatCell(cell)
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
                
            }
            <<< SwitchRow("park") {
                $0.title = "Park"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                    
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("trail") {
                $0.title = "Trail"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("natural_area") {
                $0.title = "Natural Area"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("body_of_water") {
                $0.title = "Body of Water"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("business") {
                $0.title = "Business"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            
            <<< MultiSelectFilterRow("difficulty") {
                $0.title = "Difficulty"
                let property=PropertyDescriptor ()
                
                $0.value = property
                
                }.cellSetup() {cell, row in
                    cell.selectionStyle = .None
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    self.formatCell(cell)
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
                    
            }
            
            <<< MultiSelectFilterRow("duration") {
                $0.title = "Duration"
                let property=PropertyDescriptor ()
                
                $0.value = property
                
                }.cellSetup() {cell, row in
                    cell.selectionStyle = .None
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    self.formatCell(cell)
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
                    
            }
            
            <<< MultiSelectFilterRow("best_time_to_go") {
                $0.title = "Best Time to Go"
                let property=PropertyDescriptor ()
                
                $0.value = property
                
                }.cellSetup() {cell, row in
                    cell.selectionStyle = .None
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    self.formatCell(cell)
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
                    
            }
            
            <<< MultiSelectFilterRow("suitable_for_kids") {
                $0.title = "Suitable for Kids"
                let property=PropertyDescriptor ()
                
                $0.value = property
                
                }.cellSetup() {cell, row in
                    cell.selectionStyle = .None
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    self.formatCell(cell)
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
                    
            }
            <<< SwitchRow("great_for_groups") {
                $0.title = "Great for Groups"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("includes_food_and_beverage") {
                $0.title = "Includes Food and Beverage"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("accessible") {
                $0.title = "Accessible"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
        }
    }
    
    
    func formatCell(cell:BaseCell){
        if let switchCell = cell as? SwitchCell {
            
            switchCell.switchControl?.tintColor = UIColor(hexString: "#d3ceb9")
            switchCell.switchControl?.thumbTintColor = UIColor(hexString: "#d3ceb9")
            switchCell.switchControl?.onTintColor = UIColor(hexString: "#bafb9a")
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.contentView.layoutMargins.left = 30
        cell.backgroundColor = UIColor(hexString: "#f7f1da")
        cell.selectionStyle = .None
    }
    
    override func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath)
    {
        guard tableView == self.tableView else { return }
        form[indexPath].updateCell()
        cell.textLabel?.frame = CGRectMake(0,
                                           0,
                                           cell.frame.size.width,
                                           20)
        
        guard cell.subviews[cell.subviews.count-1].dynamicType != UIImageView.self else { return }
        let separatorImage=UIImageView(frame: CGRectMake(0,
            cell.frame.size.height - 2,
            cell.frame.size.width,
            2))
        separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        separatorImage.clipsToBounds = true
        separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        cell.addSubview(separatorImage)
    }
    
    func tappedDone(sender: UIBarButtonItem){
        
        var filters = [PropertyDescriptor]()
        
        for (key, value) in form.values() {
            if let property = value as? PropertyDescriptor {
                if let values = property.values  {
                    property.key = key
                filters.append(property)
                }
            }
        }
        
        completion!(filters: filters)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func tappedCancel(sender: UIBarButtonItem){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#f7f1da")
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
}