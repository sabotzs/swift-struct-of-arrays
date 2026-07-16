import SwiftSyntax
import SwiftSyntaxBuilder

extension StructDeclSyntax {
    func getVariableDecls() -> [VariableDeclSyntax] {
        return self.memberBlock.members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }
    }

    func getNestedTypeDecls() -> [DeclSyntaxProtocol] {
        return self.memberBlock.members.lazy
            .map { $0.decl }
            .filter { $0.isTypeDecl }
    }

    static func initWithTypedThrow<E: Error>(
        leadingTrivia: Trivia? = nil,
        name: TokenSyntax,
        inheritanceClause: InheritanceClauseSyntax? = nil,
        @MemberBlockItemListBuilder memberBlockBuilder: () throws(E) -> MemberBlockItemListSyntax,
        trailingTrivia: Trivia? = nil
    ) throws(E) -> StructDeclSyntax {
        return StructDeclSyntax(
            leadingTrivia: leadingTrivia,
            name: name,
            inheritanceClause: inheritanceClause,
            memberBlock: MemberBlockSyntax(members: try memberBlockBuilder()),
            trailingTrivia: trailingTrivia
        )
    }
}
