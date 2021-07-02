//
//  main.swift
//  NitrolessAutomator
//
//  Created by Andromeda on 02/07/2021.
//

import AppKit

let currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let emotesDirectory = currentPath.appendingPathComponent("emotes")
var files = [String: ImageType]()

func cacheImages() {
    guard emotesDirectory.dirExists else {
        print("Making Emotes Directory")
        try? FileManager.default.createDirectory(at: emotesDirectory, withIntermediateDirectories: true, attributes: nil)
        return
    }
    guard let contents = try? emotesDirectory.contents(),
          !contents.isEmpty else {
        print("No Files Found at Path")
        return
    }
    for file in contents {
        let name = file.lastPathComponent
        let split = name.split(separator: ".")
        guard split.count == 2,
              let type = ImageType(rawValue: String(split[1])) else { continue }
        let fileName = String(split[0])
        if type == .png {
            guard var image = NSImage(contentsOf: file) else {
                print("\(name) is not a valid image")
                continue
            }
            let size = image.size
            let max = max(size.height, size.width)
            if max > 48 {
                image = ImageProcessor.resize(image)
                do {
                    try image.savePNGRepresentationToURL(url: file)
                } catch {
                    print("Failed to save \(file)")
                }
            }
        } else {
            guard let data = try? Data(contentsOf: file) else { continue }
            guard ImageProcessor.saveGif(gif: data, directory: file) else {
                print("Failed to Process Gif \(fileName)")
                continue
            }
        }
        files[fileName] = type
    }
}

func generateJson() {
    let path = currentPath.appendingPathComponent("index").appendingPathExtension("json")
    guard let data = try? Data(contentsOf: path),
          var dict = try? JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as? [String: Any] else {
        print("No Valid index.json found")
        return
    }
    var emotes = [[String: String]]()
    for file in files {
        let dict: [String: String] = [
            "name": file.key,
            "type": ".\(file.value.rawValue)"
        ]
        emotes.append(dict)
    }
    dict["emotes"] = emotes
    guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else {
        print("Unknown Error when creating Json Data")
        return
    }
    do {
        try jsonData.write(to: path)
    } catch {
        print(error)
        return
    }
}

cacheImages()
generateJson()
