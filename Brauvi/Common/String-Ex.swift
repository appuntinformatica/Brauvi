import UIKit

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    mutating func renamedIfNotUnique() {
        let ranges = self.ranges(of: "(?<=\\().*?(?=\\))", options: .regularExpression)
        var replaced = false
        if let range = ranges.last {
            if self.distance(from: startIndex , to: range.upperBound) == self.characters.count - 1 {
                if let n = Int(self.substring(with: range)) {
                    self.replaceSubrange(range, with: "\(n + 1)")
                    replaced = true
                }
            }
        }
        if !replaced {
            self = "\(self) (0)"
        }
    }
    func getPathExtension() -> String {
        return (self as NSString).pathExtension
    }
    func convertHtmlSymbols() -> String {
        // https://dev.w3.org/html5/html-author/charref
        var htmlConverted = self.replacingOccurrences(of: "\n", with: "<br/>")
        htmlConverted = htmlConverted.replacingOccurrences(of: "&", with: "&amp;")
        htmlConverted = htmlConverted.replacingOccurrences(of: "<", with: "&lt;")
        htmlConverted = htmlConverted.replacingOccurrences(of: ">", with: "&gt;")
        return htmlConverted
    }

}
