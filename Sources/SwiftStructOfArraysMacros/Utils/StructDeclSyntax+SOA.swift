import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics

extension StructDeclSyntax {
    func getVariableDecls() -> [VariableDeclSyntax] {
        return self.memberBlock.getVariableDecls()
    }

    func getNestedTypeDecls() -> [DeclSyntaxProtocol] {
        return self.memberBlock.getNestedTypeDecls()
    }
}
