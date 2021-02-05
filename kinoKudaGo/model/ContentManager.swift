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
    /* Для делегатов лучше указывать did... will... Они как бы всегда около какого-то события, сразу до него или после.
     И речь о событии которое происходит тут в ContentManager, то есть например didResultsLoaded
     То есть смысл в том, что нам лучше не говорить отсюда из ContentManager что надо обновить UI где-то
     Тут мы просто говорим некоему делегату, что вот у нас загрузились фильмы, вот они, забирай, а дальше делегат может делать с ними все что хочет.
     Делегаты могут быть разными и использовать загруженные фильмы по разному.
     В этом смысл, что мы не знаем какой будет делегат и для чего ему фильмы.
     Это деляется для снижения связности между классами.
     Если метод назвать updateUI или как-то так - это накладывает некое ограничение, что фильмы нужны для UI и тд, а нам надо придерживаться более generic подхода
    */
    func didResultsLoaded(contentManager: ContentManager, contentModel: ContentModel)
}

struct ContentManager {
    private let baseUrl = "https://kudago.com/public-api/v1.4/movies/?/&fields="
    private let title = "title"
    private let poster = "poster"
    private let description = "body_text"
    var nextUrl = ""
    
    // делегат weak, чтобы избежать reference cycle
    weak var delegate: ContentManagerDelegate?
    
    // Можно добавлять для удобства пометки где public методы доступные из других классов, а где private, когда разрастется класс, это очень помогает ориентироваться
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
            // Можно чейнить if let через запятую, чтобы не добавлять новых скобок {} и не добавлять индентацию
            if let safeData = data,
               let films = self.parseJSON(from: safeData) {
                self.delegate?.didResultsLoaded(contentManager: self, contentModel: films)
                
            }
//            if let safeData = data {
//                if let films = self.parseJSON(from: safeData) {
//                    self.delegate?.didResultsLoaded(contentManager: self, contentModel: films)
//                }
//            }
        }
        task.resume()
    }
    
    // Я бы назвал метод setImageToImageView, так оно более соответствует тому что он делает. Он ведь не только получает картинку, но еще и устанавливает ее в ячейку
    // url_str - в качестве имени переменной не очень, в Swift и Objective-C не особо принят snake_case. Принят CamelCase. snake_case принят в Python
    public func setImage(withUrlString urlString:String, toImageView imageView:UIImageView) {
        // Зачем тип URL указывать? Он через type inference подхватывается
//        let url:URL = URL(string: url_str)!
        let url = URL(string: urlString)!

        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: {(data, response, error) in
            // Лучше с помощью conditional binding подхватить data, чтобы потом на надо было постоянно делать ей forceunwrap
            // if let data = data
            // Аналогично с image, и круглые скобки в if не обязательно
            
//            if data != nil {
//                let image = UIImage(data: data!)
//                if(image != nil) {
//                    DispatchQueue.main.async(execute: {
//                        imageView.image = image
//                        imageView.alpha = 0
//                        UIView.animate(withDuration: 1, animations: {
//                            imageView.alpha = 1.0
//                        })
//                    })
//                }
//            }
            
            // ТАК:
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
