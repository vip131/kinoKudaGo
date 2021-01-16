//
//  DetailViewController.swift
//  kinoKudaGo
//
//  Created by Admin on 15.01.2021.
//  Copyright © 2021 DmitryChaschin. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    open var film: Result?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        view = webView
        guard let film = film else { return }
        
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%; } </style>
        </head>
        <body>
        <p style="text-align: center;"><img src="\(film.poster.image)" width="189" height="255" alt="альтернативный текст"> </p>
        <h3>
        <p style="text-align: center;">\(film.title)<p>
        </h3>
        <p>\(film.bodyText)<p>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
    
}
