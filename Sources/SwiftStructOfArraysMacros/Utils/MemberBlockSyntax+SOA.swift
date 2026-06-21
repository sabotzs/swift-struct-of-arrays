import SwiftSyntax
import SwiftSyntaxBuilder

extension MemberBlockSyntax {
    func getVariableDecls() -> [VariableDeclSyntax] {
        return self.members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }
    }
}
