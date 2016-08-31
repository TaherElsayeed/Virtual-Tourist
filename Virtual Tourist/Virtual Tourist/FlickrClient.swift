//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Seab on 8/30/16.
//  Copyright © 2016 Seab Jackson. All rights reserved.
//

import Foundation

class FlickrClient {
    
    var session = NSURLSession.sharedSession()
    
    func taskForGetMethod(method: String, parameters: [String: AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // build the url and configure the request
        let request = NSMutableURLRequest(URL: flickrURLFromParameters(parameters, withPathExtension: method))
        
        // make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // was there an error
            guard (error == nil) else {
                print("error with get method")
                return
            }
            
            // did we get a successful 2xx response
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("statusCode error")
                return
            }
            
            // was there any data returned
            guard let data = data else {
                print("no data")
                return
            }
            
        }
        
        // start the request
        task.resume()
        
        return task
        
    }
    
    func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertedData: (result: AnyObject!, error: NSError?) -> Void) {
        
    }
    
    // build the url
    func flickrURLFromParameters(parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.URL.ApiScheme
        components.host = Constants.URL.ApiHost
        components.path = Constants.URL.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            
        }
        print(components.URL!)
        return components.URL!
        
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}