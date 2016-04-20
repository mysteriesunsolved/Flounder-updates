//
//  UserMedia.swift
//  Flounderr
//
//  Created by Sanaya Sanghvi on 4/19/16.
//  Copyright © 2016 Flounderr. All rights reserved.
//

import UIKit
import Parse

 let postNotification = "postNotification"

class UserMedia: NSObject {
    
    
    //event post
        
    class func postUserPost(post: String?, user: PFUser, completion: PFBooleanResultBlock?) {
            // Create Parse object PFObject
            let media = PFObject(className: "UserMedia")
            
            // Add relevant fields to the object
            media["media"] = post! as String
            media["author"] = user
            
            media["username"] = PFUser.currentUser()!.username
        
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(postNotification, object: nil)
            // Save object (following function will save the object in Parse asynchronously)
            media.saveInBackgroundWithBlock(completion)
            
        }
    
    //carpool request
    
    class func postUserRequest(textRequest: String?, sender: PFUser, recipient: PFUser , completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        
        
        let message = PFObject(className: "Message")
        message["author"] = sender
        message["recipient"] = recipient
        message["request"] = textRequest
        
        message["likesCount"] = 0
        message["commentsCount"] = 0
        message["username"] = PFUser.currentUser()!.username
        
        message.ACL = PFACL(user: recipient) //makes it so that only the person receiving carpool requests can view it
        
        
        
        
        
        NSNotificationCenter.defaultCenter().postNotificationName(postNotification, object: nil)
        // Save object (following function will save the object in Parse asynchronously)
      
        message.saveInBackgroundWithBlock(completion)
    }
    
    //fetch event data
    class func fetchData(post: String?, completion: (posts: [PFObject]?, error: NSError? ) -> ()){
        var query: PFQuery
        
        if post != nil {
            let predicate = NSPredicate(format: post!)
            query = PFQuery(className: "UserMedia", predicate: predicate)
        } else {
            query = PFQuery(className: "UserMedia")
        }
        
        
        
        query.orderByDescending("_created_at")
        query.includeKey("author")
        query.limit = 20
        
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (media: [PFObject]?, error: NSError?) -> Void in
            if let gotmedia = media {
                print("media recieved")
                completion(posts: gotmedia, error: nil)
                
                
            } else {
                print(error?.localizedDescription)
                completion(posts: nil, error: error)
            }
        }
        
    }
    
    //fetch message - request data
    
    class func fetchMessages(message: String?, completion: (message: [PFObject]?, error: NSError? ) -> ()){
        var query: PFQuery
        
        if message != nil {
            let predicate = NSPredicate(format: message!)
            query = PFQuery(className: "Message", predicate: predicate)
        } else {
            query = PFQuery(className: "Message")
        }
        
        
        
        query.orderByDescending("_created_at")
        query.includeKey("author")
        query.limit = 20
        
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (message: [PFObject]?, error: NSError?) -> Void in
            if let gotmessage = message {
                print("message recieved")
                completion(message: gotmessage, error: nil)
                
                
            } else {
                print(error?.localizedDescription)
                completion(message: nil, error: error)
            }
        }
        
    }

    
    class func fetchMediaDetails(userMedia: NSDictionary, completion: (posts: [PFObject]?, error: NSError? ) -> ()){
        var query: PFQuery
        
        
        query = PFQuery(className: "UserMedia")
        
        
        query.getObjectInBackgroundWithId("mediaID") {
            (userMedia: PFObject?, error: NSError?) -> Void in
            if error == nil && userMedia != nil {
                print(userMedia)
                print("hi")
            } else {
                print(error)
            }
        }
    }
    
    

}

