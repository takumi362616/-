//
//  CustomVisionService.swift
//  小野大輔がかっこいい件について
//
//  Created by ビデオエイペックス on 2017/08/02.
//  Copyright © 2017 takumi. All rights reserved.
//

import Foundation

class CustomVisionService {
    var preductionUrl = "https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/f4478b39-a934-41ca-b031-edaa381e81e9/image?iterationId=e3fa50ad-a918-4d10-8616-ef0d0c0edba9"
    var predictionKey = "2695b58feb7c44679538ebbe63cfd68a"
    var contentType = "application/octet-stream"
    
    var defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func predict(image: Data, completion: @escaping (CustomVisionResult?, Error?) -> Void) {
        
        // Create URL Request
        var urlRequest = URLRequest(url: URL(string: preductionUrl)!)
        urlRequest.addValue(predictionKey, forHTTPHeaderField: "Prediction-Key")
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        
        // Cancel existing dataTask if active
        dataTask?.cancel()
        
        // Create new dataTask to upload image
        dataTask = defaultSession.uploadTask(with: urlRequest, from: image) { data, response, error in
            defer { self.dataTask = nil }
            
            if let error = error {
                completion(nil, error)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let result = try? CustomVisionResult(json: json!) {
                    completion(result, nil)
                }
            }
        }
        
        // Start the new dataTask
        dataTask?.resume()
    }
}
