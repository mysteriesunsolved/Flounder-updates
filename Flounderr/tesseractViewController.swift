//
//  tesseractViewController.swift
//  Flounderr
//
//  Created by Sanaya Sanghvi on 3/22/16.
//  Copyright © 2016 Flounderr. All rights reserved.
//


import UIKit
import Foundation

//Tesseract infor learnt from Ray Wenderlich tutorial

class tesseractViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   
    
    
    @IBOutlet var recognisedTextView: UITextView!
    
    var activityIndicator:UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        let regex = try! NSRegularExpression(pattern: "Jan(uary)?", options: NSRegularExpressionOptions.CaseInsensitive)
        print("hi1")
        print(regex)
        
        //get hanuel to type this up
        let name = regex.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name != nil {
            
            print("January")

        }
        
        let regex2 = try! NSRegularExpression(pattern: "Feb(rurary)?", options: NSRegularExpressionOptions.CaseInsensitive)
       

        
        let name2 = regex2.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name2 != nil {
            
            print("February")
            
        }
        
        let regex3 = try! NSRegularExpression(pattern: "Mar(ch)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name3 = regex3.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name3 != nil {
            
            print("March")
            
        }
        let regex4 = try! NSRegularExpression(pattern: "Apr(il)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name4 = regex4.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name4 != nil {
            
            print("April")
            
        }
        let regex5 = try! NSRegularExpression(pattern: "May", options: NSRegularExpressionOptions.CaseInsensitive)
        let name5 = regex5.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name5 != nil {
            
            print("May")
            
        }
        
        let regex6 = try! NSRegularExpression(pattern: "Jun(e)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name6 = regex6.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name6 != nil {
            
            print("June")
            
        }
        let regex7 = try! NSRegularExpression(pattern: "Jul(y)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name7 = regex7.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name7 != nil {
            
            print("July")
            
        }

        let regex8 = try! NSRegularExpression(pattern: "Aug(ust)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name8 = regex8.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name8 != nil {
            
            print("August")
            
        }
        let regex9 = try! NSRegularExpression(pattern: "Sep(tember)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name9 = regex9.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name9 != nil {
            
            print("September")
            
        }
        let regex10 = try! NSRegularExpression(pattern: "Oct(tober)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name10 = regex10.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name10 != nil {
            
            print("August")
            
        }
        let regex11 = try! NSRegularExpression(pattern: "Nov(ember)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name11 = regex11.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name11 != nil {
            
            print("November")
            
        }
        let regex12 = try! NSRegularExpression(pattern: "Dec(ember)?", options: NSRegularExpressionOptions.CaseInsensitive)
        let name12 = regex12.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name12 != nil {
            
            print("December")
            
        }
        
        //temporary fix till extraction can be carried out effecively in swift 2.0.
        let regex13 = try! NSRegularExpression(pattern: "2016", options: NSRegularExpressionOptions.CaseInsensitive)
        let name13 = regex13.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name13 != nil {
            
            print("2016")
            
        }
        let regex14 = try! NSRegularExpression(pattern: "2017", options: NSRegularExpressionOptions.CaseInsensitive)
        let name14 = regex14.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        if name14 != nil {
            
            print("2017")
            
        }
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
    
    
   
    //will have to add a swap text feature so we can autocorrect after text has been added
    //use swap text feature for dates. If satur- then saturday etc

}
