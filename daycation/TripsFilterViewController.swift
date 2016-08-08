
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
            let a = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: "tappedCancel:")
        self.navigationItem.rightBarButtonItem = a
        a.setTitlePositionAdjustment(UIOffset.init(horizontal: -15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
            a.setTitleTextAttributes([NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:14)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        let b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
         b.setTitlePositionAdjustment(UIOffset.init(horizontal: 15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
            b.setTitleTextAttributes([NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:14)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
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
                
                    setMultiCellValue($0)
                
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
                setMultiCellValue($0)
                
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
              setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                    
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
                }
            <<< SwitchRow("trail") {
                $0.title = "Trail"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("natural_area") {
                $0.title = "Natural Area"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("body_of_water") {
                $0.title = "Body of Water"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            
            <<< SwitchRow("refreshment") {
                $0.title = "Includes Food and Beverage"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("accessible") {
                $0.title = "Accessible"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< MultiSelectFilterRow("physical_features") {
                $0.title = "Physical Features"
                setMultiCellValue($0)
                
                
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
                setMultiCellValue($0)
                
                
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
                setMultiCellValue($0)
                
                
                }.cellSetup() {cell, row in
                    cell.selectionStyle = .None
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    self.formatCell(cell)
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
                    
            }
            
            
            <<< SwitchRow("suitable_for_young_children") {
                $0.title = "Suitable for Young Children"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("suitable_for_elderly") {
                $0.title = "Suitable for Elderly"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("suitable_for_wheeled_devices") {
                $0.title = "Suitable for Wheeled Devices"
                setSwitchCellValue($0)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textLabel!.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textLabel!.textColor = UIColor(hexString: "#8e8e8e")
            }
            <<< SwitchRow("dogs") {
                $0.title = "Dogs"
                setSwitchCellValue($0)
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
    func setMultiCellValue(row:MultiSelectFilterRow){
        
        if let i = filters!.indexOf({$0.key == row.tag}) {
            row.value = filters![i]
        } else {
            
            let property=PropertyDescriptor ()
            property.values=[]
            row.value = property
        }
    }
    func setSwitchCellValue(row:SwitchRow){
        
        if let i = filters!.indexOf({$0.key == row.tag}) {
            row.value = true
        }
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
                if let values = property.values where values.count>0{
                    property.key = key
                    filters.append(property)
                }
            }
            if let checked = value as? Bool {
                if checked == true  {
                    let property=PropertyDescriptor( )
                    property.key = key
                    property.values = ["yes"]
                    
                    filters.append(property)
                }
            }
        }
        
        completion!(filters: filters)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func tappedCancel(sender: UIBarButtonItem){
        completion!(filters: [PropertyDescriptor]())
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#f7f1da")
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
}