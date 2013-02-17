CC=gcc
CFLAGS=-Wall
LEX=flex
YACC=bison
YFLAGS=-d

OBJ=obj/
SRC=src/

LEXFILE=$(SRC)interpreteur.l
YACCFILE=$(SRC)interpreteur.y

BIN=interpreteur
MAIN=$(SRC)main.c
PARSER=$(OBJ)parser.o
PARSER_SRC=$(SRC)parser.c
PARSER_H=$(SRC)parser.h
LEXER=$(OBJ)lexer.o
LEXER_SRC=$(SRC)lexer.c

all: $(BIN)

$(BIN): $(PARSER) $(LEXER) 
	$(CC) $(CFLAGS) -o $@ $(MAIN) $^ -ll

$(PARSER): $(PARSER_SRC)
	$(CC) $(CFLAGS) -c -o $@ $^

$(LEXER): $(LEXER_SRC)
	$(CC) $(CFLAGS) -c -o $@ $^

$(LEXER_SRC):
	$(LEX) -o $@ $(LEXFILE)

$(PARSER_SRC):
	$(YACC) $(YFLAGS) -o $@ $(YACCFILE)

clean:
	rm $(OBJ)*.o $(PARSER_SRC) $(PARSER_H) $(LEXER_SRC)

fullclean:
	rm $(BIN) $(OBJ)*.o $(PARSER_SRC) $(PARSER_H) $(LEXER_SRC)

