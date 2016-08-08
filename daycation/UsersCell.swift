    
    class UserView: UITableViewCell {
        var profileImageView:UIImageView?
        var contributorText: UILabel!
        var dateText: UILabel!
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.profileImageView=UIImageView(frame: CGRectMake(20, 10, 60, 60))
            self.profileImageView!.layer.borderWidth = 1
            self.profileImageView!.layer.masksToBounds = false
            self.profileImageView!.layer.borderColor = UIColor.blackColor().CGColor
            self.profileImageView!.layer.cornerRadius = self.profileImageView!.frame.height/2
            self.profileImageView!.clipsToBounds = true
            self.addSubview(profileImageView!)
            
            contributorText = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:10, width:self.w-profileImageView!.rightOffset(5)-5, height:10))
            contributorText.font = UIFont(name: "Quicksand-Bold", size: 14)
            contributorText.textColor = UIColor(hexString: "#e09b1b")
            contributorText.numberOfLines = 1
            self.addSubview(contributorText)
            
            dateText = UILabel(frame: CGRectMake(profileImageView!.rightOffset(5),30,self.w-profileImageView!.rightOffset(5)-5, 10))
            dateText.textColor = UIColor.lightGrayColor()
            dateText.font = UIFont(name: "Quicksand-Regular", size: 14)
            
            self.addSubview(dateText!)
            
            self.backgroundColor = UIColor(hexString: "#fff9e1")
        }
        func setUser(user: User) {
            self.profileImageView!.hnk_setImageFromURL(user.profile!.imageUrl!)
            var text = ""
            var attributedString:NSMutableAttributedString=NSMutableAttributedString()
            if let abbreviatedName = user.profile!.abbreviatedName{
                text = "\(abbreviatedName)"
                if let organization = user.profile?.organization?.name{
                    text += " | \(organization)"
                    attributedString = NSMutableAttributedString(string:text)
                    var range = (text as NSString).rangeOfString("|")
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#949494")! , range: range)
                    range = (text as NSString).rangeOfString(organization)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#585858")! , range: range)
                } else {
                    
                    attributedString = NSMutableAttributedString(string:text)
                }
                
                
            }
            
            self.contributorText.attributedText = attributedString
            
            self.contributorText.fitHeight()
            
            
        }
        func setDate(post: Post) {
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .ShortStyle
            dateText.text = formatter.stringFromDate(post.createdAt!)
            
            dateText.fitHeight()
            
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
            