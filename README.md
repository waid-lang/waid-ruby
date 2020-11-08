# WaidLang
My personal attempt at writing a programming language from scratch.

Waid is everything you never wanted. It's ugly, verbose, and it doesn't even work yet.
It's currently implemented with a custom lexer and a LL(1) parser (recursive descent), although I would like to write a LL(1) parsing table in the future.

I'm working on a tree walking interpreter at the moment, but I'm planning to write a VM in C or C++ in the future.

## Usage
```bash
$ ./main.rb
Usage: main [options] filename
    -t, --show-tokens                Print the tokens produced by the scanner
    -a, --show-ast                   Print the AST produced by the parser
    -e, --show-final-env             Print the final state of the global enviroment
```


***main.wd***
```py
fib_rec: func(n) =>
    if n < 2 =>
        <- n
    endif
    <- !(fib_rec n - 1) + !(fib_rec n - 2)
endfn

fib_while: func(n) =>
    a => 0
    b => 1
    count => 0
    while count < n =>
        prev_a => a
        a => b
        b => prev_a + b
        count => count + 1
    endwl
    <- a
endfn

main: func() =>
    num => 20
    count => 0
    !(printLine "Iterative Fibonacci:")
    while count < num =>
        !(print !(fib_while count))
        !(print " ")
        count => count + 1
    endwl

    !printLine

    count => 0
    !(printLine "Recursive Fibonacci:")
    while count < num =>
        !(print !(fib_rec count))
        !(print " ")
        count => count + 1
    endwl
    !printLine
endfn

!main
```

### Output
```
$ ./main.rb main.wd
Iterative Fibonacci:
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 
Recursive Fibonacci:
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181
```

## TODO
- Arrays
- Hashes
