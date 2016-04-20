//
//  postViewCellTableViewCell.swift
//  Flounderr
//
//  Created by Sanaya Sanghvi on 4/19/16.
//  Copyright © 2016 Flounderr. All rights reserved.
//

import UIKit
import Parse


class postViewCellTableViewCell: UITableViewCell {
    
    //this view cell allows users to press the carpool button and send a message to the event poster 

    @IBOutlet var postLabel: UILabel!
    @IBOutlet var carpoolRequestButton: UIButton!
    
    var post: PFObject? {
        
        didSet {
            
            let postText = post!["media"] as? String
            if postText != nil {
                postLabel.text = postText
                postLabel.sizeToFit()
                
            let recipient = post!["author"] as? String
                if recipient != nil {
                    print("The author you are sending this message to is: \(recipient)")
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func onRequest(sender: AnyObject) {
        
        
        var inputTextField = UITextField?()
        var phoneTextField = UITextField?()
        
        var alert = UIAlertController(title: "Send Request?", message: "Enter your name and phone number below", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel?", style: .Cancel) { (action) -> Void in
            
        }
        
        
        
        let textfield = alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            inputTextField = textField
        }
        let phoneField = alert.addTextFieldWithConfigurationHandler { (phoneField) -> Void in
            phoneTextField = phoneField
        }
        
        alert.addAction(cancel)
        let done = UIAlertAction(title: "Done", style: .Default) { (action) -> Void in
            
            let name = inputTextField?.text
            let phoneNumber = phoneTextField!.text
            
            if (name != nil && phoneNumber != nil )
            {
                UserMedia.postUserRequest("\(name!) would like to carpool with you to an event. Contact them at \(phoneNumber!) if you agree!", sender: PFUser.currentUser()!, recipient: self.post!["author"] as! PFUser , completion: nil)
            } 
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(done)
    
        self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
   
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   

}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
                
            }
        }
        
        
        return nil
    }
}
