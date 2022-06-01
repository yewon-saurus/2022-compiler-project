%{
#include <string.h>
#include "cbu2.h"
#define MAXSYM	100
#define	MAXSYMLEN	20
char symtbl[MAXSYM][MAXSYMLEN];
int lineno=1;
int insertsym();
int maxsym=0;
char s[30];
int temp;

%}
sp		[ \t]
ws		{sp}+
nl		\n
eletter	[A-Za-z]
hletter	[\xb0-\xfe][\xa0-\xfe]
letter	({eletter}|{hletter})
digit	[0-9]
id		{letter}({letter}|{digit})*
%%
{ws}	{/* do nothing */}
{nl}	{lineno++; }
"+"		{return(ADD); }
"-"		{return(SUB); }
:=		{return(ASSGN); }
;		{return(STMTEND); }
Ω√¿€	{return(START); }
≥°		{return(END); }
"*"		{return(MUL); }
"/"		{return(DIV); }
if		{return(IF); }
else	{return(ELSE); }
while	{return(WHILE); }
"<"		{return(LT); }
"<="	{return(LE); }
">"		{return(GT); }
">="	{return(GE); }
"=="	{return(EQ); }
"!="	{return(NE); }
{id}	{strcpy(s, yytext); temp=insertsym(s); yylval=MakeNode(ID, temp); return(ID);}
{digit}+		{sscanf(yytext, "%d", &temp); yylval=MakeNode(NUM, temp); return(NUM);}
.		{printf("invalid token %s\n", yytext); }
%%

int insertsym(s)
char *s;
{
int i;

	for(i=0;i<maxsym; i++) {
		if(strcmp(s, symtbl[i])==0) return(i);
		}
	if (i<MAXSYM-1) {
		strcpy(symtbl[maxsym],s);
		maxsym++;
		return(maxsym-1);
		}
	else
		{printf("symbol table overflow\n");}
	return(0);
}

yywrap() {}