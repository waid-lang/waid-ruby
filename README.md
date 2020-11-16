<div>
    </br>
    <img src="https://raw.githubusercontent.com/TaconeoMental/WaidLang/main/assets/WaidLogo.png"
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
### Control Flow
#### If Statement
If statements in Waid work just like in any other language. The elseif/elif syntax isn't implemented yet, but it will be in the future.
```ruby
falsey => null
truthy => 5

if true and truthy:
    !(printLine ":D")
else:
    !(printLine ":(")
endif

if false or not falsey:
	!(printLine ":D x2")
endif
```

#### While Loop
While loops work normally aswell. For loops haven't been implemented yet.
```ruby
x => 0
while x < 10:
    !(printLine x)
    x => x + 1
endwl
```
### Builtin Functions
Waid has 6 builtin functions at the moment:
#### printLine
Prints its arguments string representation to Stdout and appends a line break to it.
```ruby
!(printLine "str") # str
!(printLine 6) # 6
!(printLine printLine) # Builtin function
```
#### print
Prints its argument without appending a new line.
```ruby
!(print "Hello ")
!(print "world")
# Hello world
```
#### length
Returns the length of a string or array. If the arguments is neither of those, it returns null.
```ruby
!(length "hola :)") # 7
!(length [1, "dos", 7 - 4, ["cua", "tro"]]) # 4
!(length 7) # null
```
#### input
Input doesn't take any arguments and returns a string read from Stdin.
```ruby
a => !input
!(printLine a)
```
#### toNum
toNum converts its argument into its numeric representation, if it doesn't exist, it returns null. Because of this it can also be used to check if a string is in fact a number or not.
```ruby
num => !(toNum !input)
if num: # Is not null
    num => num + 1
else:
    !(printLine "No ingresaste un número :(")
endif
```
#### toStr
toStr converts its argument into its string representation.
```ruby
n => 7
frase => "Este es el número " . !(toStr n) . "!!" # String concatenation
```
