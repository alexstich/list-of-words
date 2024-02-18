//
//  FilePreview.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 18.02.24.
//

import UIKit

class FilePreview: UIViewController {

    let textView = UITextView()

    override func viewDidLoad() 
    {
        super.viewDidLoad()

        textView.frame = view.bounds
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.isEditable = false
        view.addSubview(textView)

        loadTextFile()
    }

    func loadTextFile() 
    {
        let filePath = DataProviderConfiguration.shared.fileURL.path
        
        if let contents = try? String(contentsOfFile: filePath) {
            textView.text = contents
        } else {
            textView.text = " File is not found"
        }
    }
}
