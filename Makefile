# MANEA STEFANIA-DELIA 335CC
LEX_FILE = tema.l
LEX_OUTPUT = lex.yy.c
EXECUTABLE = tema

all: $(EXECUTABLE)

$(EXECUTABLE): $(LEX_OUTPUT)
	@gcc $(LEX_OUTPUT) -o $(EXECUTABLE) -lfl

$(LEX_OUTPUT): $(LEX_FILE)
	@flex $(LEX_FILE)

clean:
	@rm -f $(LEX_OUTPUT) $(EXECUTABLE)

.PHONY: all clean run
