%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "lexico.c"
#include "utils.c"
int contaVar;
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_INTEIRO
%token T_LOGICO
%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_ATRIBUI
%token T_ABRE
%token T_FECHA
%token T_V
%token T_F
%token T_IDENTIF
%token T_NUMERO

%start programa

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa
    : cabecalho 
        { contaVar = 0; }
      variaveis
        { fprintf(yyout, "\tAMEM\t%d\n", contaVar); } 
      T_INICIO lista_comandos T_FIM
        { fprintf(yyout, "\tDMEM\tx\n\tFIMP\n"); };
    ; 

cabecalho
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout, "\tINPP\n"); }
    ;

variaveis
    : /* vazio */
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    |tipo lista_variaveis
    ;

tipo
    : T_LOGICO
    |T_INTEIRO
    ;

lista_variaveis
    : lista_variaveis T_IDENTIF
        {
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            insereSimbolo(elemTab);
            contaVar++;
        }
      lista_variaveis
    | T_IDENTIF
        { 
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            insereSimbolo(elemTab);
            contaVar++;
        }
    ;

lista_comandos
    : /* vazio */
    | comando lista_comandos
    ;

comando
    : entrada_saida
    | repeticao
    | selecao
    | atribuicao
    ;

entrada_saida
    : leitura
    | escrita
    ;

leitura
    : T_LEIA T_IDENTIF
        { 
            int pos = buscaSimbolo(atomo);
            fprintf(yyout, "\tLEIA\n\tARZG\t%d\n", tabSimb[pos].end); 
        }
    ;

escrita
    : T_ESCREVA expressao
        { fprintf(yyout, "\tESCR\n"); }
    ;

repeticao
    : T_ENQTO 
        { fprintf(yyout, "Lx\tNADA\n"); }
      expressao T_FACA 
        { fprintf(yyout, "\tDSVF\tLy\n"); }
      lista_comandos 
      T_FIMENQTO
        { fprintf(yyout, "\tDSVS\tLx\nLy\tNADA\n"); }
    ;

selecao
    : T_SE expressao T_ENTAO 
        { fprintf(yyout, "\tDSVF\tLx\n"); }
      lista_comandos T_SENAO 
        { fprintf(yyout, "\tDSVS\tLy\nLx\tNADA\n"); }
      lista_comandos T_FIMSE
        { fprintf(yyout, "Ly\tNADA\n"); }
    ;

atribuicao
    : T_IDENTIF T_ATRIBUI expressao
        { fprintf(yyout, "\tARZG\tx\n"); }
    ;

expressao
    : expressao T_VEZES expressao
        { fprintf(yyout, "\tMULT\n"); }
    | expressao T_DIV expressao
        { fprintf(yyout, "\tDIVI\n"); }
    | expressao T_MAIS expressao
        { fprintf(yyout, "\tSOMA\n"); }
    | expressao T_MENOS expressao
        { fprintf(yyout, "\tSUBT\n"); }
    | expressao T_MAIOR expressao
        { fprintf(yyout, "\tCMMA\n"); }
    | expressao T_MENOR expressao
        { fprintf(yyout, "\tCMME\n"); }
    | expressao T_IGUAL expressao
        { fprintf(yyout, "\tCMMIG\n"); }
    | expressao T_E expressao
        { fprintf(yyout, "\tCONJ\n"); }
    | expressao T_OU expressao
        { fprintf(yyout, "\tDISJ\n"); }
    | termo;
    ;

termo
    : T_IDENTIF
        { 
            int pos = buscaSimbolo(atomo);
            fprintf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end); 
        }
    | T_NUMERO
        { fprintf(yyout, "\tCRCT\t%s\n", atomo); }
    | T_V
        { fprintf(yyout, "\tCRCT\t1\n"); }
    | T_F
        { fprintf(yyout, "\tCRCT\t0\n"); }
    | T_NAO termo
        { fprintf(yyout, "\tNEGA\n"); }
    | T_ABRE expressao T_FECHA
    ;

%%

int main(int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if(argc < 2) {
        puts("\nCompilador Simples");
        puts("\n\tUso: ./simples <NOME>[.simples]\n\n");
        exit(10);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen (nameIn, "rt");
    if (!yyin) {
        puts("Programa fonte não encontrado!");
        exit(20);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    puts("Programa ok!");
}