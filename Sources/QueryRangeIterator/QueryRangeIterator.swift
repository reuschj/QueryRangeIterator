//
//  QueryRangeIterator.swift
//
//
//  Created by Justin Reusch on 10/4/20.
//

import Foundation

/// An iterator (conforming to `IteratorProtocol`) which finds all ranges of a query within the searched content.
/// The iterator can be collected to an `Array<Range<String.Index>>`, mapped or used manually
///  (by calling the `next()` method until no further result is returned).
///
/// # Example
/// ```
/// let query = "needle"
/// let content = "haystackneedlehaystackneedlehaystack"
/// var occurrences = QueryRangeIterator(query, in: content)
/// // Inversion gets everything that isn't the query.
/// var rest = QueryRangeIterator(query, in: content, inverted: true)
/// print(occurrences.collectStrings())
/// print(rest.collectStrings())
/// ```
public struct QueryRangeIterator<Content> where Content: StringProtocol {
    var inverted: Bool
    let query: Content
    var currentContent: Content.SubSequence
    let fullContent: Content
    
    public init(_ query: Content, in content: Content, inverted: Bool = false) {
        self.query = query
        self.currentContent = content[content.startIndex..<content.endIndex]
        self.fullContent = content
        self.inverted = inverted
    }
}

/// Conforms to the iterator protocol
extension QueryRangeIterator: IteratorProtocol {
    public typealias Element = Range<String.Index>
    
    /// Gets the next range of the query in the iterator
    public mutating func next() -> Element? {
        if inverted {
            return nextInverted()
        }
        return nextStandard()
    }
    
    // Other methods ------------------------------------------------------------------------------------------------------------ /
    
    /// Collects all iterated elements to a collection type
    public mutating func collect() -> [Element] {
        var collection: [Element] = []
        while let next = self.next() {
            if (next.upperBound > next.lowerBound) {
                // Only collect non-empty ranges
                collection.append(next)
            }
        }
        return collection
    }
    
    /// Collects all iterated elements to a collection type and performs a side effect
    public mutating func collectWithSideEffect(_ sideEffect: (Element) -> Void) -> [Element] {
        var mappedCollection: [Element] = []
        while let next = self.next() {
            if (next.upperBound > next.lowerBound) {
                // Only collect non-empty ranges
                sideEffect(next)
                mappedCollection.append(next)
            }
        }
        return mappedCollection
    }
    
    /// Collects all iterated ranges and builds an array of strings from the original content at those ranges
    public mutating func collectStrings() -> [String] {
        let content = self.fullContent
        return self.map { String(content[$0]) }
    }
    
    /// Maps all iterated elements to a collection type
    public mutating func map<R>(_ transform: (Element) -> R) -> [R] {
        var mappedCollection: [R] = []
        while let next = self.next() {
            if (next.upperBound > next.lowerBound) {
                // Only collect non-empty ranges
                let result: R = transform(next)
                mappedCollection.append(result)
            }
        }
        return mappedCollection
    }
    
    // Type aliases ------------------------------------------------------------------------------------------------------ /
    
    public typealias ContentTransform = (String) -> String
    
    // Static ------------------------------------------------------------------------------------------------------------ /
    
    /// Reassembles content, but allowing transforms to the query content and/or the non-query content
    /// - Parameter query: The search query
    /// - Parameter content: The content to look for the query in
    /// - Parameter queryTransform: An optional transform closure to run on all found query
    public static func transform(
        _ query: Content,
        in content: Content,
        _ queryTransform: @escaping ContentTransform
    ) -> String {
        return Self.reassemble(content, with: query, nonQueryTransform: nil, queryTransform: queryTransform)
    }
    
    /// Reassembles content, but allowing transforms to the query content and/or the non-query content
    /// - Parameter content: The content to look for the query in
    /// - Parameter query: The search query
    /// - Parameter nonQueryTransform:  An optional transform closure to run on all non-query content
    /// - Parameter queryTransform: An optional transform closure to run on all found query
    public static func reassemble(
        _ content: Content,
        with query: Content,
        nonQueryTransform: ContentTransform? = nil,
        queryTransform: ContentTransform? = nil
    ) -> String {
        var selects = Self(query, in: content)
        var nonSelects = Self(query, in: content, inverted: true)
        let selectTransform = queryTransform ?? { $0 }
        let selectedSubs: [(String, String.Index)] = selects.map {
            (selectTransform(String(content[$0])), $0.lowerBound)
        }
        let nonSelectTransform = nonQueryTransform ?? { $0 }
        let nonSelectedSubs: [(String, String.Index)] = nonSelects.map {
            (nonSelectTransform(String(content[$0])), $0.lowerBound)
        }
        let merged: [String] = (selectedSubs + nonSelectedSubs).sorted { $0.1 < $1.1 }.map { $0.0 }
        return merged.joined()
    }
    
    // Private ------------------------------------------------------------------------------------------------------------ /
    
    /// Gets the next query range in the content
    private mutating func nextStandard() -> Element? {
        guard let range = currentContent.range(of: query) else { return nil }
        let endIndex = range.upperBound
        guard endIndex <= currentContent.endIndex else { return nil }
        currentContent = currentContent[endIndex..<currentContent.endIndex]
        return range
    }
    
    /// Gets the next non-query range in the content (content between queries)
    private mutating func nextInverted() -> Element? {
        let startIndex = currentContent.startIndex
        let queryRange = currentContent.range(of: query)
        let endIndex = queryRange?.lowerBound ?? currentContent.endIndex
        let nextQueryEnd = queryRange?.upperBound ?? currentContent.endIndex
        let nextStart = min(nextQueryEnd, currentContent.endIndex)
        let range = startIndex..<endIndex
        currentContent = currentContent[nextStart..<currentContent.endIndex]
        guard startIndex < endIndex || !currentContent.isEmpty else { return nil }
        return range
    }
}
