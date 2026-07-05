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

final class VariableDeclSyntaxToArrayTests: XCTestCase {
    func testToArrayPreservesVarBinding() throws {
        let decl = try VariableDeclSyntax("var index: Int")
        let arrayType = decl.toArrayType().withTestTrivia
        let arrayTypeCode = "\(arrayType)"

        let expectedDeclCode = "var index: [Int]"

        XCTAssertEqual(arrayTypeCode, expectedDeclCode)
    }

    func testToArrayAlwaysGeneratesVarBinding() throws {
        let decl = try VariableDeclSyntax("let index: Int")
        let arrayType = decl.toArrayType().withTestTrivia
        let arrayTypeCode = "\(arrayType)"

        let expectedDeclCode = "var index: [Int]"

        XCTAssertEqual(arrayTypeCode, expectedDeclCode)
    }

    func testToArrayPreservesModifiers() throws {
        let modifiers = [
            "",
            "static ",
            "nonisolated ",
            "private ",
            "public ",
            "internal ",
            "fileprivate ",
        ]
        let codes = try modifiers.lazy
            .map { $0 + "var index: Int" }
            .map { try VariableDeclSyntax(SyntaxNodeString(stringLiteral: $0)) }
            .map { $0.toArrayType().withTestTrivia }
            .map { "\($0)" }

        let expected = modifiers.map { $0 + "var index: [Int]" }

        XCTAssertEqual(Array(codes), expected)
    }
}

final class VariableDeclSyntaxIsStaticTests: XCTestCase {
    func testStaticVariableReturnsTrue() throws {
        let decl = try VariableDeclSyntax("static let number = 10")

        XCTAssertTrue(decl.isStatic)
    }

    func testNonStaticVariableReturnsFalse() throws {
        let decl = try VariableDeclSyntax("let number = 10")

        XCTAssertFalse(decl.isStatic)
    }
}

final class VariableDeclSyntaxIsAccessorTests: XCTestCase {
    func testAccessorVariableReturnsTrue() throws {
        let decl = try VariableDeclSyntax("""
        var prop: Int {
            get { _prop }
            set { _prop = newValue }
        }
        """)

        XCTAssertTrue(decl.isAccessor)
    }

    func testComputedPropertyReturnsTrue() throws {
        let decl = try VariableDeclSyntax("""
        var isAlive: Int {
            health != 0
        }
        """)

        XCTAssertTrue(decl.isAccessor)
    }

    func testSimpleVariableReturnsFalse() throws {
        let decl = try VariableDeclSyntax("var prop: Int")

        XCTAssertFalse(decl.isAccessor)
    }
}

final class VariableDeclSyntaxToFullTypeTests: XCTestCase {
    func testSimpleType() throws {
        let baseType = IdentifierTypeSyntax(name: .identifier("Monster"))
        let decl = try VariableDeclSyntax("var kind: Kind")
        let fullType = decl.toFullType(base: baseType).withTestTrivia
        let result = "\(fullType)"

        let expectedDecl = "var kind: Monster.Kind"

        XCTAssertEqual(result, expectedDecl)
    }
}

private extension VariableDeclSyntax {
    var withTestTrivia: VariableDeclSyntax {
        var decl = self
        decl.bindings[bindings.startIndex].pattern.leadingTrivia = .space
        decl.bindings[bindings.startIndex].typeAnnotation?.type.leadingTrivia = .space
        return decl
    }
}
