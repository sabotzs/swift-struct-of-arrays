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

final class DeclSyntaxProtocolGetNestedTypeDecls: XCTestCase {
    func testGetNestedTypeDeclsThrowsFromEnum() throws {
        let enumDecl = try EnumDeclSyntax("enum Monster { }")

        XCTAssertThrowsError(try enumDecl.getNestedTypeDecls())
    }

    func testGetNestedTypeDeclsThrowsFromActor() throws {
        let actorDecl = try ActorDeclSyntax("actor Monster { }")

        XCTAssertThrowsError(try actorDecl.getNestedTypeDecls())
    }

    func testGetNestedTypeDeclsFromClass() throws {
        let classDecl = try ClassDeclSyntax("class Monster { }")

        let variableDecls = try classDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        XCTAssertEqual(variableDecls, [])
    }

    func testGetNestedTypeDeclsFromStruct() throws {
        let structDecl = try StructDeclSyntax("struct Monster { }")

        let variableDecls = try structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        XCTAssertEqual(variableDecls, [])
    }

    func testGetNestedTypeDeclsRecognizesActor() throws {
        let structDecl = try StructDeclSyntax("""
        struct Monster {
            actor Health { }
        }
        """)
        let variableDecls = try structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

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
        let variableDecls = try structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

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
        let variableDecls = try structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

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
        let variableDecls = try structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

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
        let variableDecls = try structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

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
        let variableDecls = try structDecl.getNestedTypeDecls().map { "\($0.trimmed)" }

        let expectedDecls = [
            "typealias Health = Int",
        ]

        XCTAssertEqual(variableDecls, expectedDecls)
    }
}
