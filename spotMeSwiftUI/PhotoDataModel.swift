//
//  PhotoDataModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import Foundation

class PhotoDataModel: ObservableObject {
    @Published var items:[PhotoItem] = []
    @Published var filteredItems:[PhotoItem] = []
    
    static let shared  = PhotoDataModel()
    
    private init() {
        loadUrls()
    }
    
    func loadUrls() {
        if !FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).isEmpty {
            items.removeAll()
            let docUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = docUrls[0]
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: documentDirectory,
                                                                       includingPropertiesForKeys: [.contentAccessDateKey],
                                                                       options: [.skipsHiddenFiles])
                    .filter { $0.lastPathComponent.hasSuffix(".mov") }
                    .sorted(by: {
                        let date0 = try $0.promisedItemResourceValues(forKeys:[.contentAccessDateKey]).contentAccessDate!
                        let date1 = try $1.promisedItemResourceValues(forKeys:[.contentAccessDateKey]).contentAccessDate!
                        return date0.compare(date1) == .orderedDescending
                    })
                for url in urls {
                    if url.isVideo {
                        // simplest if URL contains the constant in the filename assign the workouttype to item
                        var item = PhotoItem()
                        let date = (try? FileManager.default.attributesOfItem(atPath: url.path()))?[.creationDate] as? Date
                        item.createdAt = date
                        item.url = url
                        let urlString = url.absoluteString
                        if urlString.localizedLowercase.contains("kettlebellswing".localizedLowercase) {
                            item.workoutType = KBWorkoutConstants.KB_SWING
                        }
                        else if urlString.localizedLowercase.contains("kettlebellsquat".localizedLowercase) {
                            item.workoutType = KBWorkoutConstants.KB_SQUAT
                        }
                        else if urlString.localizedLowercase.contains("kettlebelldeadlift".localizedLowercase) {
                            item.workoutType = KBWorkoutConstants.KB_DEAD_LIFT
                        }
                        else if urlString.localizedLowercase.contains("general".localizedLowercase) {
                            item.workoutType = KBWorkoutConstants.GEN_WORKOUT
                        } else {
                            item.workoutType = KBWorkoutConstants.KB_DEAD_LIFT
                        }
                        items.append(item)
                    }
                }
            } catch {
                NSLog(error.localizedDescription)
            }
        }
        if let urls = Bundle.main.urls(forResourcesWithExtension: "mov", subdirectory: nil) {
            for url in urls {
                if url.isVideo {
                    var item = PhotoItem()
                    item.url = url
                    items.append(item)
                }
            }
        }
    }
    
    func clearAllFile() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
    
    func addPhotoItem(_ item: PhotoItem) {
        items.insert(item, at: 0)
    }
    
    func removeItem(_ item: PhotoItem) {
        if let removeIndex = items.firstIndex(of: item) {
            items.remove(at: removeIndex)
            do {
                try FileManager.default.removeItem(at: item.url!)
            } catch {
                NSLog(error.localizedDescription)
            }
        }
    }
}

extension URL {
    /// Indicates whether the URL has a file extension corresponding to a common image format.
    var isVideo: Bool {
        let imageExtensions = ["mov", "mp4"]
        return imageExtensions.contains(self.pathExtension)
    }
}
