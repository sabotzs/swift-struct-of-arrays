import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest
@testable import SwiftStructOfArraysMacros

final class DeclSyntaxProtocolGetVariableDeclsTests: XCTestCase {
    func testGetVariableDeclsThrowsFromEnum() throws {
        let enumDecl = try EnumDeclSyntax("""
        enum MonsterKind {
            case ogre
            case satyr
        }
        """)

        XCTAssertThrowsError(try enumDecl.getVariableDecls())
    }

    func testGetVariableDeclsThrowsFromActor() throws {
        let actorDecl = try ActorDeclSyntax("""
        actor Monster {
            var health: Int = 100
            var mana: Int = 100
        }
        """)

        XCTAssertThrowsError(try actorDecl.getVariableDecls())
    }

    func testGetVariableDeclsFromClass() throws {
        let structDecl = try ClassDeclSyntax("""
        class Monster {
            var health: Int = 100
            var mana: Int = 100
            var name: String = ""
        }
        """)
        let variableDecls = try structDecl.getVariableDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "var health: Int = 100",
            "var mana: Int = 100",
            "var name: String = \"\"",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetVariableDeclsFromStruct() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            var health: Int
            var mana: Int
            var name: String
        }
        """)
        let variableDecls = try structDecl.getVariableDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "var health: Int",
            "var mana: Int",
            "var name: String",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetVariableDeclsReturnsComputedVariables() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            var image: Int { 3 }
        }
        """)
        let variableDecls = try structDecl.getVariableDecls().map { "\($0.trimmed)" }

        let expectedDecls = ["var image: Int { 3 }"]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetVariableDeclsIgnoresFunctionDecls() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            let index: Int

            func fight() {}
        }
        """)
        let variableDecls = try structDecl.getVariableDecls().map { "\($0.trimmed)" }

        let expectedDecls = ["let index: Int"]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetVariableDeclsIgnoresNestedTypes() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            enum Kind {
                case ogre
                case satyr
            }
        }
        """)

        let variableDecls = try structDecl.getVariableDecls().map { "\($0.trimmed)" }

        XCTAssertEqual(variableDecls, [])
    }
}
