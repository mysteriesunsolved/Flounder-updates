//
//  HomeViewController.swift
//  Flounderr
//
//  Created by Sanaya Sanghvi on 4/19/16.
//  Copyright © 2016 Flounderr. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    //this is where the user can view posts and send carpool requests

    
    @IBOutlet var tableView: UITableView!
    
    var posts = [PFObject]?()
    
    var refreshControl = UIRefreshControl()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.tintColor = UIColor .blueColor()
        tableView.addSubview(refreshControl)
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UserMedia.fetchData(nil, completion: {(posts, error) -> () in
            print("I'm here")
            self.posts = posts
            self.tableView.reloadData()
            print(posts)
        })
        self.tableView.reloadData()
        print("check3")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if posts != nil {
            return posts!.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postViewCell", forIndexPath: indexPath) as! postViewCellTableViewCell
        
        let post = posts![indexPath.row]
        
        cell.post = post
        
                
        print("cell should post")
        
        return cell
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        UserMedia.fetchData(nil, completion: {(posts, error) -> () in
            
            self.posts = posts
            
            self.tableView.reloadData()
        })
        
    }
    
    
    @IBAction func dismissButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
