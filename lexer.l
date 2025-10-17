%{
#include "y.tab.h"
#include <string.h>
extern int yylineno;
extern YYSTYPE yylval;
%}

%%

"form"              { printf("TOKEN: FORM\n"); return FORM; }
"section"           { printf("TOKEN: SECTION\n"); return SECTION; }
"field"             { printf("TOKEN: FIELD\n"); return FIELD; }
"meta"              { printf("TOKEN: META\n"); return META; }
"validate"          { printf("TOKEN: VALIDATE\n"); return VALIDATE; }
"if"                { printf("TOKEN: IF\n"); return IF; }
"error"             { printf("TOKEN: ERROR\n"); return ERROR; }
"required"          { printf("TOKEN: REQUIRED\n"); return REQUIRED; }
"default"           { printf("TOKEN: DEFAULT\n"); return DEFAULT; }
"pattern"           { printf("TOKEN: PATTERN\n"); return PATTERN; }
"min"               { printf("TOKEN: MIN\n"); return MIN; }
"max"               { printf("TOKEN: MAX\n"); return MAX; }
"rows"              { printf("TOKEN: ROWS\n"); return ROWS; }
"cols"              { printf("TOKEN: COLS\n"); return COLS; }
"accept"            { printf("TOKEN: ACCEPT\n"); return ACCEPT; }
"options"           { printf("TOKEN: OPTIONS\n"); return OPTIONS; }
"true"              { printf("TOKEN: BOOLEAN (%s)\n", yytext); yylval.str = strdup("true"); return BOOLEAN; }
"false"             { printf("TOKEN: BOOLEAN (%s)\n", yytext); yylval.str = strdup("false"); return BOOLEAN; }
"text"              { printf("TOKEN: TEXT\n"); return TEXT; }
"textarea"          { printf("TOKEN: TEXTAREA\n"); return TEXTAREA; }
"number"            { printf("TOKEN: NUMBER_TYPE\n"); return NUMBER_TYPE; }

"date"              { printf("TOKEN: DATE\n"); return DATE; }
"checkbox"          { printf("TOKEN: CHECKBOX\n"); return CHECKBOX; }
"dropdown"          { printf("TOKEN: DROPDOWN\n"); return DROPDOWN; }
"radio"             { printf("TOKEN: RADIO\n"); return RADIO; }
"password"          { printf("TOKEN: PASSWORD\n"); return PASSWORD; }
"file"              { printf("TOKEN: FILE_TYPE\n"); return FILE_TYPE; }
"email"             { printf("TOKEN: EMAIL_TYPE\n"); return EMAIL_TYPE; }
[a-zA-Z][a-zA-Z0-9]* {
    printf("TOKEN: IDENTIFIER (%s)\n", yytext);
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}
\"[^\"]*\"          { printf("TOKEN: STRING (%s)\n", yytext); yylval.str = strdup(yytext); return STRING; }
[0-9]+              { printf("TOKEN: NUMBER (%s)\n", yytext); yylval.str = strdup(yytext); return NUMBER; }
"<"                 { printf("TOKEN: LT\n"); return LT; }
">"                 { printf("TOKEN: GT\n"); return GT; }
"<="                { printf("TOKEN: LTE\n"); return LTE; }
">="                { printf("TOKEN: GTE\n"); return GTE; }
"=="                { printf("TOKEN: EQ\n"); return EQ; }
"!="                { printf("TOKEN: NEQ\n"); return NEQ; }
"{"                 { printf("TOKEN: LBRACE\n"); return LBRACE; }
"}"                 { printf("TOKEN: RBRACE\n"); return RBRACE; }
"["                 { printf("TOKEN: LBRACKET\n"); return LBRACKET; }
"]"                 { printf("TOKEN: RBRACKET\n"); return RBRACKET; }
"="                 { printf("TOKEN: EQUAL\n"); return EQUAL; }
";"                 { printf("TOKEN: SEMICOLON\n"); return SEMICOLON; }
":"                 { printf("TOKEN: COLON\n"); return COLON; }
","                 { printf("TOKEN: COMMA\n"); return COMMA; }
[ \t\n]+        { /* Ignore whitespace but track line numbers */
                 char *p = yytext;
                 while (*p) {
                     if (*p == '\n') yylineno++;
                     p++;
                 }
                 }
.               { fprintf(stderr, "Invalid character '%c' at line %d\n", *yytext, yylineno); }

%%

int yywrap() {
    return 1;
}
