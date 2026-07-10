import SwiftSyntax
import SwiftSyntaxBuilder

extension DeclSyntaxProtocol {
    func `is`<S: TypeDeclSyntaxProtocol>(_ type: S.Type) -> Bool {
        return self.as(type) != nil
    }

    func `as`<S: TypeDeclSyntaxProtocol>(_ type: S.Type) -> S? {
        return S.init(self)
    }

    var isTypeDecl: Bool {
        return typeDeclSyntaxProtocolTypes.contains { self.is($0) }
    }

    var typeIdentifier: String {
        let typeDecl = typeDeclSyntaxProtocolTypes
            .compactMap {
                self.as($0)
            }
            .first
        guard let typeDecl else {
            preconditionFailure("DeclSyntaxProtocol is not a type declaration: \(self)")
        }
        return typeDecl.name.text
    }
}
