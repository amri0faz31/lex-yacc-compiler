%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

extern int yylineno;
void yyerror(const char *msg);
int yylex();

FILE *output_file;
char *current_form = NULL;

char* capitalize(const char *str) {
    if (!str || !*str) return strdup("");
    char *result = strdup(str);
    result[0] = toupper(result[0]);
    return result;
}
%}

%union {
    char *str;
}

%token FORM SECTION FIELD META VALIDATE IF ERROR
%token REQUIRED DEFAULT PATTERN MIN MAX ROWS COLS ACCEPT OPTIONS
%token TEXT TEXTAREA NUMBER_TYPE EMAIL_TYPE  DATE CHECKBOX DROPDOWN RADIO PASSWORD FILE_TYPE

%token BOOLEAN LT GT LTE GTE EQ NEQ
%token  LBRACE RBRACE LBRACKET RBRACKET 
%token EQUAL SEMICOLON COLON COMMA
%token IDENTIFIER STRING NUMBER

%type <str> IDENTIFIER STRING NUMBER BOOLEAN
%type <str> field_type attribute attributes attribute_list option_list
%type <str> meta_decl validation condition expression operator

%%

program: form { printf(" \n\n\n  V  A  L  I  D     F  O  R  M \n\n\n"); };

form: FORM IDENTIFIER LBRACE { 
        current_form = $2;
        fprintf(output_file, "<form name=\"%s\">\n", current_form);
    } 
    meta_decl 
    sections 
    validation 
    RBRACE {
        fprintf(output_file, "</form>\n");
        free(current_form);
    }
;

meta_decl: /* empty */ { $$ = NULL; }
         | META IDENTIFIER EQUAL STRING SEMICOLON {
             free($2);
             free($4);
             $$ = NULL;
         }
;

sections: /* empty */
        | sections section
;

section: SECTION IDENTIFIER LBRACE { free($2); } 
        fields 
        RBRACE
;

fields: /* empty */
      | fields field
;

field: FIELD IDENTIFIER COLON field_type attributes SEMICOLON {
    printf("Processing field: %s, type: %s, attrs: '%s'\n", $2, $4, $5);
    char *label = capitalize($2);
    
    if (strcmp($4, "radio") == 0) {
        fprintf(output_file, "  <label>%s:</label><br>\n", label);
        char *opts = strdup($5);
        char *token = strtok(opts, ",");
        while (token) {
            fprintf(output_file, "  <input type=\"radio\" name=\"%s\" value=\"%s\"> %s<br>\n", 
                    $2, token, token);
            token = strtok(NULL, ",");
        }
        free(opts);
    } 
    else if (strcmp($4, "checkbox") == 0) {
        fprintf(output_file, "  <label><input type=\"checkbox\" name=\"%s\" %s>%s</label><br>\n",
            $2, $5, label);
    }
    else if (strcmp($4, "textarea") == 0) {
        fprintf(output_file, "  <label>%s: <textarea name=\"%s\" %s></textarea></label><br>\n",
            label, $2, $5);
    }
    else if (strcmp($4, "textarea") == 0) {
    fprintf(output_file, "  <label>%s: <textarea name=\"%s\"", label, $2);
    if (strlen($5) > 0) {
        fprintf(output_file, " %s", $5);
    }
    fprintf(output_file, "></textarea></label>\n");
    }
    else if (strcmp($4, "dropdown") == 0) {
    fprintf(output_file, "  <label>%s: <select name=\"%s\">\n", label, $2);
    char *opts = strdup($5);
    char *token = strtok(opts, ",");
    while (token) {
        fprintf(output_file, "    <option value=\"%s\">%s</option>\n", token + 1, token + 1); // Remove quotes
        token = strtok(NULL, ",");
    }
    fprintf(output_file, "  </select></label><br>\n");
    free(opts);
}
   else if (strcmp($4, "password") == 0) {
    printf("Processing password field: %s\n", $2);
    fprintf(output_file, "  <label>%s: <input type=\"password\" name=\"%s\"%s></label><br>\n",
        label, $2, $5);
}
    else {
        fprintf(output_file, "  <label>%s: <input type=\"%s\" name=\"%s\" %s></label><br>\n",
            label, $4, $2, $5);
    }
    printf("Parsed field: name=%s, type=%s, attrs=%s\n", $2, $4, $5);
    free($2);
    free($4);
    free($5);
    free(label);
}
;

field_type: TEXT { $$ = strdup("text"); printf("Field type: TEXT\n"); }
          | TEXTAREA { $$ = strdup("textarea"); printf("Field type: TEXTAREA\n"); }
          | NUMBER_TYPE { $$ = strdup("number"); printf("Field type: NUMBER_TYPE\n"); }
          | EMAIL_TYPE { $$ = strdup("email"); printf("Field type: EMAIL_TYPE\n"); }
          | DATE { $$ = strdup("date"); printf("Field type: DATE\n"); }
          | CHECKBOX { $$ = strdup("checkbox"); printf("Field type: CHECKBOX\n"); }
          | DROPDOWN { $$ = strdup("dropdown"); printf("Field type: DROPDOWN\n"); }
          | RADIO { $$ = strdup("radio"); printf("Field type: RADIO\n"); }
          | PASSWORD { $$ = strdup("password"); printf("Field type: PASSWORD\n"); }
          | FILE_TYPE { $$ = strdup("file"); printf("Field type: FILE_TYPE\n"); }
          | IDENTIFIER { $$ = strdup($1); printf("Field type: IDENTIFIER (%s)\n", $1); }
;

attributes: /* empty */ { $$ = strdup(""); printf("Attributes: empty\n"); }
          | attribute_list { $$ = $1; printf("Attributes: %s\n", $1); }
;

attribute_list: attribute { $$ = $1; printf("Attribute list: %s\n", $1); }
              | attribute_list attribute {
                  char *new = malloc(strlen($1) + strlen($2) + 2);
                  sprintf(new, "%s %s", $1, $2);
                  free($1);
                  free($2);
                  $$ = new;
                  printf("Attribute list combined: %s\n", $$);
              }
;

attribute: REQUIRED { $$ = strdup("required"); printf("Attribute: REQUIRED\n"); }
            
        | ROWS EQUAL NUMBER {
             $$ = malloc(strlen($3) + 7);
             sprintf($$, "rows=%s", $3);
             free($3);
             printf("Attribute: ROWS (%s)\n", $$);
         }
         | COLS EQUAL NUMBER {
             $$ = malloc(strlen($3) + 7);
             sprintf($$, "cols=%s", $3);
             free($3);
             printf("Attribute: COLS (%s)\n", $$);
         }


         | DEFAULT EQUAL STRING { 
             $$ = malloc(strlen($3) + 8);
             sprintf($$, "value=%s", $3+1);
             $$[strlen($$)-1] = '\0';
             free($3);
             printf("Attribute: DEFAULT STRING (%s)\n", $$);
         }
         | DEFAULT EQUAL BOOLEAN {
             $$ = strdup(strcmp($3, "true") == 0 ? "checked" : "");
             free($3);
             printf("Attribute: DEFAULT BOOLEAN (%s)\n", $$);
         }
         | PATTERN EQUAL STRING {
             $$ = malloc(strlen($3) + 9);
             sprintf($$, "pattern=%s", $3+1);
             $$[strlen($$)-1] = '\0';
             free($3);
             printf("Attribute: PATTERN (%s)\n", $$);
         }
         | MIN EQUAL NUMBER {
             $$ = malloc(strlen($3) + 5);
             sprintf($$, "min=%s", $3);
             free($3);
             printf("Attribute: MIN (%s)\n", $$);
         }
         | MAX EQUAL NUMBER {
             $$ = malloc(strlen($3) + 5);
             sprintf($$, "max=%s", $3);
             free($3);
             printf("Attribute: MAX (%s)\n", $$);
         }
         | LBRACKET option_list RBRACKET {
             $$ = $2;
             printf("Attribute: OPTIONS (%s)\n", $$);
         }
;

option_list: STRING { $$ = $1; }
           | option_list COMMA STRING {
               char *new = malloc(strlen($1) + strlen($3) + 2);
               sprintf(new, "%s,%s", $1, $3);
               free($1);
               free($3);
               $$ = new;
           }
;

validation: /* empty */ { $$ = NULL; }
          | VALIDATE LBRACE conditions RBRACE { $$ = NULL; }
;

conditions: /* empty */
          | conditions condition
;

condition: IF expression LBRACE ERROR STRING SEMICOLON RBRACE {
    fprintf(output_file, "  <script>if(document.forms['%s'].%s) { alert(%s); }</script>\n",
            current_form, $2, $5);
    free($2); /* Free expression string */
    free($5); /* Free error message string */
}
;

expression: IDENTIFIER operator IDENTIFIER {
    char *temp = malloc(strlen($1) + strlen($2) + strlen($3) + 4);
    sprintf(temp, "%s %s %s", $1, $2, $3);
    $$ = temp;
    free($1);
    free($2);
    free($3);
}
          | IDENTIFIER operator NUMBER {
    char *temp = malloc(strlen($1) + strlen($2) + strlen($3) + 4);
    sprintf(temp, "%s %s %s", $1, $2, $3);
    $$ = temp;
    free($1);
    free($2);
    free($3);
}
;

operator: LT { $$ = strdup("<"); }
        | GT { $$ = strdup(">"); }
        | LTE { $$ = strdup("<="); }
        | GTE { $$ = strdup(">="); }
        | EQ { $$ = strdup("=="); }
        | NEQ { $$ = strdup("!="); }  
;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, msg);
}

int main() {
    
    output_file = fopen("output.html", "w");
    if (!output_file) {
        fprintf(stderr, "Cannot open output.html\n");
        return 1;
    }
    
    // Adding CSS header for styling
    fprintf(output_file, 
       "<!DOCTYPE html>\n"
        "<html lang=\"en\">\n"
        "<head>\n"
        "<meta charset=\"UTF-8\">\n"
        "<title>Registration Form</title>\n"
        "<link rel=\"stylesheet\" href=\"styles.css\">\n"
        "</head>\n"
        "<body>\n"
    );
    
    yyparse();
    fprintf(output_file, "</body>\n</html>\n");
    fclose(output_file);
    return 0;
}