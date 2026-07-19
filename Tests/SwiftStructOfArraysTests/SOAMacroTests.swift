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
    func testSOAMacroWithSeparateVariableDecls() throws {
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

            struct MonsterSOA: RandomAccessCollection, MutableCollection {
                var health: [Int]
                var isAlive: [Bool]

                init(_ sequence: some Sequence<Monster>) {
                    self.health = sequence.map {
                        $0.health
                    }
                    self.isAlive = sequence.map {
                        $0.isAlive
                    }
                }

                init(repeating monster: Monster, count: Int) {
                    self.health = Array(repeating: monster.health, count: count)
                    self.isAlive = Array(repeating: monster.isAlive, count: count)
                }

                var startIndex: Int {
                    0
                }

                var endIndex: Int {
                    health.count
                }

                func index(after i: Int) -> Int {
                    i + 1
                }

                subscript(index: Int) -> Monster {
                    get {
                        Monster(health: health[index], isAlive: isAlive[index])
                    }
                    set(monster) {
                        health[index] = monster.health
                        isAlive[index] = monster.isAlive
                    }
                }

                mutating func reserveCapacity(_ minimumCapacity: Int) {
                    health.reserveCapacity(minimumCapacity)
                    isAlive.reserveCapacity(minimumCapacity)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        XCTFail("")
        #endif
    }

    func testSOAMacroWithMultipleVariableDeclsWithSameTypeInSingleLine() throws {
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

            struct MonsterSOA: RandomAccessCollection, MutableCollection {
                var health: [Int]
                var mana: [Int]

                init(_ sequence: some Sequence<Monster>) {
                    self.health = sequence.map {
                        $0.health
                    }
                    self.mana = sequence.map {
                        $0.mana
                    }
                }

                init(repeating monster: Monster, count: Int) {
                    self.health = Array(repeating: monster.health, count: count)
                    self.mana = Array(repeating: monster.mana, count: count)
                }

                var startIndex: Int {
                    0
                }

                var endIndex: Int {
                    health.count
                }

                func index(after i: Int) -> Int {
                    i + 1
                }

                subscript(index: Int) -> Monster {
                    get {
                        Monster(health: health[index], mana: mana[index])
                    }
                    set(monster) {
                        health[index] = monster.health
                        mana[index] = monster.mana
                    }
                }

                mutating func reserveCapacity(_ minimumCapacity: Int) {
                    health.reserveCapacity(minimumCapacity)
                    mana.reserveCapacity(minimumCapacity)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testSOAMacroWithMultipleVariableDeclsWithDifferentTypesInSingleLine() throws {
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

            struct MonsterSOA: RandomAccessCollection, MutableCollection {
                var health: [Int]
                var isAlive: [Bool]

                init(_ sequence: some Sequence<Monster>) {
                    self.health = sequence.map {
                        $0.health
                    }
                    self.isAlive = sequence.map {
                        $0.isAlive
                    }
                }

                init(repeating monster: Monster, count: Int) {
                    self.health = Array(repeating: monster.health, count: count)
                    self.isAlive = Array(repeating: monster.isAlive, count: count)
                }

                var startIndex: Int {
                    0
                }

                var endIndex: Int {
                    health.count
                }

                func index(after i: Int) -> Int {
                    i + 1
                }

                subscript(index: Int) -> Monster {
                    get {
                        Monster(health: health[index], isAlive: isAlive[index])
                    }
                    set(monster) {
                        health[index] = monster.health
                        isAlive[index] = monster.isAlive
                    }
                }

                mutating func reserveCapacity(_ minimumCapacity: Int) {
                    health.reserveCapacity(minimumCapacity)
                    isAlive.reserveCapacity(minimumCapacity)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testSOAMacroWithNestedType() throws {
        #if canImport(SwiftStructOfArraysMacros)
        assertMacroExpansion(
            """
            @SOA
            struct Monster {
                var kind: Kind
                var longitude: Position.Longitude

                enum Kind {
                    case ogre
                    case troll
                }

                struct Position {
                    struct Longitude {
                        var degrees: Int
                    }
                }
            }
            """,
            expandedSource: """
            struct Monster {
                var kind: Kind
                var longitude: Position.Longitude

                enum Kind {
                    case ogre
                    case troll
                }

                struct Position {
                    struct Longitude {
                        var degrees: Int
                    }
                }
            }

            struct MonsterSOA: RandomAccessCollection, MutableCollection {
                var kind: [Monster.Kind]
                var longitude: [Monster.Position.Longitude]

                init(_ sequence: some Sequence<Monster>) {
                    self.kind = sequence.map {
                        $0.kind
                    }
                    self.longitude = sequence.map {
                        $0.longitude
                    }
                }

                init(repeating monster: Monster, count: Int) {
                    self.kind = Array(repeating: monster.kind, count: count)
                    self.longitude = Array(repeating: monster.longitude, count: count)
                }

                var startIndex: Int {
                    0
                }

                var endIndex: Int {
                    kind.count
                }

                func index(after i: Int) -> Int {
                    i + 1
                }

                subscript(index: Int) -> Monster {
                    get {
                        Monster(kind: kind[index], longitude: longitude[index])
                    }
                    set(monster) {
                        kind[index] = monster.kind
                        longitude[index] = monster.longitude
                    }
                }

                mutating func reserveCapacity(_ minimumCapacity: Int) {
                    kind.reserveCapacity(minimumCapacity)
                    longitude.reserveCapacity(minimumCapacity)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
