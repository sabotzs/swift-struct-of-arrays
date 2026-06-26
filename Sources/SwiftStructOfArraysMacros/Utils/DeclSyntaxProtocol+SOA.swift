import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics

extension DeclSyntaxProtocol {
    func getVariableDecls() throws(SOAError) -> [VariableDeclSyntax] {
        if let classDecl = self.as(ClassDeclSyntax.self) {
            return classDecl.memberBlock.getVariableDecls()
        }

        if let structDecl = self.as(StructDeclSyntax.self) {
            return structDecl.memberBlock.getVariableDecls()
        }

        throw .notStructOrClass
    }

    func getNestedTypeDecls() throws(SOAError) -> [DeclSyntaxProtocol] {
        if let classDecl = self.as(ClassDeclSyntax.self) {
            return classDecl.memberBlock.getNestedTypeDecls()
        }

        if let structDecl = self.as(StructDeclSyntax.self) {
            return structDecl.memberBlock.getNestedTypeDecls()
        }

        throw .notStructOrClass
    }
}
