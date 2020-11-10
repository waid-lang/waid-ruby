<div>
    </br>
    <img src="assets/WaidLogo.png"
    height="150px"
    alt="Waid Programming language"
    title="Waid Programming Language"
    style="border-radius:30px;margin-right:10px"
    align="left">
    <h1>The Waid Programming Language</h1>
    <h4>My personal attempt at writing a programming language from scratch</h4>
</div>
</br>
Waid is everything you never wanted. It's ugly, verbose and has a lot of arrows.
It's currently implemented with a custom lexer and a LL(1) parser (recursive descent), although I would like to write a LL(1) parsing table in the future.

I'm working on a tree walking interpreter at the moment, but I'm planning to write a VM in C or C++ eventually.

## Usage
```bash
$ ./waid.rb
Usage: main [options] filename
    -t, --show-tokens                Print the tokens produced by the scanner
    -a, --show-ast                   Print the AST produced by the parser
    -e, --show-final-env             Print the final state of the global enviroment
```

## Language
Please take this as a vague reference of the language. I probably won't write real documentation until imports are a thing. You're probably better off looking at the code examples.
### Variables
variables are declared using the ***=>*** operator.
```ruby
var_1 => 10
var_2 => 5.7
var_1 => "Variables can change and store values of any type!"
```

### Functions
To declare a function you need to use the *func* keyword. The body of the function starts at the ***=>*** operator and ends at the *endfn* keyword.
Values are returned with the ***<-*** operator.
```ruby
add: func(num1, num2) =>
    <- num1 + num2
endfn

no_args: func() =>
    <- "Znqrlbhybfrgvzrunun"
endfn
```

To call a function, the ***!*** operator is used.
```ruby
# Functions with arguments use parenthesis. Arguments are separated by spaces.
!(add 24 45)

# If the function doesn't take any arguments, parenthesis can be ommited.
secret_string => !no_args
```
#### First Class Objects
In Waid, functions are first class objects. This means that they can be passed as arguments to and returned by other functions.
##### Returning a function
```ruby
make_adder: func(num) =>
    adder: func(x) =>
        <- x + num
    endfn
    <- adder
endfn

add_2 => !(make_adder 2)
!(print !(add_2 4)) # 6
```
##### Passing a function as an argument
```ruby
call: func(function, arg1, arg2) =>
    <- !(function arg1 arg2)
endfn

add: func(x, y) =>
    <- x + y
endfn

sum => !(call add 382 284)
!(print sum)
```
### Conditionals
### Builtin Functions

## TODO
- Arrays
- Hashes
