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
}
