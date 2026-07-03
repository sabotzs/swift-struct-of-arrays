// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(peer, names: suffixed(SOA))
public macro SOA() = #externalMacro(module: "SwiftStructOfArraysMacros", type: "SOAMacro")
