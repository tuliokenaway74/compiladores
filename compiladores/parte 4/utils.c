#include <ctype.h>
#define TAM_TAB 100
#define MAX_PAR 20
enum 
{
    INT, 
    LOG
};


struct elemTabSimbolos {
    char id[100];             // identificador
    int end;                  // endereco (globa) ou deslocamento (local)
    int tip;                  // tipo
    char cat;                 // categoria: 'f' = FUN, 'p' = PAR, 'v' = VAR
    char esc;                 // escopo: 'g' = GLOBAL, 'l' = LOCAL
    int rot;                  // rotulo (especifico para funcao)
    int npa;                  // numero de parametros (para funcao)
    int par[MAX_PAR];         // tipos dos parametros (para funcao)
} tabSimb[TAM_TAB], elemTab;

int posTab = 0; 

void maiscula (char *s) {
    for(int i = 0; s[i]; i++)
        s[i] = toupper(s[i]);
}

int buscaSimbolo(char *id)
{
    int i;
    //maiscula(id);
    for (i = posTab - 1; strcmp(tabSimb[i].id, id) && i >= 0; i--)
        ;
    if (i == -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado!", id);
        yyerror(msg);
    }
    return i;
}
void insereSimbolo (struct elemTabSimbolos elem) {
    int i; 
    //maiscula(elem.id);
    if (posTab == TAM_TAB)
        yyerror("Tabela de Simbolos Cheia!");
    for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--)
        ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg);
    }
    tabSimb[posTab++] = elem; 
}

// Sugestao:
// -------------------------------------------------------------
// Desenvolver uma rotina para ajustar o endereco dos parametros
// na tabela de simbolos e o vetor de parametros da funcao.
// depois que for cadastrado o ultimo parametro

// Modificar a rotina mostraTabela para apresentar os outros
// campos (esc, rot, cat, ...) da tabela.
void mostraTabela () {
    puts("Tabela de Simbolos");
    puts("------------------");
    printf("\n%30s | %s | %s \n", "ID", "END", "TIP");
    for(int i = 0; i < 50; i++) 
        printf(".");
    for(int i = 0; i < posTab; i++)
        printf("\n%30s | %3d | %s", tabSimb[i].id, tabSimb[i].end, tabSimb[i].tip == INT? "INT" : "LOG");
    printf("\n");
}



// estrutura da pilha semantica
// usada para enderecos, variaveis, rotulos

#define TAM_PIL 100
int pilha[TAM_PIL];
int topo = -1;

void empilha (int valor) {
    if (topo == TAM_PIL)
        yyerror("Pilha semântica cheia");
    pilha[++topo] = valor;
}

int desempilha() {
    if (topo == -1)
        yyerror("Pilha semântica vazia");
    return pilha[topo--];
}

void testaTipo(int tipo1, int tipo2, int ret) 
{
    int t1 = desempilha();
    int t2 = desempilha();
    if (t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo");
    empilha(ret);
}
