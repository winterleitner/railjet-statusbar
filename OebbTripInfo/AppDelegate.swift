//
//  AppDelegate.swift
//  OebbTripInfo
//
//  Created by Felix Winterleitner on 31.07.21.
//

import Cocoa
import SwiftUI
import CoreWLAN


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusItem: NSStatusItem?
    
    
    
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    
    var refreshTimer: Timer?
    
    var ssid: String {
        return CWWiFiClient.shared().interface(withName: nil)?.ssid() ?? ""
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
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


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
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
                result = data + " km/h " + self.ssid
                semaphore.signal()

               }
          }
        semaphore.wait()
        statusItem?.button?.title = result
     }
    
    func loadTrainSpeed(completion: @escaping (String?) -> ()) {
        if let url = URL(string: "https://localhost:5001") {
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
    
    func sendRequest(completion: @escaping (String?) -> ()) {
        //let params = ["username":"john", "password":"123456"] as Dictionary<String, String>

        var request = URLRequest(url: URL(string: "https://railnet.oebb.at/api/speed")!)
        request.httpMethod = "GET"
        //request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { data, response, error in
            if (response != nil) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    return completion(json["name"] as! String)
                } catch {
                    return completion(nil)
                }
            }
        }).resume()
    }


}

