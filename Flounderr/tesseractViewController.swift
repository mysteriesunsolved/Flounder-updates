//
//  tesseractViewController.swift
//  Flounderr
//
//  Created by Sanaya Sanghvi on 3/22/16.
//  Copyright © 2016 Flounderr. All rights reserved.
//


import UIKit
import Foundation
import Parse

//Tesseract infor learnt from Ray Wenderlich tutorial

//this is where the user uses tesseract and posts an event

class tesseractViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
   
    @IBOutlet var eventTimeText: UITextField!
    @IBOutlet var eventNameText: UITextField!
    @IBOutlet var dateText: UITextField!
    @IBOutlet var eventAddressText: UITextField!
    @IBOutlet var departTimeText: UITextField!
    
    @IBOutlet var leavingFromText: UITextField!
    
    @IBOutlet var recognisedTextView: UITextView!
    
    @IBOutlet var nameText: UITextField!
    var activityIndicator:UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.eventNameText.delegate = self
        
        //instantiates camera on first glance if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.Camera)
        {
            let instantiateCamera = UIImagePickerController()
            instantiateCamera.delegate = self
            instantiateCamera.sourceType = .Camera
            self.presentViewController(instantiateCamera, animated: true, completion: nil)
        }
        //don't need an else. If no camera, goes to default view. Should this be under view did load?
        //How can I make this more interactive like the snapchat camera?
        //Will look into a tutorial on it.
        
        recognisedTextView.hidden = true
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    //lets you take a picture
    @IBAction func takePhoto(sender: AnyObject) {
        
        let choiceController = UIAlertController(title: "Snap or Upload a Picture?", message: nil, preferredStyle: .ActionSheet)
        
        //in case no camera is available inititially. Also if the person decides to choose a picture, and then decides against it, wanting to click a picture instead. Option should be available
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera)
        {
            let takePictureOption = UIAlertAction(title: "Take photo", style: .Default) { (UIAlertAction) -> Void in
                let instantiateCamera = UIImagePickerController()
                instantiateCamera.delegate = self
                instantiateCamera.sourceType = .Camera
                self.presentViewController(instantiateCamera, animated: true, completion: nil)
            }
            choiceController.addAction(takePictureOption)
        }
        //no else if because you might not always want to snap a picture right?
        //don't need an if for photolibrary, since this is the default option if no camera is available at all
        
        let cameraRollOption = UIAlertAction(title: "Choose from camera Roll", style: .Default) { (UIAlertAction) -> Void in
            let instantiateLibrary = UIImagePickerController()
            instantiateLibrary.delegate = self
            instantiateLibrary.sourceType = .PhotoLibrary
            self.presentViewController(instantiateLibrary, animated: true, completion: nil)
        }
        //even if camera is available library button will always be there
        //adding directly to the function
        
        choiceController.addAction(cameraRollOption)
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .Cancel) { (UIAlertAction) -> Void in
            //automatic cancel stuff
        }
        choiceController.addAction(cancelOption)
        
        //have to present the choice controller or code crashes (obviously)
        presentViewController(choiceController, animated: true, completion: nil)
        
    }
    
    //Activity indicator. Might replace with MBDHUD
    func addActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(frame: view.bounds)
    activityIndicator.activityIndicatorViewStyle = .WhiteLarge
    activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }

    //need to scale image for tesseract
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension // if width is too big, scale width
            scaledSize.height = scaledSize.width * scaleFactor // scale with respect to width. We don't make it equal to maxDimension as that might stretch the image vertically and blur it. There is no min dimension
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension // if height is too big, scale height
            scaledSize.width = scaledSize.height * scaleFactor // aspect ratio thing. Ray Wenderlich explained this formula well
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func performImageRecognition(image: UIImage)
    {
        let tesseract = G8Tesseract()
        
        tesseract.language = "eng+fra"
        
        
        
        tesseract.engineMode = .CubeOnly
        //Tesseract only = fast but less accurate
        //Cubeo only = slow but more accurate
        //Both combined = more slow but way more accurate which is what we want or maybe not. Takes too much time. Easy text edit makes up for lack of accuracy and more convenience as less time taken and half is already right for them.
        
        tesseract.pageSegmentationMode = .Auto
        
        //detects paragraph -> detects new lines. Could try to make it choose the first line only as title. Then perform a second recogniton or not -> will take too much time. Will test with other modes as well.
        //Once formatted, we could detect what is what or even allow user input to detect. 
        //Like choose title, etc.
        //Date will already be put in if it's only one. If more than one create a start date and end date
        
        tesseract.maximumRecognitionTime = 3*60.0
        //this does practically nothing. TesseractCubeCombined engine will take its own sweet time. If done within 3 minutes, displays entire thing, if not, displays what little it recognise. Might consider reducing time by converting to cube engine. It is pretty accurate as well. And we need some accuracy so cube engine it is. This is why our text is editable.
        
        tesseract.image = image.g8_blackAndWhite()
        //increases contrast and exposure automatically
        
        tesseract.charWhitelist = "01234567890";
        
        tesseract.recognize()// creates recognised text as part of tesseract I think. Also is of type bool. Hmm, further understanding would be cool
        
        
        recognisedTextView.autocorrectionType = UITextAutocorrectionType.Default
        recognisedTextView.text = tesseract.recognizedText
        recognisedTextView.editable = true
        print("hi")
        
            let input = recognisedTextView.text as String
        
        let regex1 = try! NSRegularExpression(pattern: "Jan(uary)?", options: NSRegularExpressionOptions.CaseInsensitive)
               //get hanuel to type this up
        let name1 = regex1.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name1 != nil {
            
            print("January")
            dateText.text = "January"

        }
        
        let regex2 = try! NSRegularExpression(pattern: "Feb(rurary)?", options: NSRegularExpressionOptions.CaseInsensitive)
       

        
        let name2 = regex2.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name2 != nil {
            
            print("February")
            dateText.text = "February"
            
        }
        
        let regex3 = try! NSRegularExpression(pattern: "Mar(ch)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name3 = regex3.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name3 != nil {
            
            print("March")
            dateText.text = "March"
            
        }
        let regex4 = try! NSRegularExpression(pattern: "Apr(il)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name4 = regex4.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name4 != nil {
            
            print("April")
            dateText.text = "April"
            
        }
        let regex5 = try! NSRegularExpression(pattern: "May", options: NSRegularExpressionOptions.CaseInsensitive)
        let name5 = regex5.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name5 != nil {
            
            print("May")
            dateText.text = "May"
            
        }
        
        let regex6 = try! NSRegularExpression(pattern: "Jun(e)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name6 = regex6.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name6 != nil {
            
            print("June")
            dateText.text = "June"
            
        }
        let regex7 = try! NSRegularExpression(pattern: "Jul(y)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name7 = regex7.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name7 != nil {
            
            print("July")
            dateText.text = "July"
            
        }

        let regex8 = try! NSRegularExpression(pattern: "Aug(ust)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name8 = regex8.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name8 != nil {
            
            print("August")
            dateText.text = "August"
            
        }
        let regex9 = try! NSRegularExpression(pattern: "Sep(tember)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name9 = regex9.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name9 != nil {
            
            print("September")
            dateText.text = "September"
            
        }
        let regex10 = try! NSRegularExpression(pattern: "Oct(tober)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name10 = regex10.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name10 != nil {
            
            print("October")
            dateText.text = "October"
            
        }
        let regex11 = try! NSRegularExpression(pattern: "Nov(ember)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name11 = regex11.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name11 != nil {
            
            print("November")
            dateText.text = "November"
            
        }
        let regex12 = try! NSRegularExpression(pattern: "Dec(ember)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name12 = regex12.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name12 != nil {
            
            print("December")
            dateText.text = "December"
            
        }
        
        //temporary fix till extraction can be carried out effecively in swift 2.0.
        let regex13 = try! NSRegularExpression(pattern: "2016", options: NSRegularExpressionOptions.CaseInsensitive)
        let name13 = regex13.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name13 != nil {
            
            dateText.text? = dateText.text! + "2016"
            
        }
        let regex14 = try! NSRegularExpression(pattern: "2017", options: NSRegularExpressionOptions.CaseInsensitive)
        let name14 = regex14.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name14 != nil {
            
            print("2017")
            dateText.text? = dateText.text! + "2016"
            
        }
        let regex15 = try! NSRegularExpression(pattern: "2013", options: NSRegularExpressionOptions.CaseInsensitive)
        let name15 = regex15.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name15 != nil {
            
            dateText.text? = dateText.text! + " " + "2013"
            
        }
        
        //it gets the wrong address because of Tesseract's Crappy Recognition but if it was like England or something, it would recognise AND extract. So success I guess.
        let pattern = "[a-zA-Z]+[,]\\s*([A-Z]{2})"
        let resultFinal = String(regMatchGroup(pattern, text: recognisedTextView.text))
        
        //to get the date if written in 3/4/16 format but doesn't work properly with what we have
        let pattern1 = "(\\d{1,2}[-/.]\\d{1,2}[-/.]\\d{1,2})|(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?)\\s*(\\d{1,2}(st|nd|rd|th)?+)?[,]\\s*\\d{4}"
        let resultFinal1 = String(regMatchGroup(pattern1, text: recognisedTextView.text))

        print(resultFinal)
        eventAddressText.text = resultFinal
        print(resultFinal1)
        removeActivityIndicator()
        
        
        
    }

    
    //once image picked you want activity indicator to show right?
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        addActivityIndicator()
        
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 640) // gets modified image returned from the function
        
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            self.performImageRecognition(scaledImage)
        })
        
        
    }
    
    //extract matching pieces of text like the address
    func regMatchGroup(regex: String, text: String) -> [[String]] {
    
            var resultsFinal = [[String]]()
            let regex = try? NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex!.matchesInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            for result in results {
                var internalString = [String]()
                for var i = 0; i < result.numberOfRanges; ++i{
                    internalString.append(nsString.substringWithRange(result.rangeAtIndex(i)))
                }
                resultsFinal.append(internalString)
        }
            return resultsFinal
       
    }
    
    
   
   
    @IBAction func postText(sender: AnyObject) {
        
        let event = "\(nameText.text!) is going to \(eventNameText.text!) at \(eventTimeText.text!), \(dateText.text!). \n Event Location: \(eventAddressText.text!) \n Departing From: \(leavingFromText.text!) \n Departing At: \(departTimeText.text!)"
        
        print(event)
        
        UserMedia.postUserPost(event, user: PFUser.currentUser()! ,completion: nil)
        
        //not going to worry about empty text fields right now
        
        
        
    
    }

}
