//
//  URL+FileManager.swift
//  NitrolessAutomator
//
//  Created by Andromeda on 02/07/2021.
//

import Foundation

enum ImageType: String {
    case png = "png"
    case gif = "gif"
}

extension String {
    var toBase64: String {
        return Data(self.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "").replacingOccurrences(of: "=", with: "")
    }
}

extension FileManager {
    func directorySize(_ dir: URL) -> Int {
        guard let enumerator = self.enumerator(at: dir, includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]) else { return 0 }
        var bytes = 0
        for case let url as URL in enumerator {
            bytes += url.size
        }
        return bytes
    }
    
    func sizeString(_ dir: URL) -> String {
        let bytes = Float(directorySize(dir))
        let kiloBytes = bytes / Float(1024)
        if kiloBytes <= 1024 {
            return "\(String(format: "%.1f", kiloBytes)) KB"
        }
        let megaBytes = kiloBytes / Float(1024)
        if megaBytes <= 1024 {
            return "\(String(format: "%.1f", megaBytes)) MB"
        }
        let gigaBytes = megaBytes / Float(1024)
        return "\(String(format: "%.1f", gigaBytes)) GB"
    }
}

extension URL {
    var size: Int {
        guard let values = try? self.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]) else { return 0 }
        return values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0
    }
}

extension URL {

    var exists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var dirExists: Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func contents() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)
    }

    var implicitContents: [URL] {
        (try? contents()) ?? []
    }

}
