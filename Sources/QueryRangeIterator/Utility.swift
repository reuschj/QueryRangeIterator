//
//  Utility.swift
//  
//
//  Created by Justin Reusch on 10/4/20.
//

import Foundation

// These are just alternative ways to call the static function

/// Reassembles content, but allowing transforms to the query content and/or the non-query content
/// - Parameter query The search query
/// - Parameter content The content to look for the query in
/// - Parameter queryTransform An optional transform closure to run on all found query
public func transformQuery<Content: StringProtocol>(
    _ query: Content,
    in content: Content,
    _ queryTransform: @escaping QueryRangeIterator<Content>.ContentTransform
) -> String {
    return QueryRangeIterator.transform(query, in: content, queryTransform)
}

/// Reassembles content, but allowing transforms to the query content and/or the non-query content
/// - Parameter content The content to look for the query in
/// - Parameter query The search query
/// - Parameter nonQueryTransform  An optional transform closure to run on all non-query content
/// - Parameter queryTransform An optional transform closure to run on all found query
public func reassembleContent<Content: StringProtocol>(
    _ content: Content,
    with query: Content,
    nonQueryTransform: QueryRangeIterator<Content>.ContentTransform? = nil,
    queryTransform: QueryRangeIterator<Content>.ContentTransform? = nil
) -> String {
    return QueryRangeIterator.reassemble(content, with: query, nonQueryTransform: nonQueryTransform, queryTransform: queryTransform)
}
