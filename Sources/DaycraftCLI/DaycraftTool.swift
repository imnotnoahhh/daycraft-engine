//
//  main.swift
//  DaycraftEngine
//
//  Created by qinfuyao on 1/14/26.
//

import Foundation
import ArgumentParser
import DaycraftLogic // 引用上面的库

@main
struct Daycraft: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "The Anti-Guilt Productivity Tool",
        version: "1.0.0"
    )
    
    func run() throws {
        let brain = DaycraftBrain()
        print("Hello from CLI!")
        print(brain.sayHello())
    }
}
