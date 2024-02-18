//
//  Notifications.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 15.02.24.
//

import Foundation

extension Notification.Name 
{
    static let addedWordToListWordsNotification = Notification.Name("addedWordToListWordsNotification")
    static let deletedWordFromListWordsNotification = Notification.Name("deletedWordFromListWordsNotification")
    
    static let addedWordToFavoriteListWordsNotification = Notification.Name("addedWordToFavoriteListWordsNotification")
    static let deletedWordFromFavoriteListWordsNotification = Notification.Name("deletedWordFromFavoriteListWordsNotification")
}
