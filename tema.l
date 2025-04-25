    /* MANEA STEFANIA-DELIA 335CC*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <regex.h>
#include <stdbool.h>

typedef struct {
    char state[100];
    char symbol;
    char next_state[100];
} Tranzitie;

typedef struct {
    int type;
    int num_states;
    char initial_state[100];
    char final_states[100];
    char alphabet[100];
    bool active_variable;
    char identificator[100];
    char domeniu[100];
    int num_transitions;
    Tranzitie tranzitii[100];
} Automat;

typedef struct {
    int type;
    int num_reguli;
    char alphabet[100];
    int alphabet_size;
    char start_symbol[100];
    bool active_variable;
    char identificator[100];
    char domeniu[100];
    int l;
} Gramatica;

typedef struct {
    char identificator[100];
    char domeniu[100];
} VariabilaGlobala;

Automat a[100];
int n = 0;  // numarul de automate
Gramatica g[100];
int m = 0;  // numarul de gramatici
VariabilaGlobala v[100];
int k = 0;  // numarul de variabile globale

char prev_state[100];
int prev_pos;

// returneaza tipul gramaticii
char *get_tip_gramatica(int type) {
    switch (type) {
        case 0:
            return "GFR";
        case 1:
            return "GDC";
        case 2:
            return "GIC";
        case 3:
            return "GR";
    }
}

void print_automat() {
    // tipul automatului
    if (a[n].type == 0) {
        printf("Tipul automatului: Automat finit nedeterminist\n");
    } else {
        printf("Tipul automatului: Automat finit determinist\n");
    }

    // alfabetul
    printf("Alfabetul de intrare: {");
    printf("%s", a[n].alphabet);
    printf("}\n");
    
    // stari
    printf("Numarul de stari: %d\n", a[n].num_states);
    // stare initiala
    printf("Starea initiala: %s\n", a[n].initial_state);
    // stari finale
    printf("Stari finale: {");
    printf("%s", a[n].final_states);
    printf("}\n");

    // tranzitii
    printf("Functia de tranzitie:\n");
    for(int i = 0; i < a[n].num_transitions; i++) {
        printf("\tm(%s, %c) = %s\n", a[n].tranzitii[i].state, a[n].tranzitii[i].symbol, a[n].tranzitii[i].next_state);
    }

    // variabila locala
    if (a[n].active_variable) {
        printf("Variabila locala:\n");
        printf("\tIdentificator: %s\n", a[n].identificator);
        printf("\tDomeniu: {");
        for (int i = 0; i < strlen(a[n].domeniu); i++) {
            if (i == strlen(a[n].domeniu) - 1) {
                printf("%c}\n", a[n].domeniu[i]);
            } else {
                printf("%c, ", a[n].domeniu[i]);
            }
        }
    }
}

void print_gramatica() {
    // tipul gramaticii
    printf("Tipul gramaticii: %s\n", get_tip_gramatica(g[m].type));

    // numarul de reguli de productie
    printf("Numarul de reguli de productie: %d\n", g[m].num_reguli);

    // alfabetul
    printf("Alfabetul de intrare: {");
    printf("%s", g[m].alphabet);
    printf("}\n");

    // variabila locala
    if (g[m].active_variable) {
        printf("Variabila locala:\n");
        printf("\tIdentificator: %s\n", g[m].identificator);
        printf("\tDomeniu: {");
        for (int i = 0; i < strlen(g[m].domeniu); i++) {
            if (i == strlen(g[m].domeniu) - 1) {
                printf("%c}\n", g[m].domeniu[i]);
            } else {
                printf("%c, ", g[m].domeniu[i]);
            }
        }
    }
}

int current_file_index = 0;
char *file_list[100]; // lista fisierelor de intrare
int total_files = 0;  // numarul total de fisiere

int yywrap(void) {
    if (current_file_index < total_files - 1) {
        current_file_index++;
        yyin = fopen(file_list[current_file_index], "r");
        if (!yyin) {
            perror("Nu s-a putut deschide fisierul\n");
            return 1;
        }
        printf("\n      =================Am deschis fisierul %s====================\n", file_list[current_file_index]);
        return 0; // continua cu urmatorul fisier
    }
    return 1; // am terminat de procesat fisierele
}

%}

%x IDENTIFICATOR IGNORE DOMENIU ALPHABET STATES INITIAL_STATE FINAL_STATE AUTOMAT IDENTIFICATOR_A  IGNORE_A DOMENIU_A ALPHABET_G GRAMATICA IDENTIFICATOR_G IGNORE_G DOMENIU_G GR GIC GDC GFR START_SYMBOL TRANSITIONS

%%

    /* identificarea variabilelor */
<AUTOMAT,INITIAL,GRAMATICA>variable[ \t]+ {
    if (YY_START == INITIAL) {
        printf("Variabilă globală:\n");
        BEGIN(IDENTIFICATOR);
    } else {
        if (YY_START == AUTOMAT) {           
            BEGIN(IDENTIFICATOR_A);
        } else {
            BEGIN(IDENTIFICATOR_G);
        }
    }
}

    /* identificatorul variabilei */
<IDENTIFICATOR,IDENTIFICATOR_A,IDENTIFICATOR_G>[a-z_] {
    if (YY_START == IDENTIFICATOR) {
        printf("\tIdentificator:  %s\n", yytext);
        strcpy(v[k].identificator, yytext);    
        BEGIN(IGNORE);
    } else {
        if (YY_START == IDENTIFICATOR_A) {
            a[n].active_variable = true;
            strcpy(a[n].identificator, yytext);
            BEGIN(IGNORE_A);
        } else {
            g[m].active_variable = true;
            strcpy(g[m].identificator, yytext);
            BEGIN(IGNORE_G);
        }
    }
}

    /* pentru varibile ignor niste caractere */
<IGNORE_A,IGNORE,IGNORE_G>[ \t]::=[ \t]*\{ {
    if (YY_START == IGNORE) {
        BEGIN(DOMENIU);
    } else {
        if (YY_START == IGNORE_A) {
            BEGIN(DOMENIU_A);
        } else {
            BEGIN(DOMENIU_G);
        }
    }
}

    /* construiesc domeniul variabilei */
<DOMENIU_A,DOMENIU,DOMENIU_G>[a-zA-Z0-9_]+ {
    if (YY_START == DOMENIU) {
        strncat(v[k].domeniu, yytext, sizeof(v[k].domeniu) - strlen(v[k].domeniu) - 1);
    } else if (YY_START == DOMENIU_A) {
        strncat(a[n].domeniu, yytext, sizeof(a[n].domeniu) - strlen(a[n].domeniu) - 1);
    } else {
        strncat(g[m].domeniu, yytext, sizeof(g[m].domeniu) - strlen(g[m].domeniu) - 1);
    }
}

    /* termin de construit domeniul variabilei */
<DOMENIU_A,DOMENIU,DOMENIU_G>\} {
    if (YY_START == DOMENIU) {
        printf("\tDomeniu: {");
        for (int i = 0; i < strlen(v[k].domeniu); i++) {
            if (i == strlen(v[k].domeniu) - 1) {
                printf("%c}\n", v[k].domeniu[i]);
            } else {
                printf("%c, ", v[k].domeniu[i]);
            }
        }
        k++;
        BEGIN(INITIAL);
    } else if (YY_START == DOMENIU_A) {
        BEGIN(AUTOMAT);
    } else {
        BEGIN(GRAMATICA);
    }
}

    /* identific automat si printez numele lui */
.*[ \t]*::=[ \t]*FiniteAutomaton { 
    printf("\n");
    yyless(yyleng - 20);
    printf("Numele automatului: %s\n", yytext);
    a[n].type = 1;
    a[n].active_variable = false;
    a[n].num_transitions = 0;
    BEGIN(AUTOMAT);
}

    /* identific gramatic si printez numele lui */
.*[ \t]*::=[ \t]*Grammar { 
    printf("\n");
    yyless(yyleng - 12);
    printf("Numele gramaticii: %s\n", yytext);
    g[m].num_reguli = 0;
    g[m].active_variable = false;
    g[m].l = 0;
    BEGIN(GRAMATICA);
}

    /* identific alfabetul */
<AUTOMAT,GRAMATICA>alphabet[ \t]*::[ \t]* {
    if (YY_START == AUTOMAT) {
        BEGIN(ALPHABET);
    } else {
        BEGIN(ALPHABET_G);
    }
}

    /* retin alfabetul automatului */
<ALPHABET>\{([^\}]+) {
    yyless(yyleng - 1); // ca sa sterg spatiul de dupa ultimul caracter din domeniu
    strcpy(a[n].alphabet, yytext + 2);
    BEGIN(AUTOMAT); 
}

    /* retin alfabetul gramaticii */
<ALPHABET_G>\{([^\}]+) {
    yyless(yyleng - 1); // ca sa sterg spatiul de dupa ultimul caracter din domeniu
    strcpy(g[m].alphabet, yytext + 2);
    BEGIN(GRAMATICA); 
}

    /* identific inceputul starilor initiale */
<AUTOMAT>initial_state[ \t]*::[ \t]* {
    BEGIN(INITIAL_STATE);
}

    /* identific starile initiale si le retin */
<INITIAL_STATE>[a-z0-9]+[ \t]*; {
    strncpy(a[n].initial_state, yytext, yyleng - 1);
    BEGIN(AUTOMAT);
}

    /* identific inceputul starilor finale */
<AUTOMAT>final_states[ \t]*::[ \t]* {
    BEGIN(FINAL_STATE);
}

    /* identific starile finale si le retin */
<FINAL_STATE>\{([^\}]+) {
    yyless(yyleng - 1); // ca sa sterg spatiul de dupa ultimul caracter din domeniu
    strcpy(a[n].final_states, yytext + 2);
    BEGIN(AUTOMAT); 
}

    /* identific inceputul starilor */
<AUTOMAT>[ \t]states[ \t]::[ \t]\{ {
    a[n].num_states = 0;
    BEGIN(STATES);
}

    /* identific starile si le retin */
<STATES>[a-z][0-9]*, {
        a[n].num_states++;
}

    /* identific ultima stare si o retin */
<STATES>[a-z][0-9]*[ \t]* {
    a[n].num_states++;
    BEGIN(AUTOMAT);
}

    /* identific starea de plecare */
<AUTOMAT>[a-z0-9]+[ \t]*->[ \t]*\([ \t]* {
    yyless(yyleng - 5);
    strcpy(prev_state, yytext);
    prev_pos = a[n].num_transitions;
    BEGIN(TRANSITIONS);
}

    /* identific simbolul cu care se face tranzitia*/
<TRANSITIONS>[a-z0-9]+[ \t]*->[ \t]* {
    strcpy(a[n].tranzitii[a[n].num_transitions].state, prev_state);
    a[n].tranzitii[a[n].num_transitions].symbol = yytext[0];
    // daca simbolul este 'e', automatul este nedeterminist
    if (yytext[0] == 'e') {
        a[n].type = 0;
    }
}

    /* identific starea in care se ajunge */
<TRANSITIONS>[a-z0-9]+[ \t]*; {
    yyless(yyleng - 2);
    char t = a[n].tranzitii[a[n].num_transitions].symbol;
    int ok = 0;

    // verific dacă simbolul este o variabila globala
    for (int i = 0; i < k; i++) {
        if (t == v[i].identificator[0]) {
            for (int j = 0; j < strlen(v[i].domeniu); j++) {
                // adaug tranzitia pentru fiecare simbol din domeniu               
                strcpy(a[n].tranzitii[a[n].num_transitions].state, prev_state);
                a[n].tranzitii[a[n].num_transitions].symbol = v[i].domeniu[j];
                strcpy(a[n].tranzitii[a[n].num_transitions].next_state, yytext);
                a[n].num_transitions++;
            }
            ok = 1;
        }
    }

    // verific daca simbolul este o variabila locala
    if (a[n].active_variable && t == a[n].identificator[0]) {
        for (int i = 0; i < strlen(a[n].domeniu); i++) {
            // adaug tranzitia pentru fiecare simbol din domeniu
            strcpy(a[n].tranzitii[a[n].num_transitions].state, prev_state);
            a[n].tranzitii[a[n].num_transitions].symbol = a[n].domeniu[i];
            strcpy(a[n].tranzitii[a[n].num_transitions].next_state, yytext);
            a[n].num_transitions++;
        }
        ok = 1;
    }

    // daca nu este o variabila, trateaz simbolul normal
    if (ok == 0) {
        strcpy(a[n].tranzitii[a[n].num_transitions].state, prev_state);
        a[n].tranzitii[a[n].num_transitions].symbol = t;
        strcpy(a[n].tranzitii[a[n].num_transitions].next_state, yytext);
        a[n].num_transitions++;
    }
}

    /* identific sfarsitul tranzitiei */
<TRANSITIONS>\)[ \t]*; {
    for (int i = prev_pos; i < a[n].num_transitions - 1; i++) {
        for (int j = i + 1; j < a[n].num_transitions; j++) {
            if (a[n].tranzitii[i].symbol == a[n].tranzitii[j].symbol) {
                a[n].type = 0;
                break;
            }
        }
    }
    BEGIN(AUTOMAT);
}

    /* identific inceputul simbolului de start */
<GRAMATICA>[ \t]start_symbol[ \t]*::[ \t]* {
    BEGIN(START_SYMBOL);
}

    /* identific simbolul de start si il retin */
<START_SYMBOL>[A-Z0-9]+[ \t]*; {
    strncpy(g[m].start_symbol, yytext, yyleng - 2);
    BEGIN(GRAMATICA);
}

    /* identific inceputul regulii de productie */
<GRAMATICA,GR,GIC>[A-Z][0-9]*[ \t]->[ \t][e][ \t]; {
    
    yyless(yyleng - 7);
    // daca simbolul de start merge doar in 'e', gramatica e dependenta de context
    if (strcmp(yytext, g[m].start_symbol) == 0) {
        g[m].type = 1;
        BEGIN(GDC);
    } else {
        g[m].num_reguli++;
    }
}

<GR,GIC,GDC,GFR,GRAMATICA>[A-Z][0-9]*[ \t]->[ \t][a-z0-9&]*[A-Z]*[0-9]*[ \t] { // pt GR
    g[m].num_reguli++;
    g[m].l = 0;
    if (YY_START == GRAMATICA) {
        g[m].type = 3;
        BEGIN(GR);
    }
}

<GR,GIC,GDC,GFR>[|][ \t][a-z0-9&]*[A-Z]*[0-9]*[ \t] { // pt GR
    g[m].num_reguli++;
}

<GR,GIC,GDC,GFR,GRAMATICA>[A-Z][0-9]*[ \t]->[ \t][a-z0-9&A-Z]*[ \t] { // pt GIC
    g[m].num_reguli++;
    g[m].l = 0;
    // daca sunt la inceputul gramaticii sau pana acum am avut doar reguli de tip 3 trec la tip 2
    if (YY_START == GRAMATICA || YY_START == GR) {
        g[m].type = 2;
        BEGIN(GIC);
    }
}

<GR,GIC,GDC,GFR>[|][ \t][a-z0-9&A-Z]*[ \t] {  // pt GFR 
    g[m].num_reguli++;
    if (g[m].l != 0 && g[m].l > yyleng - 3) {
        g[m].type = 0;
        BEGIN(GFR);
    }
}

<GR,GIC,GDC,GFR,GRAMATICA>[A-Za-z0-9&]*[ \t]- {  // pt GDC
    g[m].l = yyleng - 2;
    g[m].type = 1;
    BEGIN(GDC);
}

<GR,GIC,GDC,GFR>[>][ \t][a-z0-9&A-Z]*[ \t] {  // pt GFR
    g[m].num_reguli++;
    if (g[m].l > yyleng - 3) {
        g[m].type = 0;
        BEGIN(GFR);
    }
}

    /* identific sfarsitul definitiei automatului/gramaticii */
<AUTOMAT,GRAMATICA,GR,GIC,GDC,GFR>\)[ \t];; {
    if (YY_START == AUTOMAT) {
        print_automat();
        n++;
    } else {
        print_gramatica();
        m++;
    }
    BEGIN(INITIAL);
}

<AUTOMAT,INITIAL,GRAMATICA,GR,GIC,GDC,GFR,TRANSITIONS,DOMENIU,DOMENIU_A,DOMENIU_G,STATES>.|\n { /* ignor alte caractere */ }


%%

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s\n", argv[0]);
        return 1;
    }

    // initializeaza lista de fisiere
    for (int i = 1; i < argc; i++) {
        file_list[total_files++] = argv[i];
    }

    // deschide primul fisier
    yyin = fopen(file_list[current_file_index], "r");
    if (!yyin) {
        perror("Nu s-a putut deschide fisierul\n");
        return 1;
    }
    printf("        =================Am deschis fisierul %s====================\n", file_list[current_file_index]);
    yylex();

    return 0;
}

