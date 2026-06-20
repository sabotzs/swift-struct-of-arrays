import SwiftSyntax
import SwiftSyntaxBuilder

extension  VariableDeclSyntax {
    func toFlatBindings() -> [VariableDeclSyntax] {
        let specifier: Keyword = self.bindingSpecifier.tokenKind == .keyword(.let) ? .let : .var
        var typelessIds: [IdentifierPatternSyntax] = []
        return self.bindings.flatMap { binding -> [VariableDeclSyntax] in
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                return []
            }
            guard var typeAnnotation = binding.typeAnnotation else {
                typelessIds.append(identifier)
                return []
            }
            typeAnnotation.trailingTrivia = .backslashes(0)
            typelessIds.append(identifier)
            defer { typelessIds.removeAll() }
            return typelessIds.map {
                var name = PatternSyntax($0)
                name.leadingTrivia = .space
                return VariableDeclSyntax(
                    modifiers: self.modifiers,
                    specifier,
                    name: name,
                    type: typeAnnotation
                )
            }
        }
    }
}
