//
//  Global.swift
//  AIQuestion
//
//  Created by Jose Decena on 28/9/24.
//

import Foundation

func divideArray<T>(_ array: [T], intoChunks numberOfChunks: Int) -> [[T]] {
    let chunkSize = array.count / numberOfChunks
    let remainder = array.count % numberOfChunks
    
    var chunks: [[T]] = []
    var startIndex = 0
    
    for i in 0..<numberOfChunks {
        let currentChunkSize = chunkSize + (i < remainder ? 1 : 0)
        let endIndex = startIndex + currentChunkSize
        let chunk = Array(array[startIndex..<endIndex])
        chunks.append(chunk)
        startIndex = endIndex
    }
    
    return chunks
}
