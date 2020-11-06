# WaidLang
My personal attempt at writing a programming language from scratch.

Waid is everything you never wanted. It's ugly, verbose, and it doesn't even work yet.
It's currently implemented with a custom lexer and a LL(1) parser (recursive descent), although I would like to write a LL(1) parsing table in the future.

I'm working on a tree walking interpreter at the moment, but I'm planning to write a VM in C++ in the future.

## Usage
```bash
$ ./main.rb
Usage: main [options] filename
    -t, --show-tokens                Print the tokens produced by the scanner
    -a, --show-ast                   Print the AST produced by the parser
```


***main.wd***
```py
# Recursive function to calculate nth fibonacci number
fib_rec: func(n) =>
  if n < 2 =>
    <- n
  endif
  <- !(fib_rec n - 1) + !(fib_rec n - 2)
endfn

# Iterative Function to calculate nth fibonacci number
fib_while: func(n) =>
  a => 0
  b => 1
  while b <= n =>
    prev_a => a
    a => b
    b => prev_a + b
  endwl
  <- a
endfn

main: func() =>
  num => !input
  
  # Checks if both functions return the same value
  if !(fib_rec num) == !(fib_while num) =>
    !(print 0)
  else =>
    !(print -1)
  endif
endfn

!main
```

```
$ ./main.rb -a main.wd
Program
├──FuncDecl
│  ├──Identifier
│  │  └──Identifier
│  │     └──fib_rec
│  ├──Parameters
│  │  └──Identifier
│  │     └──n
│  └──Body
│     ├──IfStatement
│     │  ├──Condition
│     │  │  └──BinaryOperation
│     │  │     ├──Left
│     │  │     │  └──Identifier
│     │  │     │     └──n
│     │  │     ├──Operator
│     │  │     │  └──<
│     │  │     └──Right
│     │  │        └──IntLiteral
│     │  │           └──2
│     │  ├──Body
│     │  │  └──ReturnStatement
│     │  │     └──Identifier
│     │  │        └──n
│     │  └──ElseBody
│     │     └──Empty
│     └──ReturnStatement
│        └──BinaryOperation
│           ├──Left
│           │  └──FunctionCall
│           │     ├──Identifier
│           │     │  └──Identifier
│           │     │     └──fib_rec
│           │     └──Arguments
│           │        └──BinaryOperation
│           │           ├──Left
│           │           │  └──Identifier
│           │           │     └──n
│           │           ├──Operator
│           │           │  └──-
│           │           └──Right
│           │              └──IntLiteral
│           │                 └──1
│           ├──Operator
│           │  └──+
│           └──Right
│              └──FunctionCall
│                 ├──Identifier
│                 │  └──Identifier
│                 │     └──fib_rec
│                 └──Arguments
│                    └──BinaryOperation
│                       ├──Left
│                       │  └──Identifier
│                       │     └──n
│                       ├──Operator
│                       │  └──-
│                       └──Right
│                          └──IntLiteral
│                             └──2
├──FuncDecl
│  ├──Identifier
│  │  └──Identifier
│  │     └──fib_while
│  ├──Parameters
│  │  └──Identifier
│  │     └──n
│  └──Body
│     ├──VariableDeclaration
│     │  ├──Identifier
│     │  │  └──Identifier
│     │  │     └──a
│     │  └──Value
│     │     └──IntLiteral
│     │        └──0
│     ├──VariableDeclaration
│     │  ├──Identifier
│     │  │  └──Identifier
│     │  │     └──b
│     │  └──Value
│     │     └──IntLiteral
│     │        └──1
│     ├──WhileStatement
│     │  ├──Condition
│     │  │  └──BinaryOperation
│     │  │     ├──Left
│     │  │     │  └──Identifier
│     │  │     │     └──b
│     │  │     ├──Operator
│     │  │     │  └──<=
│     │  │     └──Right
│     │  │        └──Identifier
│     │  │           └──n
│     │  └──Body
│     │     ├──VariableDeclaration
│     │     │  ├──Identifier
│     │     │  │  └──Identifier
│     │     │  │     └──prev_a
│     │     │  └──Value
│     │     │     └──Identifier
│     │     │        └──a
│     │     ├──VariableDeclaration
│     │     │  ├──Identifier
│     │     │  │  └──Identifier
│     │     │  │     └──a
│     │     │  └──Value
│     │     │     └──Identifier
│     │     │        └──b
│     │     └──VariableDeclaration
│     │        ├──Identifier
│     │        │  └──Identifier
│     │        │     └──b
│     │        └──Value
│     │           └──BinaryOperation
│     │              ├──Left
│     │              │  └──Identifier
│     │              │     └──prev_a
│     │              ├──Operator
│     │              │  └──+
│     │              └──Right
│     │                 └──Identifier
│     │                    └──b
│     └──ReturnStatement
│        └──Identifier
│           └──a
├──FuncDecl
│  ├──Identifier
│  │  └──Identifier
│  │     └──main
│  ├──Parameters
│  └──Body
│     ├──VariableDeclaration
│     │  ├──Identifier
│     │  │  └──Identifier
│     │  │     └──num
│     │  └──Value
│     │     └──FunctionCall
│     │        ├──Identifier
│     │        │  └──Identifier
│     │        │     └──input
│     │        └──Arguments
│     │           └──None
│     └──IfStatement
│        ├──Condition
│        │  └──BinaryOperation
│        │     ├──Left
│        │     │  └──FunctionCall
│        │     │     ├──Identifier
│        │     │     │  └──Identifier
│        │     │     │     └──fib_rec
│        │     │     └──Arguments
│        │     │        └──Identifier
│        │     │           └──num
│        │     ├──Operator
│        │     │  └──==
│        │     └──Right
│        │        └──FunctionCall
│        │           ├──Identifier
│        │           │  └──Identifier
│        │           │     └──fib_while
│        │           └──Arguments
│        │              └──Identifier
│        │                 └──num
│        ├──Body
│        │  └──FunctionCall
│        │     ├──Identifier
│        │     │  └──Identifier
│        │     │     └──print
│        │     └──Arguments
│        │        └──IntLiteral
│        │           └──0
│        └──ElseBody
│           └──FunctionCall
│              ├──Identifier
│              │  └──Identifier
│              │     └──print
│              └──Arguments
│                 └──UnaryOperation
│                    ├──Operator
│                    │  └──-
│                    └──Expression
│                       └──IntLiteral
│                          └──1
└──FunctionCall
   ├──Identifier
   │  └──Identifier
   │     └──main
   └──Arguments
      └──None
```
