//
//  ViewController.swift
//  EasyBrowser
//
//  Created by Darren Hodges on 11/10/2015.
//  Copyright © 2015 Darren Hodges. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate
{
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "hackingwithswift.com"]
    
    override func loadView()
    {
        // Create web view
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Load initial site
        let url = NSURL(string: "https://\(websites[0])")!
        webView.loadRequest(NSURLRequest(URL:url))
        webView.allowsBackForwardNavigationGestures = true
        
        // Watch the estimatedProgress value
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        // Right navigation bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .Plain, target: self, action: "openTapped")
        
        progressView = UIProgressView(progressViewStyle: .Default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: "reload")
        
        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.toolbarHidden = false
    }
    
    func openTapped()
    {
        // Present list of sites to open
        let ac = UIAlertController(title: "Open page…", message: nil, preferredStyle: .ActionSheet)
        for website in websites
        {
            ac.addAction(UIAlertAction(title: website, style: .Default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func openPage(action: UIAlertAction!)
    {
        let url = NSURL(string: "https://" + action.title!)!
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!)
    {
        // Set title
        title = webView.title
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void)
    {
        // Only allow urls in our safe list
        let url = navigationAction.request.URL
        
        if let host = url!.host
        {
            for website in websites
            {
                if host.rangeOfString(website) != nil
                {
                    decisionHandler(.Allow)
                    return
                }
            }
        }
        decisionHandler(.Cancel)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if keyPath == "estimatedProgress"
        {
            let floatValue = webView.estimatedProgress == 1.0 ? Float(0.0) : Float(webView.estimatedProgress)
            progressView.progress = floatValue
        }
    }
}

