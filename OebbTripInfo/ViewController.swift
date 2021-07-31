//
//  ViewController.swift
//  OebbTripInfo
//
//  Created by Felix Winterleitner on 31.07.21.
//

import Foundation

static func newInsatnce() -> ViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("ViewController")
      
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
        fatalError("Unable to instantiate ViewController in Main.storyboard")
    }
    return viewcontroller
}
