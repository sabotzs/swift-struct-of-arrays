import SwiftSyntax
import SwiftSyntaxBuilder

extension DeclSyntaxProtocol {
    var isTypeDecl: Bool {
        self is TypeDeclSyntaxProtocol
    }

    var typeIdentifier: String {
        guard let typeDecl = self as? TypeDeclSyntaxProtocol else {
            preconditionFailure("DeclSyntaxProtocol is not a type declaration: \(self)")
        }

        return typeDecl.name.text
    }
}
