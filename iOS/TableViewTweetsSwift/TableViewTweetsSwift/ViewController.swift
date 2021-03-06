//
//  ViewController.swift
//
//

import UIKit
import TwitterKit

class ViewController: UITableViewController , TWTRTweetViewDelegate {

    // setup a 'container' for Tweets
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var prototypeCell: TWTRTweetTableViewCell?

    let tweetTableCellReuseIdentifier = "TweetCell"

    var isLoadingTweets = false


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        // Create a single prototype cell for height calculations.
        self.prototypeCell = TWTRTweetTableViewCell(style: .default, reuseIdentifier: tweetTableCellReuseIdentifier)

        // Register the identifier for TWTRTweetTableViewCell.
        self.tableView.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableCellReuseIdentifier)

        // Setup table data
        loadTweets()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Make sure the navigation bar is not translucent when scrolling the table view.
        self.navigationController?.navigationBar.isTranslucent = false
    }


    func loadTweets() {
        // Do not trigger another request if one is already in progress.
        if self.isLoadingTweets {
            return
        }
        self.isLoadingTweets = true

        // set tweetIds to find
        let tweetIDs = ["20","266031293945503744", "440322224407314432"];


        // Find the tweets with the tweetIDs
        let client = TWTRAPIClient()
        client.loadTweets(withIDs: tweetIDs) { (twttrs, error) -> Void in
            
            // If there are tweets do something magical
            if ((twttrs) != nil) {
                
                // Loop through tweets and do something
                for i in twttrs! {
                    // Append the Tweet to the Tweets to display in the table view.
                    self.tweets.append(i as TWTRTweet)
                }
            } else {
                print(error as Any)
            }
        }

    }

    func refreshInvoked() {
        // Trigger a load for the most recent Tweets.
        loadTweets()
    }

    // MARK: TWTRTweetViewDelegate
    func tweetView(_ tweetView: TWTRTweetView!, didSelect tweet: TWTRTweet!) {
        // Display a Web View when selecting the Tweet.
        let webViewController = UIViewController()
        let webView = UIWebView(frame: webViewController.view.bounds)
        webView.loadRequest(URLRequest(url: tweet.permalink))
        webViewController.view = webView
        self.navigationController?.pushViewController(webViewController, animated: true)
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of Tweets.
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier, for: indexPath) as! TWTRTweetTableViewCell

        // Assign the delegate to control events on Tweets.
        cell.tweetView.delegate = self

        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]

        // Configure the cell with the Tweet.
        cell.configure(with: tweet)

        // Return the Tweet cell.
        return cell
    }

    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tweet = self.tweets[indexPath.row]
        self.prototypeCell?.configure(with: tweet)
        
        return TWTRTweetTableViewCell.height(for: tweet, style: TWTRTweetViewStyle.compact, width: self.view.bounds.width, showingActions: false)
    }
}

