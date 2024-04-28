CS152 Project - Lexical Analyzer Generation Using flex
===============================================================
## Description

The purpose of this project is to build a complex lexical analyzer generator that can parse a piece of code from a high-level programming language and convert it into an intermediate representation (pseudo-assembly code used by an interpreter/compiler) for compiling.

This project contains 3 phases:
```
1. Simple Lexer
   - Takes a piece of code represented as a string and outputs a list of tokens using *Flex*.
   - Will recognize both code and comments.
2. Simple Parser
   - Takes the sequence of tokens and identifies the grammar of the programming language of the original code using *Bison*.
   - Will identify which tokens represent while loops, if statements, function headers, function body, variable declarations, and constant variables.
3. Complex code generator
   - Takes a high-level language grammar and translates it into an intermediate representation as a string.
```

## Tools preparation

Make sure you have the following tools installed and check the version:
1. flex -V       (>=2.5)
2. git --version (>=1.8)
3. make -v       (>=3.8)
4. gcc -v        (>=4.8)
5. g++ -v        (>=4.8 optional if you wish to use C++)

## Clone and Build

Use 'git' to clone the project template and build it by typing 'make'

```sh
    git clone Lexical_Analyzer_Generator
    cd Lexical_Analyzer_Generator && make
```

## Use the template

You can change any files and add additional C files, but please make sure all files are linked to the final executable file in Makefile. Please don't change the name of 'Makefile' and 'miniL.lex'. After typing make, An executable file 'miniL' is expected to be created as your lexer.
