//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Soumya on 1/13/16.
//  Copyright © 2016 udaymitra. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var movies: [Movie]?
    
    var uiRefreshControl : UIRefreshControl!
    @IBOutlet weak var errorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        // add refresh control
        uiRefreshControl = UIRefreshControl()
        uiRefreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(uiRefreshControl)
        
        loadData()
    }
    
    func refresh(sender:AnyObject)
    {
        self.uiRefreshControl.endRefreshing()
        loadData()
    }

    func loadData() {
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.labelText = "Loading movies..."
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    self.movies = Movie.getMovies(JSON(data : data))
                    self.errorView.hidden = true

                    // reload view with new data
                    self.tableView.reloadData()
                } else {
                    self.errorView.hidden = false
                    if let e = error {
                        NSLog("Error: \(e)")
                    }
                }
                // stop spinning activity
                spinningActivity.hide(true)
        });
        task.resume()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        cell.movie = movie
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
