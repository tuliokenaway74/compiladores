%{
#include "lexico.c"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "utils.c"

int contaVar;
int rotulo = 0;
int tipo;


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
%token T_FACA
%token T_ENQTO
%token T_FIMENQTO
%token T_INTEIRO
%token T_LOGICO
%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV
%token T_ATRIBUI
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_V 
%token T_F 
%token T_IDENTIF
%token T_NUMERO
// adicionar os tokens para as palavras chave retorne, func, fimfunc
%token T_RETORNE
%token T_FUNC
%token T_FIMFUNC

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
        { 
            mostraTabela();
            empilha(contaVar);
            if (contaVar) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVar); 
            
        }
    // acrescentar as funcoes
    funcoes
       T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha();
            if (conta)
                fprintf(yyout,"\tDMEM\t%d\n", conta); 
            fprintf(yyout,"\tFIMP\n");
        }
    ;
// acrescentar a palavra chave retorne
cabecalho
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout,"\tINPP\n"); }
    ;

variaveis
    :
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo 
    : T_LOGICO
        { tipo = LOG; }
    | T_INTEIRO
        { tipo = INT; }
    ;// acrescentar a palavra chave retorne

lista_variaveis
    : lista_variaveis T_IDENTIF 
        { 
          strcpy(elemTab.id, atoma);
          elemTab.end = contaVar;
          elemTab.tip = tipo;
          // elemTab.esc = escopo;
          insereSimbolo(elemTab);
          contaVar++; 
        }
    | T_IDENTIF
        { 
          strcpy(elemTab.id, atoma);
          elemTab.end = contaVar;
          elemTab.tip = tipo;
          // elemTab.esc = escopo;
          insereSimbolo(elemTab);elem
          contaVar++;
        }
    ;
//regras para funcoes
funcoes
    : /* vazio */
    | funcao funcoes
    ;

funcao
    : T_FUNC tipo T_IDENTIF T_ABRE parametros T_FECHA
    | variaveis T_INICIO lista_comandos T_FIMFUNC
    ;

parametros
    : /* vazio */
    | parametro parametros
    ;

parametro
    : tipo T_IDENTIF
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
    | retorno
    ;

retorno
    : T_RETORNE expressao
       // deve gerar (depois da trad. da expressão)
       // ARZL (valor do retorno), DMEM (se tiver variavel local)
       // RTSP n
    ;

entrada_saida
    : leitura
    | escrita
    ;


leitura 
    : T_LEIA T_IDENTIF
        
        { 
            int pos = buscaSimbolo(atoma);
            fprintf(yyout,"\tLEIA\n\tARZG\t%d\n", tabSimb[pos].end); 
        }
    ;

escrita 
    : T_ESCREVA expressao 
        {
            desempilha(); 
            fprintf(yyout,"\tESCR\n"); 
        }
    ;

repeticao 
    : T_ENQTO
        { 
            fprintf(yyout,"L%d\tNADA\n", ++rotulo); 
            empilha(rotulo);
        } 
    expressao T_FACA  
        {   
            int tip = desempilha();
            if (tip != LOG)
                yyerror("Incompatibilidade de tipo");
            fprintf(yyout,"\tDSVF\tL%d\n", ++rotulo); 
            empilha(rotulo);
        }
    lista_comandos
    T_FIMENQTO
        {
            int rot1 = desempilha();
            int rot2 = desempilha();
            fprintf(yyout,"\tDSVS\tL%d\nL%d\tNADA\n", rot2, rot1); 

        }
    ;

selecao 
    : T_SE expressao T_ENTAO 
        { 
            int tip = desempilha();
            if (tip != LOG)
                yyerror("Incompatibilidade de tipo");
            fprintf(yyout,"\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo); 
        }
    lista_comandos T_SENAO 
        {
            int rot = desempilha(); 
            fprintf(yyout,"\tDSVS\tL%d\nL%d\tNADA\n", ++rotulo, rot); 
            empilha(rotulo);
        }
    lista_comandos T_FIMSE
        {
            int rot = desempilha(); 
            fprintf(yyout,"L%d\tNADA\n", rot); 
        }
    ;

atribuicao
    : T_IDENTIF
        {
            int pos = buscaSimbolo(atoma);
            empilha(pos);
        } 
      T_ATRIBUI expressao 
        { 
            int tip = desempilha();
            int pos = desempilha();
            if (tabSimb[pos].tip != tip)
                yyerror("Incompatibilidade de tipo!");
            fprintf(yyout,"\tARZG\t%d\n", tabSimb[pos].end); 
        }

expressao 
    : expressao T_VEZES expressao 
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tMULT\n"); 
        
        }
    | expressao T_DIV expressao 
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tDIVI\n"); 
        }
    | expressao T_MAIS expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tSOMA\n"); 
        } 
    | expressao T_MENOS expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout,"\tSUBT\n"); 
        } 
    | expressao T_MAIOR expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMMA\n"); 
        } 
    | expressao T_MENOR expressao 
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMME\n"); 
        }
    | expressao T_IGUAL expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout,"\tCMIG\n"); 
        } 
    | expressao T_E expressao 
        { 
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout,"\tCONJ\n"); 
        }
    | expressao T_OU expressao
        { 
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout,"\tDISJ\n"); 
        } 
    | termo 
    ;

identificador
    : T_IDENTIF
    ;

// A funcao eh chamada como um termo numa expressao
chamada
    : // sem parenteses eh uma variavel
    | T_ABRE lista_argumentos T_FECHA
    ;

lista_argumentos
    : /* vazio */
    | expressao lista_argumentos
    ;

termo 
    : identificador chamada
 /*   : T_IDENTIF
        { 
            int pos = buscaSimbolo(atoma);
            fprintf(yyout,"\tCRVG\t%d\n", tabSimb[pos].end);
            empilha(tabSimb[pos].tip);
        } */
    | T_NUMERO
        {   fprintf(yyout,"\tCRCT\t%s\n", atoma); 
            empilha(INT);
        }
    | T_V 
        {   fprintf(yyout,"\tCRCT\t1\n"); 
            empilha(LOG);
        }
    | T_F 
        {   fprintf(yyout,"\tCRCT\t0\n"); 
            empilha(LOG);
        }
    | T_NAO termo
        { 
            int t = desempilha();
            if (t != LOG) yyerror ("Incompatibilidade de tipo!");
            fprintf(yyout,"\tNEGA\n"); 
            empilha(LOG);
        }
    | T_ABRE expressao T_FECHA
    ;

%%


int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) {
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