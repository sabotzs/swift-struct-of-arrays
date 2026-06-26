import SwiftSyntax
import SwiftSyntaxBuilder

extension MemberBlockSyntax {
    func getVariableDecls() -> [VariableDeclSyntax] {
        return self.members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }
    }

    func getNestedTypeDecls() -> [DeclSyntax] {
        let types: [DeclSyntaxProtocol.Type] = [
            ActorDeclSyntax.self,
            ClassDeclSyntax.self,
            EnumDeclSyntax.self,
            ProtocolDeclSyntax.self,
            StructDeclSyntax.self,
            TypeAliasDeclSyntax.self,
        ]
        return self.members.lazy
            .map { $0.decl }
            .filter { decl in
                types.contains { type in
                    decl.is(type)
                }
            }
    }
}
