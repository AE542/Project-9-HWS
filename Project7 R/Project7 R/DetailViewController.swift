//
//  DetailViewController.swift
//  Project7 R
//
//  Created by Mohammed Qureshi on 2020/08/13.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit
import WebKit
class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition? //optional
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem = detailItem else { return }// we need to use a guard let as it unwraps detail item into itself it if has a value.
        //v. common to unwrap variables with using the same name rather than create new variations. Saves on code.
        
      let html = """
     <html>
     <head>
     <meta name ="viewport" content ="width=device-width, initial-scale=1">
     <style> body { font-size: 150%; } </style>
     </head>
     <body>
     \(detailItem.body)
     </html>
     """
        
        webView.loadHTMLString(html, baseURL: nil)// custom html string made by hand here.
        
        
    }// html string for showing font size at the size we want and
    

}
