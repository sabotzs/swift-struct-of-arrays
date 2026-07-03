import SwiftSyntax
import SwiftSyntaxBuilder

extension DeclSyntaxProtocol {
    private var typeDeclTypes: [DeclSyntaxProtocol.Type] {
        [
            ActorDeclSyntax.self,
            ClassDeclSyntax.self,
            EnumDeclSyntax.self,
            ProtocolDeclSyntax.self,
            StructDeclSyntax.self,
            TypeAliasDeclSyntax.self,
        ]
    }

    var isTypeDecl: Bool {
        typeDeclTypes.contains { type in self.is(type) }
    }
}
