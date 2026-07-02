import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest
@testable import SwiftStructOfArraysMacros

final class StructDeclSyntaxGetVariableDeclsTests: XCTestCase {
    func testGetVariableDeclsFromStruct() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            var health: Int
            var mana: Int
            var name: String
        }
        """)
        let variableDecls = structDecl.getVariableDecls().map { "\($0.trimmed)" }

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
        let variableDecls = structDecl.getVariableDecls().map { "\($0.trimmed)" }

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
        let variableDecls = structDecl.getVariableDecls().map { "\($0.trimmed)" }

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

        let variableDecls = structDecl.getVariableDecls().map { "\($0.trimmed)" }

        XCTAssertEqual(variableDecls, [])
    }
}

final class StructDeclSyntaxGetNestedTypeDeclsTests: XCTestCase {
    func testGetNestedTypeDeclsFromStructWithNoNestedTypes() throws {
        let structDecl = try StructDeclSyntax("struct Monster { }")

        let nestedTypeDecls = structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        XCTAssertEqual(nestedTypeDecls, [])
    }

    func testGetNestedTypeDeclsRecognizesActor() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            actor Health { }
        }
        """)
        let variableDecls = structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "actor Health { }",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetNestedTypeDeclsRecognizesClass() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            class Health { }
        }
        """)
        let variableDecls = structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "class Health { }",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetNestedTypeDeclsRecognizesEnum() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            enum Kind { }
        }
        """)
        let variableDecls = structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "enum Kind { }",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetNestedTypeDeclsRecognizesProtocol() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            protocol Kind { }
        }
        """)
        let variableDecls = structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "protocol Kind { }",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetNestedTypeDeclsRecognizesStruct() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            struct Kind { }
        }
        """)
        let variableDecls = structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "struct Kind { }",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }

    func testGetNestedTypeDeclsRecognizesTypeAlias() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            typealias Health = Int
        }
        """)
        let variableDecls = structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "typealias Health = Int",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }
}
