// Copyright © 2017 andrewwoz

import Foundation

/// Read text file line by line
public class LineReader {
    public let path: String

    fileprivate let file: UnsafeMutablePointer<FILE>!

    init?(path: String) {
        self.path = path
        file = fopen(path, "r")
        guard file != nil else { return nil }
    }

    public var nextLine: String? {
        var line: UnsafeMutablePointer<CChar>?
        var linecap: Int = 0
        defer { free(line) }
        return getline(&line, &linecap, file) > 0 ? String(cString: line!) : nil
    }

    deinit {
        fclose(file)
    }
}

extension LineReader: Sequence {
    public func makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            self.nextLine
        }
    }
}

// Usage: (from https://github.com/andrewwoz/LineReader)
// import Foundation
//
// let x = LineReader(path: "<#path to file#>")
//
// guard let reader = x else {
//    throw NSError(domain: "FileNotFound", code: 404, userInfo: nil)
// }
//
//
// for line in reader {
//    print(line)
// }
