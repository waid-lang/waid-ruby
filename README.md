# WaidLang
I am too lazy to write a nice presentation so in the meantime here is a small sample of the language and its context free grammar.

It is currently implemented with a custom lexer and a LL(1) parser (recursive descent), although I would like to write a LL(1) parsing table in the future.
```py
add: func(x, y) =>
    <- x + y
endfn

# Pseudo range function
range: func(start, end, step=>1) =>
    arr => [..end] # Array of length "end"
    while i => start, i < end, i +> 1 =>
        arr[i] => i * step
    endwl
    <- arr
endfn

main: func =>
    for elem in !(range 0 !(add !input 1) 2) =>
        !print !(add elem !input)
    endfr
endfn
```

```ebnf
LETRA            = "A" ... "Z"
                 | "a" ... "z"
                 | "_"
DIGITO_DECIMAL   = "0" ... "9";

IDENTIFICADOR    = LETRA, {LETRA | DIGITO_DECIMAL};
LISTA_IDS        = IDENTIFICADOR, {",", IDENTIFICADOR};

LITERAL_ENTERO   = (DIGITO_DECIMAL - "0"), {DIGITO_DECIMAL};
LITERAL_FLOAT    = DECIMALES, ".", DECIMALES;
DECIMALES        = DIGITO_DECIMAL, {DIGITO_DECIMAL};
LITERAL          = LITERAL_ENTERO
                 | LITERAL_FLOAT;
                
OPERANDO         = LITERAL
                 | IDENTIFICADOR
                 | "(", EXPR, ")";
                
LISTA_STMTS      = {ESTAMENTO};
LISTA_EXPR       = EXPR, {",", EXPR};

EXPR             = EXPR_BOOLEANA;

EXPR_ARITMETICA  = MULT, {OP_SUMA, MULT};
OP_SUMA          = "+"
                 | "-";
MULT             = NEG, {OP_MULT, NEG};
OP_MULT          = "*"
                 | "/"
                 | "%";
NEG              = "-", NEG
                 | EXPR_ARIT_SEC;
EXPR_ARIT_SEC    = "(", EXPR_ARITMETICA, ")"
                 | EXPR_PRIMARIA;

EXPR_BOOLEANA    = RELATIONAL, {OP_EQUALITY, RELATIONAL};
OP_EQUALITY      = "="
                 | "/=";
RELATIONAL       = EXPR_BOOL_SEC, {OP_RELATIONAL, EXPR_BOOL_SEC};
OP_RELATIONAL    = ">"
                 | "<"
                 | ">="
                 | "<=";
EXPR_BOOL_SEC    = "(", EXPR_BOOLEANA, ")"
                 | EXPR_ARITMETICA

EXPR_PRIMARIA    = OPERANDO
                 | FUNC_CALL;
                 
FUNC_CALL        = "!", "(", IDENTIFICADOR, [LISTA_EXPR], ")";
                 | "!", IDENTIFICADOR;

TIPO_FUNC        = "func", PARAMETROS;
PARAMETROS       = "(", [LISTA_PARAMS], ")";
LISTA_PARAMS     = PARAM_DECL, {",", PARAM_DECL};
PARAM_DECL       = IDENTIFICADOR, [VALOR_DEFECTO];
VALOR_DEFECTO    = "=>", OPERANDO;

DECL_FUNC        = DECL_TIPO, TIPO_FUNC, CUERPO_FUNC;
CUERPO_FUNC      = "=>", LISTA_STMTS, "endfn";
DECL_TIPO        = IDENTIFICADOR, ":";

DECL_VARIABLE    = IDENTIFICADOR, "=>", EXPR;

IF_STMT          = "if", EXPR, "=>", LISTA_STMTS, [ELIF_BLOCK], "endif";
ELIF_BLOCK       = "else", "=>", LISTA_STMTS;

WHILE_STMT       = "while", EXPR, WHILE_BODY, "=>", LISTA_STMTS, "endwl";

RETURN_STMTS     = "<-", EXPR;
ESTAMENTO        = DECL_VARIABLE
                 | DECL_FUNC
                 | RETURN_STMT
                 | IF_STMT
                 | WHILE_STMT
                 | EXPR;
PROGRAMA         = {LISTA_STMTS};
```

