%{
#include "sintatico.h"
char atoma[100];
int cont = 1;
int yyerror (char *s);
%}

identificador [a-zA-Z]([a-zA-Z0-9])*
numero [0-9]+
espaco [ \t]+
novalinha [\n]

%x coment

/* acrescentar a palavra chave retorne */

%%
programa        return T_PROGRAMA;
inicio          return T_INICIO;
fimprograma     return T_FIM;
leia            return T_LEIA;
escreva         return T_ESCREVA;
se              return T_SE;
entao           return T_ENTAO;
senao           return T_SENAO;
fimse           return T_FIMSE;
enquanto        return T_ENQTO;
faca            return T_FACA;
fimenquanto     return T_FIMENQTO;
inteiro         return T_INTEIRO;
logico          return T_LOGICO;
retorne         return T_RETORNE;
func            return T_FUNC;
fimfunc         return T_FIMFUNC

"+"             return T_MAIS;
"-"             return T_MENOS;
"*"             return T_VEZES;
div             return T_DIV;
">"             return T_MAIOR;
"<"             return T_MENOR;
"="             return T_IGUAL;
e               return T_E;
ou              return T_OU;
nao             return T_NAO;
"<-"            return T_ATRIBUI;

"("             return T_ABRE;
")"             return T_FECHA;

"V"             return T_V;
"F"             return T_F;

"//".*          ;
"/*"            BEGIN(coment);
<coment>"*/"    BEGIN(INITIAL);
<coment>.       ;
<coment>\n      cont++;

{identificador} { strcpy(atoma, yytext); return T_IDENTIF;}
{numero}        { strcpy(atoma, yytext); return T_NUMERO;}
{espaco}        ;
{novalinha}     cont++;
.               yyerror("Erro lexico");
%%

int yyerror (char *s) {
    printf ("ERRO na linha %d: %s\n", cont, s);
    exit(10);
}
int yywrap() {
    return 1;
}

