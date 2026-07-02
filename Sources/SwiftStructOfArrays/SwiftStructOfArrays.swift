// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(peer)
public macro SOA(named: String? = nil) = #externalMacro(module: "SwiftStructOfArraysMacros", type: "SOAMacro")
