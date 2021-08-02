//
//  AppDelegate.swift
//  OebbTripInfo
//
//  Created by Felix Winterleitner on 31.07.21.
//

import Cocoa
import SwiftUI
import CoreWLAN
import SwiftSoup


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusItem: NSStatusItem?
    
    var trainName: String!
    
    
    
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    
    var refreshTimer: Timer?
    
    var ssid: String {
        return CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? ""
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadTripInfo() { data in }
        let semaphore = DispatchSemaphore(value: 0)
        loadTrainInfo() { data in
               if let data = data {
                self.trainName = data
                semaphore.signal()
               }
          }
        semaphore.wait()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if (ssid == "OEBB") {
        refreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AppDelegate.refresh), userInfo: nil, repeats: true)
        }
        else {
            statusItem?.button?.title = "Please connect to OEBB WIFI!"
        }
        
        let itemImage = NSImage(named: "train")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        
        statusItem?.button?.imagePosition = NSControl.ImagePosition.imageRight
        
        if let menu = menu {
                statusItem?.menu = menu
            }
    }




    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

     @objc func refresh()
     {
        let semaphore = DispatchSemaphore(value: 0)
        var result = "yo"
        loadTrainSpeed() { data in
               if let data = data {
                result = data + " km/h (" + self.trainName + ")"
                semaphore.signal()

               }
          }
        semaphore.wait()
        statusItem?.button?.title = result
     }
    
    func loadTrainSpeed(completion: @escaping (String?) -> ()) {
        if let url = URL(string: "https://railnet.oebb.at/api/speed") {
            do {
                let contents = try String(contentsOf: url)
                completion(contents)
            } catch {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    func loadTrainInfo(completion: @escaping (String?) -> ()) {
        //let params = ["username":"john", "password":"123456"] as Dictionary<String, String>

        var request = URLRequest(url: URL(string: "https://railnet.oebb.at/api/trainInfo")!)
        request.httpMethod = "GET"
        //request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { data, response, error in
            if (response != nil) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    let trainType = json["trainType"] as! String
                    let lineNumber = json["lineNumber"] as! String
                    return completion(trainType + lineNumber)
                } catch {
                    return completion(nil)
                }
            }
        }).resume()
    }

    
    func loadTripInfo(completion: @escaping (String?) -> ()) {
        if let url = URL(string: "https://railnet.oebb.at/api/speed") {
            do {
                let contents = try String(contentsOf: url)
                do {
                    let doc: Document = try SwiftSoup.parse(contents)
                    let stations = try doc.getElementsByClass("station_item")
                    for station in stations {
                        print(try station.text())
                    }
                    print("yooosoas")
                } catch Exception.Error(let type, let message) {
                    print(message)
                } catch {
                    print("error")
                }
                completion(contents)
            } catch {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    /* Alles umstellen auf https://railnet.oebb.at/assets/modules/fis/combined.json?_time=1627830415168*/

}

