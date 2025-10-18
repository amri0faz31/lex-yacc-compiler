# FormLang++

A tiny DSL that compiles declarative form specs into HTML + client-side validation.

- Lexer: `lexer.l` (Flex/Lex)
- Parser: `parser.y` (Bison/Yacc)
- Sample input: `example.form`
- Output: `output.html`

## Prerequisites (macOS)
- Xcode Command Line Tools (for gcc)
- Lex/Flex and Yacc/Bison
  - Optionally via Homebrew:
    - `brew install flex bison`

## Quickstart (Yacc/Lex names)
```sh
# 1) Generate parser and headers
yacc -d parser.y

# 2) Generate lexer
lex lexer.l

# 3) Build
gcc -o formlang y.tab.c lex.yy.c -ll

# 4) Run the compiler on the sample DSL
./formlang < example.form

# 5) Open the generated HTML
open output.html
```

## Alternative (Bison/Flex names)
If you prefer modern tool names or Homebrew installs:
```sh
bison -d -o parser.tab.c parser.y
flex lexer.l
# On some systems use -lfl instead of -ll
gcc -o formlang parser.tab.c lex.yy.c -lfl
./formlang < example.form
open output.html
```

Notes:
- The lexer uses `%option noyywrap`, so no custom `yywrap` is needed.
- Depending on your toolchain, linking may require `-ll` (lex) or `-lfl` (flex). If one fails, try the other.
- You may see debug prints for email tokens/fields; they are harmless.

## Clean
```sh
rm -f formlang lex.yy.c y.tab.c y.tab.h parser.tab.c parser.tab.h output.html
```

## What it does
Parses `.form` specifications (meta, sections, and typed fields) and emits a `<form>` with inputs and an inline `validateForm()` JavaScript function synthesized from `validate { if ... error "..." }` rules.
