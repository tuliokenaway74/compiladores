identificador [a-zA-Z]([a-zA-Z0-9])*
numero [0-9]+
espaco[ \t]+
novalinha [\n]

%x coment

%{
int nlin = 1;
%}    

%%

programa        printf("%3d>  %11s: reservada\n", nlin, yytext);
inicio          printf("%3d>  %11s: reservada\n", nlin, yytext);
fimprograma     printf("%3d>  %11s: reservada\n", nlin, yytext);

leia            printf("%3d>  %11s: reservada\n", nlin, yytext);
escreva         printf("%3d>  %11s: reservada\n", nlin, yytext);

se              printf("%3d>  %11s: reservada\n", nlin, yytext);
entao           printf("%3d>  %11s: reservada\n", nlin, yytext);
senao           printf("%3d>  %11s: reservada\n", nlin, yytext);
fimse           printf("%3d>  %11s: reservada\n", nlin, yytext);

enquanto        printf("%3d>  %11s: reservada\n", nlin, yytext);
faca            printf("%3d>  %11s: reservada\n", nlin, yytext);
fimenquanto     printf("%3d>  %11s: reservada\n", nlin, yytext);

inteiro         printf("%3d>  %11s: reservada (tipo)\n", nlin, yytext);
logico          printf("%3d>  %11s: reservada (tipo)\n", nlin, yytext);


"+"             printf("%3d>  %11s: operador_soma\n", nlin, yytext);
"-"             printf("%3d>  %11s: operador_subtracao\n", nlin, yytext);
"*"             printf("%3d>  %11s: operador_multiplicacao\n", nlin, yytext);
"div"           printf("%3d>  %11s: operador_divisao\n", nlin, yytext);

">"             printf("%3d>  %11s: operador_maior\n", nlin, yytext);
"<"             printf("%3d>  %11s: operador_menor\n", nlin, yytext);
"="             printf("%3d>  %11s: operador_igual\n", nlin, yytext);

e               printf("%3d>  %11s: operador_conjuncao\n", nlin, yytext);
ou              printf("%3d>  %11s: operador_disjuncao\n", nlin, yytext);
nao             printf("%3d>  %11s: operador_negacao\n", nlin, yytext);

"<-"            printf("%3d>  %11s: operador_atribuicao\n", nlin, yytext);
"("             printf("%3d>  %11s: operador_abre_parenteses\n", nlin, yytext);
")"             printf("%3d>  %11s: operador_fecha_parenteses\n", nlin, yytext);

V               printf("%3d>  %11s: constante_verdade\n", nlin, yytext);
F               printf("%3d>  %11s: constante_falsidade\n", nlin, yytext);

"//".*          ;
"/*"            BEGIN(coment);
<coment>"*/"    BEGIN(INITIAL);
<coment>.       ;
<coment>\n      nlin++;


{identificador} printf("%3d>  %11s: identificador\n", nlin, yytext);
{numero}        printf("%3d>  %11s: numero\n", nlin, yytext);
{espaco}        /* nao faz nada */;
{novalinha}     nlin++;


%%

int yywrap(void) {return 1; }

int main (void) {
    yylex();
    return 0;
}