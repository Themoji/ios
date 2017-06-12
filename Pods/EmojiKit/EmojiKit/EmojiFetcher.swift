//
//  Fetcher.swift
//  EmojiKit
//
//  Created by Dasmer Singh on 12/20/15.
//  Copyright © 2015 Dastronics Inc. All rights reserved.
//

import Foundation

public struct EmojiFetcher {

    // MARK: - Properties

    fileprivate let backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()


    // MARK: - Initializers

    public init() {}

    // MARK: - Functions

    public func query(_ searchString: String, completion: @escaping (([Emoji]) -> Void)) {
        cancelFetches()

        let operation = EmojiFetchOperation(searchString: searchString)

        operation.completionBlock = {

            if operation.isCancelled {
                return;
            }

            DispatchQueue.main.async {
                completion(operation.results)
            }
        }

        backgroundQueue.addOperation(operation)
    }

    public func cancelFetches() {
        backgroundQueue.cancelAllOperations()
    }

}

private final class EmojiFetchOperation: Operation {

    static let allEmoji: [Emoji] = {
        guard let path = Bundle(for: EmojiFetchOperation.self).path(forResource: "AllEmoji", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonDictionaries = jsonObject as? [JSONDictionary] else { return [] }

        return jsonDictionaries.flatMap { Emoji(dictionary: $0) }
    }()


    // MARK: - Properties

    let searchString: String
    var results: [Emoji] = []


    // MARK: - Initializers

    init(searchString: String) {
        self.searchString = searchString
    }


    // MARK: - NSOperation

    override func main() {
        let lowercaseSearchString = self.searchString.lowercased()
        let allEmoji = type(of: self).allEmoji
        guard !isCancelled else { return }

        var results = [Emoji]()

        // Matches of the full names of the emoji
        results += allEmoji.filter { $0.name.hasPrefix(lowercaseSearchString) }
        guard !isCancelled else { return }

        // Matches of individual words in the name
        results += allEmoji.filter { emoji in
            guard results.index(of: emoji) == nil else { return false }

            var validResult = false

            let emojiNameWords = emoji.name.characters.split{$0 == " "}.map(String.init)

            for emojiNameWord in emojiNameWords {
                if emojiNameWord.hasPrefix(lowercaseSearchString) {
                    validResult = true
                    break
                }
            }
            return validResult
        }
        guard !isCancelled else { return }

        // Alias matches
        results += allEmoji.filter { emoji in
            guard results.index(of: emoji) == nil else { return false }

            var validResult = false

                for alias in emoji.aliases {
                    if alias.hasPrefix(lowercaseSearchString) {
                        validResult = true
                        break
                    }
                }

            return validResult
        }
        guard !isCancelled else { return }

        // Group matches
        results += allEmoji.filter { emoji in
            guard results.index(of: emoji) == nil else { return false }

            var validResult = false

            for group in emoji.groups {
                if lowercaseSearchString.hasPrefix(group) {
                    validResult = true
                    break
                }
            }

            return validResult
        }
        guard !isCancelled else { return }

        self.results = results
    }
}
