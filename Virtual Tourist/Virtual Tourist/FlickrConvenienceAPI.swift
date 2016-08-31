//
//  FlickrConvenienceAPI.swift
//  Virtual Tourist
//
//  Created by Seab on 8/30/16.
//  Copyright © 2016 Seab Jackson. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func searchPhotoByLocation(latitude: Double, longitude: Double, completionHandlerForSearch: (result: AnyObject?, error: NSError?) -> Void) {
        let parameters: [String:AnyObject] = [
            Constants.FlickrParameterKeys.Method: Constants.Method.PhotoSearch,
            Constants.FlickrParameterKeys.ApiKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Latitude: latitude,
            Constants.FlickrParameterKeys.Longitude: longitude,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.FormatResponse,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPageNumber,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCall
//            FlickrClient.FlickrParameterKeys.PerPage : FlickrClient.FlickrParameterValues.PerPageNumber
        ]
        
        taskForGetMethod("", parameters: parameters) { (result, error) in
            print(result)
        }
    }
    
}