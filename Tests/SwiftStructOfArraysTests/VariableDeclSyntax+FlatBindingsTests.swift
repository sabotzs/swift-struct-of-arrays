import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest
@testable import SwiftStructOfArraysMacros

final class VariableDeclSyntaxFlatBindingsTests: XCTestCase {
    func testSingleVariable() throws {
        let code = "var animation: Int"
        let decl = try VariableDeclSyntax(SyntaxNodeString(stringLiteral: code))
        let flatDecls = decl.toFlatBindings().map { "\($0)" }

        XCTAssertEqual(flatDecls, [code])
    }
    func testMultipleVariablesSingleType() throws {
        let code = "var animation, index: Int"
        let decl = try VariableDeclSyntax(SyntaxNodeString(stringLiteral: code))
        let flatDecls = decl.toFlatBindings().map { "\($0)" }

        let expectedDecls = [
            "var animation: Int",
            "var index: Int",
        ]
        XCTAssertEqual(flatDecls, expectedDecls)
    }

    func testMultipleVariablesMixedTypes() throws {
        let decl = try VariableDeclSyntax("var animation, index: Int, name: String")
        let flatDecls = decl.toFlatBindings().map { "\($0)" }

        let expectedDecls = [
            "var animation: Int",
            "var index: Int",
            "var name: String",
        ]
        XCTAssertEqual(flatDecls, expectedDecls)
    }

    func testFlatBindingsDropsInitValue() throws {
        let decl = try VariableDeclSyntax("var index: Int = 0")
        let flatDecls = decl.toFlatBindings().map { "\($0)" }

        let expectedDecls = [ "var index: Int" ]

        XCTAssertEqual(flatDecls, expectedDecls)
    }

    func testFlatBindingPreservesModifiers() throws {
        let decl = try VariableDeclSyntax("private static var index, position: Int")
        let flatDecls = decl.toFlatBindings().map { "\($0)" }

        let expectedDecls = [
            "private static var index: Int",
            "private static var position: Int",
        ]

        XCTAssertEqual(flatDecls, expectedDecls)
    }
}
