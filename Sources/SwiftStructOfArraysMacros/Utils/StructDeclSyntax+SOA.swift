import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics

extension StructDeclSyntax {
    func getVariableDecls() -> [VariableDeclSyntax] {
        return self.memberBlock.members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }
    }

    func getNestedTypeDecls() -> [DeclSyntaxProtocol] {
        let types: [DeclSyntaxProtocol.Type] = [
            ActorDeclSyntax.self,
            ClassDeclSyntax.self,
            EnumDeclSyntax.self,
            ProtocolDeclSyntax.self,
            StructDeclSyntax.self,
            TypeAliasDeclSyntax.self,
        ]
        return self.memberBlock.members.lazy
            .map { $0.decl }
            .filter { decl in
                types.contains { type in
                    decl.is(type)
                }
            }
    }
}
