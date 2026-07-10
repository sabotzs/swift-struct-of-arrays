import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SOAMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        do {
            return try expand(declaration: declaration)
        } catch {
            context.addDiagnostics(from: error, node: node)
            return []
        }
    }

    static func expand(declaration: DeclSyntaxProtocol) throws(SOAError) -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw .notStruct
        }

        let nestedTypeIdentifiers = structDecl.getNestedTypeDecls()
            .map { $0.typeIdentifier }

        let variableDecls = structDecl.getVariableDecls().lazy
            .flatMap { $0.toFlatBindings() }
            .filter { !($0.isStatic || $0.isAccessor) }
            .map { $0.toFullType(baseTypeId: structDecl.name.text, nestedTypeIds: nestedTypeIdentifiers) }

        let soaStructDecl = StructDeclSyntax(name: .identifier("\(structDecl.name.text)SOA")) {
            variableDecls.map { $0.toArrayType() }
        }

        return [DeclSyntax(soaStructDecl)]
    }
}
