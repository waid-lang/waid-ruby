[![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/emersion/stability-badges#experimental)


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

I'm working on a tree walking interpreter at the moment, but I'm planning to write a VM in Go in the future.
</br>
</br>
<div style="text-align:center"><img height="600x" src="https://raw.githubusercontent.com/TaconeoMental/WaidLang/main/assets/code_example.png" /></div>

## Usage
```bash
$ ./waid.rb
Usage: main [options] filename
    -t, --show-tokens                Print the tokens produced by the scanner
    -a, --show-ast                   Print the AST produced by the parser
```
