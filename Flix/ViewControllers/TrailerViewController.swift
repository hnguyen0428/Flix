//
//  TrailerViewController.swift
//  Flix
//
//  Created by Hoang on 2/12/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import UIKit
import WebKit

class TrailerViewController: UIViewController, WKNavigationDelegate {
    
    var videoURL: String?
    
    static let BAR_HEIGHT_MULTIPLIER: CGFloat = 0.055
    
    let doneBarButton: UIBarButtonItem = {
        let barbutton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done,
                                        target: self, action: #selector(clickedDone))
        return barbutton
    }()
    
    let topBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = false
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.allowsBackForwardNavigationGestures = true
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        webView.navigationDelegate = self
        
        setupToolbar()
        setupWebview()
        loadWebview()
    }
    
    func setupToolbar() {
        topBar.setItems([doneBarButton], animated: true)
        
        view.addSubview(topBar)
        
        topBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        topBar.heightAnchor.constraint(equalTo: view.heightAnchor,
                                       multiplier: TrailerViewController.BAR_HEIGHT_MULTIPLIER).isActive = true
        topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func setupWebview() {
        view.addSubview(webView)
        
        webView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func loadWebview() {
        if let urlString = videoURL {
            let url = URL(string: urlString)!
            
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    @objc func clickedDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
