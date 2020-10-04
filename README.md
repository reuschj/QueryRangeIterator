# QueryRangeIterator

This package provides an iterator (conforming to `IteratorProtocol`) which finds all ranges of a query within the searched content. The iterator can be collected to an `Array<Range<String.Index>>`, mapped or used manually (by calling the `next()` method until no further result is returned). 

## Iteration

To use as an iterator:
```swift
let query = "needle"
let content = "haystackneedlehaystackneedlehaystack"
var occurrences = QueryRangeIterator(query, in: content)
while let next = occurrences.next() {
    print(String(content[$0]))
}
```

## Collecting to an Array

This collects all ranges to an array of string indices.
```swift
let query = "needle"
let content = "haystackneedlehaystackneedlehaystack"
var occurrences = QueryRangeIterator(query, in: content)
let needles = occurrences.collect().map {
    String(content[$0])
}
print(needles) // ["needle", "needle"]
```

You can also collect with a side-effect (for example, printing). The side-effect will not affect the contents of the collected return.

```swift
let query = "needle"
let content = "haystackneedlehaystackneedlehaystack"
var occurrences = QueryRangeIterator(query, in: content)
let ranges = occurrences.collectWithSideEffect {
    print(String(content[$0]))
}
```

## Collecting to Strings

This collects all ranges and extracts the string from the original content at those indices.
```swift
let query = "needle"
let content = "haystackneedlehaystackneedlehaystack"
var occurrences = QueryRangeIterator(query, in: content)
// Inversion gets everything that isn't the query.
var rest = QueryRangeIterator(query, in: content, inverted: true)
print(occurrences.collectStrings()) // ["needle", "needle"]
print(rest.collectStrings()) // ["haystack", "haystack", "haystack"]
```

## Mapping

This maps each range and allows you set a callback that transforms the collected values.
```swift
let query = "needle"
let content = "haystackneedlehaystackneedlehaystack"
var occurrences = QueryRangeIterator(query, in: content)
let needles = occurrences.map {
    String(content[$0])
}
print(needles) // ["needle", "needle"]
```

## Transforming the query
If the end goal is performing a transform on all the found query, this is a convenience static method to do so.
```swift
let content = "haystackneedlehaystackneedlehaystack"
let transformed = QueryRangeIterator.transform("needle", in: content) { $0.uppercased() }
print(transformed) // "haystackNEEDLEhaystackNEEDLEhaystack"
```

## Reassembling the content
If you also need to transform the non-query content, you can with this static method:
```swift
let content = "haystackneedlehaystackneedlehaystack"
let transformed = QueryRangeIterator.reassemble(content, with: "needle",
    nonQueryTransform: { $0.uppercased() },
    queryTransform: { $0.capitalized }
)
print(transformed) // "HAYSTACKNeedleHAYSTACKNeedleHAYSTACK"
```
