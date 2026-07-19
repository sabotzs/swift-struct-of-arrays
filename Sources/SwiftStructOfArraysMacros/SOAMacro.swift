import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SOAMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        do {
            return try expand(declaration: declaration)
        } catch {
            context.addDiagnostics(from: error, node: node)
            return []
        }
    }

    static func expand(declaration: DeclSyntaxProtocol) throws(SOAError) -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw .notStruct
        }

        let nestedTypeIdentifiers = structDecl.getNestedTypeDecls()
            .map { $0.typeIdentifier }

        let variableDecls = structDecl.getVariableDecls().lazy
            .filter { !($0.isStatic || $0.isAccessor) }
            .flatMap { $0.toFlatBindings() }
            .map { $0.toFullType(baseTypeId: structDecl.name.text, nestedTypeIds: nestedTypeIdentifiers) }

        let inheritanceClause = InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("RandomAccessCollection")))
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("MutableCollection")))
            }

        let soaStructDecl = try StructDeclSyntax.initWithTypedThrow(
            name: .identifier("\(structDecl.name.text)SOA"),
            inheritanceClause: inheritanceClause
        ) { () throws(SOAError) -> MemberBlockItemListSyntax in
            variableDecls.map { $0.toArrayType() }
            generateInitDecls(for: structDecl, variableDecls: variableDecls)
            try generateCollectionConformanceDecls(for: structDecl, variableDecls: variableDecls)
            generateArrayMethods(for: structDecl, variableDecls: variableDecls)
        }

        return [DeclSyntax(soaStructDecl)]
    }

    private static func generateInitDecls(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> [DeclSyntax] {
        return [
            generateSequenceInitDecl(for: structDecl, variableDecls: variableDecls),
            generateRepeatingInitDecl(for: structDecl, variableDecls: variableDecls),
        ]
    }

    private static func generateSequenceInitDecl(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> DeclSyntax {
        let signature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(
                    firstName: .wildcardToken(),
                    secondName: .identifier("sequence"),
                    type: SomeOrAnyTypeSyntax(
                        someOrAnySpecifier: .keyword(.some),
                        constraint: IdentifierTypeSyntax(
                            name: .identifier("Sequence"),
                            genericArgumentClause: GenericArgumentClauseSyntax {
                                GenericArgumentSyntax(
                                    argument: .type(TypeSyntax(IdentifierTypeSyntax(name: .identifier(structDecl.name.text)))),
                                )
                            }
                        )
                    )
                )
            }
        )

        let codeBlock = CodeBlockSyntax {
            variableDecls.map { variableDecl in
                let expr = InfixOperatorExprSyntax(
                    leftOperand: variableDecl.selfDeclReferenceExpr,
                    operator: AssignmentExprSyntax(),
                    rightOperand: FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: .identifier("sequence")),
                            declName: DeclReferenceExprSyntax(baseName: .identifier("map"))
                        ),
                        leftParen: nil,
                        arguments: LabeledExprListSyntax { },
                        rightParen: nil,
                        trailingClosure: ClosureExprSyntax {
                            let expr = MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: .dollarIdentifier("$0")),
                                declName: DeclReferenceExprSyntax(baseName: .identifier(variableDecl.nameIdentifier))
                            )
                            CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
                        }
                    )
                )
                return CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
            }
        }
        return DeclSyntax(
            InitializerDeclSyntax(
                leadingTrivia: .newlines(2),
                signature: signature,
                body: codeBlock
            )
        )
    }

    private static func generateRepeatingInitDecl(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> DeclSyntax {
        let signature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(
                    firstName: .identifier("repeating"),
                    secondName: .identifier(structDecl.name.text.lowercased()),
                    type: TypeSyntax(IdentifierTypeSyntax(name: .identifier(structDecl.name.text)))
                )
                FunctionParameterSyntax(
                    firstName: .identifier("count"),
                    type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int")))
                )
            }
        )

        let codeBlock = CodeBlockSyntax {
            variableDecls.map { variableDecl in
                let expr = InfixOperatorExprSyntax(
                    leftOperand: variableDecl.selfDeclReferenceExpr,
                    operator: AssignmentExprSyntax(),
                    rightOperand: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Array")),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                label: .identifier("repeating"),
                                colon: .colonToken(),
                                expression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: .identifier(structDecl.name.text.lowercased())),
                                    declName: DeclReferenceExprSyntax(baseName: .identifier(variableDecl.nameIdentifier))
                                )
                            )
                            LabeledExprSyntax(
                                label: .identifier("count"),
                                colon: .colonToken(),
                                expression: DeclReferenceExprSyntax(baseName: .identifier("count"))
                            )
                        },
                        rightParen: .rightParenToken()
                    )
                )
                return CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
            }
        }

        return DeclSyntax(
            InitializerDeclSyntax(
                leadingTrivia: .newlines(2),
                signature: signature,
                body: codeBlock
            )
        )
    }

    private static func generateCollectionConformanceDecls(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) throws(SOAError) -> [DeclSyntax] {
        return [
            generateStartIndex(),
            try generateEndIndex(variableDecls: variableDecls),
            generateIndexAfter(),
            generateSubscript(for: structDecl, variableDecls: variableDecls),
        ]
    }

    private static func generateStartIndex() -> DeclSyntax {
        let codeBlock = CodeBlockItemListSyntax {
            CodeBlockItemSyntax(item: .expr(ExprSyntax(IntegerLiteralExprSyntax(integerLiteral: 0))))
        }

        let decl = VariableDeclSyntax(
            leadingTrivia: .newlines(2),
            bindingSpecifier: .keyword(.var)
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("startIndex")),
                typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int")))),
                accessorBlock: AccessorBlockSyntax(accessors: .getter(codeBlock))
            )
        }

        return DeclSyntax(decl)
    }

    private static func generateEndIndex(
        variableDecls: some Sequence<VariableDeclSyntax>
    ) throws(SOAError) -> DeclSyntax {
        guard let variableDecl = variableDecls.first(where: { _ in true }) else {
            throw .noMemberVariables
        }

        let codeBlock = CodeBlockItemListSyntax {
            let expr = MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: .identifier(variableDecl.nameIdentifier)),
                declName: DeclReferenceExprSyntax(baseName: .identifier("count"))
            )
            CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
        }

        let decl = VariableDeclSyntax(
            leadingTrivia: .newlines(2),
            bindingSpecifier: .keyword(.var)
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("endIndex")),
                typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int")))),
                accessorBlock: AccessorBlockSyntax(accessors: .getter(codeBlock))
            )
        }

        return DeclSyntax(decl)
    }

    private static func generateIndexAfter() -> DeclSyntax {
        let decl = FunctionDeclSyntax(
            leadingTrivia: .newlines(2),
            name: .identifier("index"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(
                        firstName: .identifier("after"),
                        secondName: .identifier("i"),
                        type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int")))
                    )
                },
                returnClause: ReturnClauseSyntax(type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int"))))
            ),
            body: CodeBlockSyntax {
                let expr = InfixOperatorExprSyntax(
                    leftOperand: DeclReferenceExprSyntax(baseName: .identifier("i")),
                    operator: BinaryOperatorExprSyntax(operator: .binaryOperator("+")),
                    rightOperand: IntegerLiteralExprSyntax(integerLiteral: 1)
                )
                CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
            }
        )
        return DeclSyntax(decl)
    }

    private static func generateSubscript(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> DeclSyntax {
        let decl = SubscriptDeclSyntax(
            leadingTrivia: .newlines(2),
            parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(
                    firstName: .identifier("index"),
                    type: TypeSyntax(IdentifierTypeSyntax(name: .identifier("Int")))
                )
            },
            returnClause: ReturnClauseSyntax(type: IdentifierTypeSyntax(name: .identifier(structDecl.name.text))),
            accessorBlock: AccessorBlockSyntax(accessors: .accessors(AccessorDeclListSyntax {
                generateSubscriptGetAccessor(for: structDecl, variableDecls: variableDecls)
                generateSubscriptSetAccessor(for: structDecl, variableDecls: variableDecls)
            }))
        )
        return DeclSyntax(decl)
    }

    private static func generateSubscriptGetAccessor(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> AccessorDeclSyntax {
        let index = DeclReferenceExprSyntax(baseName: .identifier("index"))
        let arguments = LabeledExprListSyntax {
            variableDecls.map { variableDecl in
                let variableDeclIdentifier = TokenSyntax.identifier(variableDecl.nameIdentifier)
                let calledExpr = DeclReferenceExprSyntax(baseName: variableDeclIdentifier)
                return LabeledExprSyntax(
                    label: variableDeclIdentifier,
                    colon: .colonToken(),
                    expression: SubscriptCallExprSyntax(
                        calledExpression: calledExpr,
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(expression: index)
                        }
                    )
                )
            }
        }
        let expr = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(structDecl.name.text)),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken()
        )
        return AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
            CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
        }
    }

    private static func generateSubscriptSetAccessor(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> AccessorDeclSyntax {
        let setValueIdentifier = TokenSyntax.identifier(structDecl.name.text.lowercased())
        let parameter = AccessorParametersSyntax(name: setValueIdentifier)
        let index = DeclReferenceExprSyntax(baseName: .identifier("index"))
        return AccessorDeclSyntax(accessorSpecifier: .keyword(.set), parameters: parameter) {
            variableDecls.map { variableDecl in
                let variableDeclIdentifier = TokenSyntax.identifier(variableDecl.nameIdentifier)
                let calledExpr = DeclReferenceExprSyntax(baseName: variableDeclIdentifier)
                let subscriptCallExpr = SubscriptCallExprSyntax(
                    calledExpression: calledExpr,
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(expression: index)
                    }
                )
                let memberAccessExpr = MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: setValueIdentifier),
                    declName: DeclReferenceExprSyntax(baseName: variableDeclIdentifier)
                )
                let expr = InfixOperatorExprSyntax(
                    leftOperand: subscriptCallExpr,
                    operator: AssignmentExprSyntax(),
                    rightOperand: memberAccessExpr
                )
                return CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
            }
        }
    }

    private static func generateArrayMethods(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> [DeclSyntax] {
        return [
            generateReserveCapacity(variableDecls: variableDecls),
            generateAppend(for: structDecl, variableDecls: variableDecls),
        ]
    }

    private static func generateReserveCapacity(
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> DeclSyntax {
        let reserveCapacity = TokenSyntax.identifier("reserveCapacity")
        let minimumCapacity = TokenSyntax.identifier("minimumCapacity")
        let signature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax {
                FunctionParameterSyntax(
                    firstName: .wildcardToken(),
                    secondName: minimumCapacity,
                    type: IdentifierTypeSyntax(name: .identifier("Int"))
                )
            }
        )
        let codeBlock = CodeBlockSyntax {
            variableDecls.map { variableDecl in
                let expr = FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(baseName: .identifier(variableDecl.nameIdentifier)),
                        declName: DeclReferenceExprSyntax(baseName: reserveCapacity)
                    ),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: minimumCapacity))
                    },
                    rightParen: .rightParenToken()
                )
                return CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
            }
        }
        let decl = FunctionDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.mutating))
            },
            name: reserveCapacity,
            signature: signature,
            body: codeBlock
        )
        return DeclSyntax(decl)
    }

    private static func generateAppend(
        for structDecl: StructDeclSyntax,
        variableDecls: some Sequence<VariableDeclSyntax>
    ) -> DeclSyntax {
        let structDeclInstance = TokenSyntax.identifier(structDecl.name.text.lowercased())
        let append = TokenSyntax.identifier("append")
        let decl = FunctionDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.mutating))
            },
            name: append,
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(
                        firstName: .wildcardToken(),
                        secondName: structDeclInstance,
                        type: IdentifierTypeSyntax(name: .identifier(structDecl.name.text))
                    )
                },
            ),
            body: CodeBlockSyntax {
                variableDecls.map { variableDecl in
                    let variableDeclName = TokenSyntax.identifier(variableDecl.nameIdentifier)
                    let expr = FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: variableDeclName),
                            declName: DeclReferenceExprSyntax(baseName: append)
                        ),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                expression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: structDeclInstance),
                                    declName: DeclReferenceExprSyntax(baseName: variableDeclName)
                                )
                            )
                        },
                        rightParen: .rightParenToken()
                    )
                    return CodeBlockItemSyntax(item: .expr(ExprSyntax(expr)))
                }
            },
        )
        return DeclSyntax(decl)
    }
}
