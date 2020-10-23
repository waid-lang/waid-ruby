class Programa
    attr_accessor :Statements
    def initialize
        @Statements = Array.new
    end
end

class StatementList
    attr_accessor :Statements
    def initialize
        @Statements = Array.new
    end
end

ReturnStatement = Struct.new(
    :ReturnValue # Expresión
)

VarDeclarationStatement = Struct.new(
    :Identifier,
    :Value # Expresión
)

class FuncDeclarationStatement
    attr_accessor :Identifier
    attr_accessor :Parameters
    attr_accessor :Body
    def initialize
        @Identifier = nil
        @Parameters = Array.new
        @Body = nil
    end
end

IfStatement = Struct.new(
    :Condition, # Expresión
    :Body, # StatementList
    :ElseBody # StatementList
)

WhileStatement = Struct.new(
    :Condition, # Expresión
    :Body # StatementList
)

