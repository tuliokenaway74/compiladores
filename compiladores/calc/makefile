calc : calc.l calc.y;
	flex -o lexico.c calc.l;\
	bison -v -d calc.y -o calc.c;\
	gcc calc.c -o calc;

limpa: ;
	rm lexico.c calc.c calc.h calc.output calc