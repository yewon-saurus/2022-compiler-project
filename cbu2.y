%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DEBUG	0

#define	 MAXSYM	100
#define	 MAXSYMLEN	20
#define	 MAXTSYMLEN	15
#define	 MAXTSYMBOL	MAXSYM/2

#define STMTLIST 500

typedef struct nodeType {
	int token;
	int tokenval;
	struct nodeType *son;
	struct nodeType *brother;
	enum {iselse, isloop, nomal} noderep;
	} Node;

#define YYSTYPE Node*
	
int tsymbolcnt=0;
int errorcnt=0;

int labelno=0;
int looplabel=0;

FILE *yyin;
FILE *fp;

extern char symtbl[MAXSYM][MAXSYMLEN];
extern int maxsym;
extern int lineno;

void DFSTree(Node*);
Node * MakeOPTree(int, Node*, Node*);
Node * MakeNode(int, int);
Node * MakeListTree(Node*, Node*);
void codegen(Node* );
void prtcode(Node* );

void	dwgen();
int		gentemp();
void	assgnstmt(int, int);
void	numassgn(int, int);
void	addstmt(int, int, int);
void	substmt(int, int, int);
int		insertsym(char *);
%}

%token	ADD SUB ASSGN ID NUM STMTEND START END ID2
%token	MUL DIV IF ELSE WHILE
%token	LT LE GT GE EQ NE

%left	ADD SUB
%left	MUL DIV
%right	ASSGN


%%
program	: START stmt_list END	{ if (errorcnt==0) {codegen($2); dwgen();} }
		;

stmt_list: 	stmt_list stmt 	{$$=MakeListTree($1, $2);}
		|	stmt			{$$=MakeListTree(NULL, $1);}
		| 	error STMTEND	{ errorcnt++; yyerrok;}
		;

stmt	: 	ID ASSGN expr STMTEND	{ $1->token = ID2; $$=MakeOPTree(ASSGN, $1, $3);}
		|	IF comp stmt_list STMTEND { $$=MakeOPTree(IF, $2, $3); }
		|	IF comp stmt_list ELSE stmt_list STMTEND { $$=MakeListTree(MakeOPTree(ELSE, $2, $3), $5); $5->son->son->noderep = iselse; }
		|	WHILE comp stmt_list STMTEND { $$=MakeOPTree(WHILE, $2, $3); $2->son->noderep = isloop; }
		;

expr	: 	expr ADD term	{ $$=MakeOPTree(ADD, $1, $3); }
		|	expr SUB term	{ $$=MakeOPTree(SUB, $1, $3); }
		|	expr MUL term	{ $$=MakeOPTree(MUL, $1, $3); }
		|	expr DIV term	{ $$=MakeOPTree(DIV, $1, $3); }
		|	term
		;

comp	:	expr LT expr	{ $$=MakeOPTree(LT, $1, $3); }
		|	expr LE expr	{ $$=MakeOPTree(LE, $1, $3); }
		|	expr GT expr	{ $$=MakeOPTree(GT, $1, $3); }
		|	expr GE expr	{ $$=MakeOPTree(GE, $1, $3); }
		|	expr EQ expr	{ $$=MakeOPTree(EQ, $1, $3); }
		|	expr NE expr	{ $$=MakeOPTree(NE, $1, $3); }
		;

term	:	ID		{ /* ID node is created in lex */ }
		|	NUM		{ /* NUM node is created in lex */ }
		;


%%
int main(int argc, char *argv[]) 
{
	printf("\nsample CBU compiler v2.0\n");
	printf("(C) Copyright by Jae Sung Lee (jasonlee@cbnu.ac.kr), 2022.\n");
	
	if (argc == 2)
		yyin = fopen(argv[1], "r");
	else {
		printf("Usage: cbu2 inputfile\noutput file is 'a.asm'\n");
		return(0);
		}
		
	fp=fopen("a.asm", "w");
	
	yyparse();
	
	fclose(yyin);
	fclose(fp);

	if (errorcnt==0) 
		{ printf("Successfully compiled. Assembly code is in 'a.asm'.\n");}
}

yyerror(s)
char *s;
{
	printf("%s (line %d)\n", s, lineno);
}


Node * MakeOPTree(int op, Node* operand1, Node* operand2)
{
Node * newnode;

	newnode = (Node *)malloc(sizeof (Node));
	newnode->token = op;
	newnode->tokenval = op;
	newnode->son = operand1;
	newnode->brother = NULL;
	operand1->brother = operand2;
	return newnode;
}

Node * MakeNode(int token, int operand)
{
Node * newnode;

	newnode = (Node *) malloc(sizeof (Node));
	newnode->token = token;
	newnode->tokenval = operand; 
	newnode->son = newnode->brother = NULL;
	return newnode;
}

Node * MakeListTree(Node* operand1, Node* operand2)
{
Node * newnode;
Node * node;

	if (operand1 == NULL){
		newnode = (Node *)malloc(sizeof (Node));
		newnode->token = newnode-> tokenval = STMTLIST;
		newnode->son = operand2;
		newnode->brother = NULL;
		return newnode;
		}
	else {
		node = operand1->son;
		while (node->brother != NULL) node = node->brother;
		node->brother = operand2;
		return operand1;
		}
}

void codegen(Node * root)
{
	DFSTree(root);
}

void DFSTree(Node * n)
{
	if (n==NULL) return;
	DFSTree(n->son);
	prtcode(n);
	DFSTree(n->brother);
	
}

void prtcode(Node * n)
{
	switch (n->token) {
	case ID:
		if (n->noderep == isloop) {
			fprintf(fp, "LABEL LOOP%d\n", looplabel);
		}
		fprintf(fp,"RVALUE %s\n", symtbl[n->tokenval]);
		break;
	case ID2:
		if (n->noderep == iselse) {
			fprintf(fp, "LABEL LABEL%d\n", labelno++);
		}
		fprintf(fp, "LVALUE %s\n", symtbl[n->tokenval]);
		break;
	case NUM:
		if (n->noderep == isloop) {
			fprintf(fp, "LABEL LOOP%d\n", looplabel);
		}
		fprintf(fp, "PUSH %d\n", n->tokenval);
		break;
	case ADD:
		fprintf(fp, "+\n");
		break;
	case SUB:
		fprintf(fp, "-\n");
		break;
	case MUL:
		fprintf(fp, "*\n");
		break;
	case DIV:
		fprintf(fp, "/\n");
		break;
	case LT:
		fprintf(fp, "$ --- Less Than ---\n");
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOPLUS LABEL%d\n", labelno);
		fprintf(fp, "GOFALSE LABEL%d\n", labelno);
		break;
	case LE:
		fprintf(fp, "$ --- Less Equal ---\n");
		fprintf(fp, "-\n");
		fprintf(fp, "GOPLUS LABEL%d\n", labelno);
		break;
	case GT:
		fprintf(fp, "$ --- Greater Than ---\n");
		fprintf(fp, "-\n");
		fprintf(fp, "COPY\n");
		fprintf(fp, "GOMINUS LABEL%d\n", labelno);
		fprintf(fp, "GOFALSE LABEL%d\n", labelno);
		break;
	case GE:
		fprintf(fp, "$ --- Greater Equal ---\n");
		fprintf(fp, "-\n");
		fprintf(fp, "GOMINUS LABEL%d\n", labelno);
		break;
	case EQ:
		fprintf(fp, "$ --- Equal ---\n");
		fprintf(fp, "-\n");
		fprintf(fp, "GOTRUE LABEL%d\n", labelno);
		break;
	case NE:
		fprintf(fp, "$ --- Not Equal ---\n");
		fprintf(fp, "-\n");
		fprintf(fp, "GOFALSE LABEL%d\n", labelno);
		break;
	case IF:
	{
		fprintf(fp, "$ --- if ---\n");
		fprintf(fp, "LABEL LABEL%d\n", labelno++);
		break;
	}
	case ELSE:
	{
		fprintf(fp, "$ --- else ---\n");
		break;
	}
	case WHILE:
	{
		fprintf(fp, "$ --- while ---\n");
		fprintf(fp, "GOTO LOOP%d\n", looplabel);
		looplabel++;
		fprintf(fp, "LABEL LABEL%d\n", labelno++);
		break;
	}
	case ASSGN:
		fprintf(fp, ":=\n");
		break;
	case STMTLIST:
	default:
		break;
	};
}


/*
int gentemp()
{
char buffer[MAXTSYMLEN];
char tempsym[MAXSYMLEN]="TTCBU";

	tsymbolcnt++;
	if (tsymbolcnt > MAXTSYMBOL) printf("temp symbol overflow\n");
	itoa(tsymbolcnt, buffer, 10);
	strcat(tempsym, buffer);
	return( insertsym(tempsym) ); // Warning: duplicated symbol is not checked for lazy implementation
}
*/
void dwgen()
{
int i;
	fprintf(fp, "HALT\n");
	fprintf(fp, "$ -- END OF EXECUTION CODE AND START OF VAR DEFINITIONS --\n");

// Warning: this code should be different if variable declaration is supported in the language 
	for(i=0; i<maxsym; i++) 
		fprintf(fp, "DW %s\n", symtbl[i]);
	fprintf(fp, "END\n");
}

