//
//  FileProcessor.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 17.02.24.
//

import Foundation

final class FileProcessor 
{
    static let shared = FileProcessor()
    private init() {}

    private let queue = DispatchQueue(label: "FileProcessorQueue", attributes: .concurrent)

    func removeLineFromFile(atPath path: String, lineNumber: Int32, completion: ((Bool, Error?) -> Void)?)
    {
        queue.async {
            let tempFilePath = path + ".tmp"
            let fileManager = FileManager.default

            if let reader = LineReader(path: path), let writer = OutputStream(toFileAtPath: tempFilePath, append: false) {
                writer.open()

                var currentLineNumber = 1
                while let line = reader.nextLine() {
                    if currentLineNumber != lineNumber {
                        if let data = "\n\(line)".data(using: .utf8) {
                            data.withUnsafeBytes { writer.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count) }
                        }
                    }
                    currentLineNumber += 1
                }

                writer.close()

                do {
                    try fileManager.removeItem(atPath: path)
                    try fileManager.moveItem(atPath: tempFilePath, toPath: path)
                    DispatchQueue.main.async {
                        completion?(true, nil)
                        print("Word has removed from the file: line - \(lineNumber)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion?(false, error)
                        print("Error of word removing: line - \(lineNumber)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion?(false, NSError(domain: "FileProcessorError", code: 1, userInfo: [NSLocalizedDescriptionKey: "File did not open."]))
                }
            }
        }
    }
    
    func appendLineToFile(atPath path: String, word: String, completion: ((Bool, Error?) -> Void)?)
    {
        queue.async {
            let fileURL = URL(fileURLWithPath: path)
            let data = "\(word)\n".data(using: .utf8)!
            
            do {
                if FileManager.default.fileExists(atPath: path) {
                    let fileHandle = try FileHandle(forWritingTo: fileURL)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    try data.write(to: fileURL, options: .atomic)
                }
                
                DispatchQueue.main.async {
                    completion?(true, nil)
                    print("Word has added to the end of file")
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(false, error)
                    print("Error of word adding to the end of file")
                }
            }
        }
    }
}
