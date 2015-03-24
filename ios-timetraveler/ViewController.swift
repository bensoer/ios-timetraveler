//
//  ViewController.swift
//  ios-timetraveler
//
//  Created by Ben Soer on 2015-03-23.
//  Copyright (c) 2015 bensoer. All rights reserved.
//

import UIKit
import Darwin
import Foundation
//import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var dateSlider: UISlider!
    
    @IBOutlet weak var currentDateValue: UILabel!
    
    @IBOutlet weak var currentPercentValue: UILabel!
    
    @IBOutlet weak var whatHappened: UITextView!

    var canUpdate:Bool = true;
    
    var pageItemsArray = Array<NSString>();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPercentValue.text = "0.000%"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func sliderMoved(sender: UISlider) {
        
        if (canUpdate){
            canUpdate = false;
            var percent = sender.value;
            
            var year = convertPercentToYear(Double(percent));
            var day = getDayOfYear(year);
            var month = getMonth(day);
            var dateOfMonth = getDayOfMonth(day);
            
            println("Percent: \(percent), Year: \(year), Day: \(day)");
            
            getArticle(Int(year));
            displayDate(percent)

            displayArticlesFromDate(month, day: dateOfMonth);
        }
    }
    
    private func displayDate(percent:Float){
        
        let flags: NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit
        let date = NSDate()
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        
        var year = convertPercentToYear(Double(percent));
        var day = getDayOfYear(year);
        
        // Common year
        if (year > 0) {
            currentDateValue.text = "\(Int(round(year)))"
            // Further than our calendar
        } else if ( round(Double(components.year) - year) < 1000000) {
            currentDateValue.text = "\(Int(round(Double(components.year) - year))) years ago"
            // Million years ago
        } else if (round(Double(components.year) - year) > 1000000 && round(Double(components.year) - year) < 1000000000) {
            currentDateValue.text = "\(Int(round(Double(components.year) - year) / 1000000)) million years ago"
            // Billion years ago
        } else {
            currentDateValue.text = "\(Int(round(Double(components.year) - year) / 1000000000)) billion years ago"
        }
    }
    
    private func displayArticlesFromDate(month:Int, day:Int) {
        
        //var monthName:String = Months(rawValue: month);
        
        var string = getMonthName(day);
        var fullString = "\(string) \(day)";
        
        whatHappened.text = "";
        
        println(fullString);
        
        for(data:NSString ) in pageItemsArray{
            
            var article = data.rangeOfString(fullString);
            
            if(article.location != NSNotFound){
                println("Article Found");
                var temp = whatHappened.text;
                var totalData = temp + data;
                whatHappened.text = totalData;
                //break;
            }
            
            
        }
        
        println("end");
    }
    
    private func getMonthName(month:Int)->String{
        switch month {
        case 1:
            return "January";
        case 2:
            return "February";
        case 3:
            return "March";
        case 4:
            return "April";
        case 5:
            return "May";
        case 6:
            return "June";
        case 7:
            return "July";
        case 8:
            return "August";
        case 9:
            return "September";
        case 10:
            return "October";
        case 11:
            return "November";
        case 12:
            return "December";
        default:
            return "error";
        }
    }
    
    private func getArticle(year:Int){

        var url = NSURLRequest(URL: NSURL(string: "http://en.wikipedia.org/w/api.php?action=query&continue&prop=extracts&format=json&titles=\(year)")!);
        
        //var connection = NSURLConnection(url, respHandler, startimmediatly:true);
        
        NSURLConnection.sendAsynchronousRequest(url, queue: NSOperationQueue.mainQueue(), respHandler);
    }
    
    private func respHandler(resp:NSURLResponse!, data:NSData!, error:NSError!){
        
        var jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil);
        
        //println(jsonData);
        
        if let query = jsonData as? Dictionary<String, AnyObject>{
            if let pages = query["query"] as AnyObject? as? Dictionary<String, AnyObject>{
                //println(pages);
                
                if let number = pages["pages"] as AnyObject? as? Dictionary<String, AnyObject>{
                    
                    for(key:String, dataBelow: AnyObject) in number {
                        
                        //println("Key: \(key) , dataBelow: \(dataBelow)");
                        
                        if let extract = number[key] as AnyObject? as? Dictionary<String, AnyObject>{
                            
                            if let html = extract["extract"] as AnyObject? as? String{
                                
                                //println("THE HTML: \(html)");
                                
                                parseDateEventsOutOfPage(html);
                                
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func parseDateEventsOutOfPage(html:NSString){
        
        var shrinkingData:NSString = html;
        //var startIndexOfLi:NSRange = 0;
        //var endIndexOfLi:NSRange = 0;
        
        
        while(true){
            
            var startIndexOfLi = shrinkingData.rangeOfString("<li>");
            
            if(startIndexOfLi.location == NSNotFound){
                println("Couldn't find start");
                break;
            }
            
           
            var endTagData:NSString = shrinkingData.substringWithRange(NSRange(location: startIndexOfLi.location + 4, length: shrinkingData.length - startIndexOfLi.location - 4));
            
            var endIndexOfLi = endTagData.rangeOfString("</li>");
            endIndexOfLi.location += startIndexOfLi.location + 4;
            
            /*if(endIndexOfLi.location == NSNotFound){
                println("Couldn't find end");
                break;
            }*/
            
            //println("Start: \(startIndexOfLi.location) , End: \(endIndexOfLi.location)");
            
            var difference = endIndexOfLi.location - startIndexOfLi.location;
            
            var text = shrinkingData.substringWithRange(NSRange(location: startIndexOfLi.location + 4 , length: difference - 4));
            
            //println(text);
            
            pageItemsArray.append(text);
            
            shrinkingData = shrinkingData.substringWithRange(NSRange(location: endIndexOfLi.location + 4, length: (shrinkingData.length - endIndexOfLi.location - 4)));
            
            //println("\n\n----------------" + shrinkingData + "\n\n--------------------------------------------------------");
            
            
            //break;
            
        }
        
        canUpdate  = true;
        
        
    }
    
    private func convertPercentToYear(percent:Double)->Double{
        
        var percent2 = percent * 100.00;
        
        let numberOfPlaces = 3.0
        let multiplier = pow(10.0, numberOfPlaces)
        var rounded = round(Double(percent2) * multiplier) / multiplier
        
        currentPercentValue.text = "\(rounded)%"
        
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
    
    private func getMonth(dayOfYear:Int)->Int{
        return Int(dayOfYear  / 12);
    }
    
    private func getDayOfMonth(dayOfYear:Int)->Int{
        return Int( dayOfYear % 12);
    }

}

