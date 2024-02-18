//
//  LineReader.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 17.02.24.
//

import Foundation

class LineReader
{
    let fileHandle: FileHandle
    let buffer: NSMutableData
    let delimData: Data
    var atEof: Bool = false

    init?(path: String, delimiter: String = "\n") 
    {
        guard let fileHandle = FileHandle(forReadingAtPath: path),
              let delimData = delimiter.data(using: .utf8) else {
            return nil
        }
        
        self.fileHandle = fileHandle
        self.buffer = NSMutableData()
        self.delimData = delimData
    }
    
    deinit {
        self.fileHandle.closeFile()
    }
    
    func nextLine() -> String? 
    {
        if atEof { return nil }

        var range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
        
        while range.location == NSNotFound {
            
            let tempData = fileHandle.readData(ofLength: 4096)
            
            if tempData.isEmpty { // EOF
                atEof = true
                if buffer.length > 0 {
                    let line = String(data: buffer as Data, encoding: .utf8)
                    buffer.length = 0
                    return line
                }
                return nil
            }
            
            buffer.append(tempData)
            range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
        }

        let line = String(data: buffer.subdata(with: NSRange(location: 0, length: range.location)), encoding: .utf8)
        
        buffer.replaceBytes(in: NSRange(location: 0, length: range.location + range.length), withBytes: nil, length: 0)

        return line
    }
}
