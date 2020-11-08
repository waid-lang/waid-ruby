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
    num => 10
    count => 0
    while count < num =>
        !(print !(fib_while count))
        count => count + 1
    endwl
    
    count => 0
    while count < num =>
        !(print !(fib_rec count))
        count => count + 1
    endwl
endfn

!main
```

```
$ ./main.rb main.wd
0
1
1
2
3
5
8
13
21
34
0
1
1
2
3
5
8
13
21
34
```

## TODO
- Arrays
- Hashes
