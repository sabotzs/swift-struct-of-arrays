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

        let variableDecls = structDecl.getVariableDecls().lazy
            .filter { !($0.isStatic || $0.isAccessor) }
            .flatMap { $0.toFlatBindings() }

        let soaStructDecl = StructDeclSyntax(name: .identifier("MonsterSOA")) {
            variableDecls.map { $0.toArrayType() }
        }

        return [DeclSyntax(soaStructDecl)]
    }
}
