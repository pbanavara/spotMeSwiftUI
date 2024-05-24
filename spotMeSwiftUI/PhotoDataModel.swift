//
//  PhotoDataModel.swift
//  spotMeSwiftUI
//
//  Created by Pradeep Banavara on 21/05/24.
//

import Foundation

class PhotoDataModel: ObservableObject {
    
    
    @Published var items:[PhotoItem] = []
    
    init() {
        if !FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).isEmpty {
            let docUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = docUrls[0]
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: .none)
                for url in urls {
                    if url.isVideo {
                        let item = PhotoItem(url: url)
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
                    let item = PhotoItem(url: url)
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
                try FileManager.default.removeItem(at: item.url)
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
