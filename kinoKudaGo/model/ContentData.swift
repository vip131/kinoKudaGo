//
//  ContentData.swift
//  kinoKudaGo
//
//  Created by Admin on 15.01.2021.
//  Copyright © 2021 DmitryChaschin. All rights reserved.
//

import Foundation

struct ContentData: Codable {
    let results: [Result]
    let count: Int
    let next : String
}

struct Result: Codable {
    let title: String
    let bodyText: String
    let poster: Poster
    
    enum CodingKeys: String, CodingKey {
        case title
        case poster
        case bodyText = "body_text"
    }
}

struct Poster: Codable {
    let image: String
    let source: Source
}

struct Source: Codable {
    let name, link: String
}
