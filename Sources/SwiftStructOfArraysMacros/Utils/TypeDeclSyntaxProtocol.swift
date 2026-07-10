import SwiftSyntax

protocol TypeDeclSyntaxProtocol: DeclSyntaxProtocol {
    var name: TokenSyntax { get }
}

extension ActorDeclSyntax: TypeDeclSyntaxProtocol { }
extension ClassDeclSyntax: TypeDeclSyntaxProtocol { }
extension EnumDeclSyntax: TypeDeclSyntaxProtocol { }
extension ProtocolDeclSyntax: TypeDeclSyntaxProtocol { }
extension StructDeclSyntax: TypeDeclSyntaxProtocol { }
extension TypeAliasDeclSyntax: TypeDeclSyntaxProtocol { }

let typeDeclSyntaxProtocolTypes: [TypeDeclSyntaxProtocol.Type] = [
    ActorDeclSyntax.self,
    ClassDeclSyntax.self,
    EnumDeclSyntax.self,
    ProtocolDeclSyntax.self,
    StructDeclSyntax.self,
    TypeAliasDeclSyntax.self
]
