//
//  ContentManager.swift
//  kinoKudaGo
//
//  Created by Admin on 15.01.2021.
//  Copyright © 2021 DmitryChaschin. All rights reserved.
//

import UIKit

// Добавил AnyObject протокол, чтобы сделать делегат weak, чтобы избежать reference cycle
protocol ContentManagerDelegate: AnyObject {

    func didResultsLoaded(contentManager: ContentManager, contentModel: ContentModel)
}

struct ContentManager {
    private let baseUrl = "https://kudago.com/public-api/v1.4/movies/?/&fields="
    private let title = "title"
    private let poster = "poster"
    private let description = "body_text"
    var nextUrl = ""
    

    weak var delegate: ContentManagerDelegate?

    // MARK: - Public
    public func fetch(page: Int) {
        let urlString = "\(baseUrl)\(title),\(poster),\(description)&page_size=100&page=\(page)"
        guard let  url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: .infinity)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlRequest) { (data, responce, error) in
            if error != nil {
                print(error!)
                return
            }
            if let safeData = data,
               let films = self.parseJSON(from: safeData) {
                self.delegate?.didResultsLoaded(contentManager: self, contentModel: films)
            }
        }
        task.resume()
    }
    
    public func setImage(withUrlString urlString:String, toImageView imageView:UIImageView) {
        let url = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async(execute: {
                    imageView.image = image
                    imageView.alpha = 0
                    UIView.animate(withDuration: 1, animations: {
                        imageView.alpha = 1.0
                    })
                })
            }
        })
        task.resume()
    }
    
    // MARK: - Private
    // add extra arguments to contentModel for next upgrade's
    private func parseJSON(from data: Data) -> ContentModel? {
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
                                            films: films,
                                            pageCounts: count,
                                            next: next)
            return contentModel
        } catch {
            print(error)
        }
        return nil
    }
}
