//
//  ExtensionQueue.swift
//  AIQuestion
//
//  Created by Jose Decena on 28/9/24.
//

import Foundation

extension DispatchQueue {
    static var customConcurrentQueue = DispatchQueue(label: "com.AiQuestion.concurrentQueue", qos: .utility, attributes: .concurrent)
}
