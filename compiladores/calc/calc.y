%{
#include "lexico.c"
%}

%token NUM
%token MAIS
%token MENOS
%token ENTER

%start comando

%left MAIS MENOS

%%
comando : expr ENTER    { printf("resultado = %d\n", $1);};
    | ;

expr : NUM              { $$ = $1; }
    | expr MAIS expr    { $$ = $1 + $3; }
    | expr MENOS expr   { $$ = $1 - $3; }
    ;
%%

void yyerror (char *s) {
    printf("ERRO: %s\n\n", s);
    exit(10);
}

int main(void){
    if(!yyparse())
        puts("aceita!");
    else
        puts("rejeita!");
    return 0;
}