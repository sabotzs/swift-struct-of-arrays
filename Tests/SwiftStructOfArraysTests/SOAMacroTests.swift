import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SwiftStructOfArraysMacros)
import SwiftStructOfArraysMacros

let testMacros: [String: Macro.Type] = [
    "SOA": SOAMacro.self,
]
#endif

final class SOAMacroTests: XCTestCase {
    func testSOAMacroOnStructWithSeparateVariableDecls() throws {
        #if canImport(SwiftStructOfArraysMacros)
        assertMacroExpansion(
            """
            @SOA
            struct Monster {
                var health: Int
                let isAlive: Bool
            }
            """,
            expandedSource: """
            struct Monster {
                var health: Int
                let isAlive: Bool
            }

            struct MonsterSOA {
                var health: [Int]
                var isAlive: [Bool]
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        XCTFail("")
        #endif
    }

    func testSOAMacroOnStructWithMultipleVariableDeclsWithSameTypeInSingleLine() throws {
        #if canImport(SwiftStructOfArraysMacros)
        assertMacroExpansion(
            """
            @SOA
            struct Monster {
                var health, mana: Int
            }
            """,
            expandedSource: """
            struct Monster {
                var health, mana: Int
            }

            struct MonsterSOA {
                var health: [Int]
                var mana: [Int]
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testSOAMacroOnStructWithMultipleVariableDeclsWithDifferentTypesInSingleLine() throws {
        #if canImport(SwiftStructOfArraysMacros)
        assertMacroExpansion(
            """
            @SOA
            struct Monster {
                var health: Int, isAlive: Bool
            }
            """,
            expandedSource: """
            struct Monster {
                var health: Int, isAlive: Bool
            }

            struct MonsterSOA {
                var health: [Int]
                var isAlive: [Bool]
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
