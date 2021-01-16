//
//  ContentManager.swift
//  kinoKudaGo
//
//  Created by Admin on 15.01.2021.
//  Copyright © 2021 DmitryChaschin. All rights reserved.
//

import UIKit

protocol ContentManagerDelegate {
    func updateUI (_ withManager: ContentManager, _ withModel: ContentModel)
}

struct ContentManager {
    private let baseUrl = "https://kudago.com/public-api/v1.4/movies/?/&fields="
    private let title = "title"
    private let poster = "poster"
    private let description = "body_text"
    var nextUrl = ""
    var delegate: ContentManagerDelegate?
    
    func fetch(page: Int) {
        let urlString = "\(baseUrl)\(title),\(poster),\(description)&page_size=100&page=\(page)"
        guard let  url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: .infinity)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlRequest) { (data, responce, error) in
            if error != nil {
                print(error!)
            }
            if let safeData = data {
                if let films = self.parseJSON(from: safeData) {
                    self.delegate?.updateUI(self, films)
                }
            }
        }
        task.resume()
    }
    
    // add extra arguments to contentModel for next upgrade's
    func parseJSON(from data: Data) -> ContentModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ContentData.self, from: data)
            let films = decodedData.results
            let title = decodedData.results.last!.title
            let fullDescription = decodedData.results.last!.bodyText
            let poster = decodedData.results.last!.poster.image
            let count = decodedData.count
            let next = decodedData.next
            let contentModel = ContentModel(title: title,
                                            poster: poster,
                                            fullDescription: fullDescription,
                                            films: films,pageCounts: count, next: next)
            return contentModel
        } catch {
            print(error)
        }
        return nil
    }
    
    //MARK: - Support functions -
    func getImage(_ url_str:String, _ imageView:UIImageView) {
        let url:URL = URL(string: url_str)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
            if data != nil {
                let image = UIImage(data: data!)
                if(image != nil) {
                    DispatchQueue.main.async(execute: {
                        imageView.image = image
                        imageView.alpha = 0
                        UIView.animate(withDuration: 1, animations: {
                            imageView.alpha = 1.0
                        })
                    })
                }
            }
        })
        task.resume()
    }
    
    
}



