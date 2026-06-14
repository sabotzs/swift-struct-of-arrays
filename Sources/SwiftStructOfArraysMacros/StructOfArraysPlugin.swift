import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct StructOfArraysPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SOAMacro.self,
    ]
}
