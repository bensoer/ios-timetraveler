//
//  ViewController.swift
//  ios-timetraveler
//
//  Created by Ben Soer on 2015-03-23.
//  Copyright (c) 2015 bensoer. All rights reserved.
//

import UIKit
import Darwin
//import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var dateSlider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderMoved(sender: UISlider) {
        var percent = sender.value;
        
        var year = convertPercentToYear(Double(percent));
        var day = getDayOfYear(year);
        
        println("Percent: \(percent), Year: \(year), Day: \(day)");
        
        getArticle(Int(year));
        
    }
    
    private func getArticle(year:Int){
        
        /*Alamofire.request(.GET, "http://en.wikipedia.org/w/api.php?action=query&continue&prop=extracts&format=json&title=2014")
            .responseJSON{ (request, response, data, error) in
                println(request)
                println(response)
                println(error)
            }*/
        var url = NSURLRequest(URL: NSURL(string: "http://en.wikipedia.org/w/api.php?action=query&continue&prop=extracts&format=json&titles=2014")!);
        
        //var connection = NSURLConnection(url, respHandler, startimmediatly:true);
        
        NSURLConnection.sendAsynchronousRequest(url, queue: NSOperationQueue.mainQueue(), respHandler);
        
        
    }
    
    private func respHandler(resp:NSURLResponse!, data:NSData!, error:NSError!){
        
        var jsonData = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil);
        
        //println(jsonData);
        
        var json = JSON(jsonData!);
        
        if let story = json["query"]["pages"].string{
            var json2 = JSON(story);
            
            
            
            for(key: String, subJson: JSON) in json2 {
                
                
                if let actual = json2[key]["extract"].string{
                    println(actual);
                }
                
                
            }
            
            
            println(story);
        }
            println("pass");
        
        //println(jsonData[0][0][0][0]);
        
    }
    
    private func convertPercentToYear(percent:Double)->Double{
        
        var euler = 0.5772156649;
        
        var percent2 = percent * 100.00;
        
        println(percent2);
        
        
        
        /* T = CURRENTTIME - (e^(20.3444(p^3) +3) -e^3 */
        
        let date = NSDate();
        let calendar = NSCalendar.currentCalendar();
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitYear, fromDate: date);
        
        //var year = components.year;
        
        
        var year = Double(components.year) - (exp(20.3444 * pow(percent,3) + 3) - exp(3.00));
        
        
        return year;
        
    }
    
    private func getDayOfYear(year:Double)->Int{
        var percentOfTheYear:Double = year - Double(Int(year));
        
        var day = Int(round(365 * percentOfTheYear));
        
        return day;
        
    
    }

}

