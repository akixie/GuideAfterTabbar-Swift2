//
//  OPListViewController.swift
//  OPSite
//
//  Created by akixie on 16/5/22.
//  Copyright © 2016年 Aki.Xie. All rights reserved.
//

import UIKit
import Alamofire

var data: [String] = []

class OPListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView : UICollectionView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //HTTP Headers
        let headers = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        Alamofire.request(.GET, "https://httpbin.org/get", headers: headers)
            .responseJSON { response in
                debugPrint(response)
        }
        
        //1. Get
        Alamofire.request(.GET, "https://httpbin.org/get", parameters: ["foo": "bar"])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
        
        let parameters = [
            "foo": "bar",
            "baz": ["a", 1],
            "qux": [
                "x": 1,
                "y": 2,
                "z": 3
            ]
        ]
        
        //2. POST
        Alamofire.request(.POST, "https://httpbin.org/post", parameters: parameters)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
        
        
        //3. Uploading with Progress
        let fileURL = NSBundle.mainBundle().URLForResource("transparent", withExtension: "png")
        Alamofire.upload(.POST, "https://httpbin.org/post", file: fileURL!)
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                print(totalBytesWritten)
                
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    print("Total bytes written on main queue: \(totalBytesWritten)")
                }
            }
            .validate()
            .responseJSON { response in
                debugPrint(response)
        }
        
        //4. Uploading MultipartFormData
        Alamofire.upload(
            .POST,
            "https://httpbin.org/post",
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: fileURL!, name: "unicorn")
                multipartFormData.appendBodyPart(fileURL: fileURL!, name: "rainbow")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
        //5. Downloading a File
        Alamofire.download(.GET, "https://httpbin.org/stream/100") { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let pathComponent = response.suggestedFilename
            
            return directoryURL.URLByAppendingPathComponent(pathComponent!)
        }
        
        //6. Downloading a File w/Progress
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
//        Alamofire.download(.GET, "https://httpbin.org/stream/100", destination: destination)
        Alamofire.download(.GET, "https://httpbin.org/stream/100", destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    print("Total bytes read on main queue: \(totalBytesRead)")
                }
            }
            .response { _, _, _, error in
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                }
        }
        
        let json = "http://dl.dropboxusercontent.com/u/7817937/nameko.json"
        let uri = NSURL(string: json)
        let uridata = NSData(contentsOfURL: uri!)
        let objects = uridata!.objectFromJSONData() as! NSDictionary
        let array = objects.objectForKey("images") as! [String]
        data += array
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MyCollectionViewCell
        let url = NSURL(string: data[indexPath.row])
        let placeholder = UIImage(named: "transparent.png")
        cell.image!.setImageWithURL(url!, placeholderImage: placeholder)
        return cell
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
