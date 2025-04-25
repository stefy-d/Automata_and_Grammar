# Automata_and_Grammar

* Pentru a decide dacă am dat de un automat sau de o gramatică, caut 
începutul de declarație „:: FiniteAutomaton”, repectiv „:: Grammar” precedat de 
orice și oricâte caractere care acelea vor reprezenta numele structurii.
Numele este afișat imediat ce este extras din șir folosind „yyless” pentru a
păstra doar primele caractere. După ce afișez numele schimb starea în
AUTOMAT/GRAMATICA.

* Mai departe, pentru a afișa informațiile despre automat sau gramatică în ordinea
specificată, trebuie să rețin informațiile din declarație. Astfel, am 
declarat două structuri, automat și gramatică, cu câmpurile necesare.

* Pentru determinarea alfabetului caut sintagma „alphabet :: ” și schimb starea în
în funcție de starea în care eram AUTOMAT/GRAMATICA, deoarece trebuie sa știu 
dacă rețin în structura automat sau gramatică. Pentru alfabetul în sine, 
caut apoi {} cu orice între ele și rețin șirul.

*AUTOMAT*
* Din starea AUTOMAT pot căuta „initial_state”, „state”, „final_state” pentru a 
determina stările, starea inițială și stările finale ale automatului și le 
rețin în structură. De asemenea, din AUTOMAT, când am șirul „->” înseamnă că am 
ajuns la începutul primei reguli de tranziție și trec în starea TRANSITIONS.

* Din starea **TRANSITIONS** caut „simbol->” rețin simbolul, verific dacă este „e” 
pentru că în cazul ăsta înseamnă că automatul e nedeterminist. Caut „stare ;”
ca să stabilesc starea în care se ajunge cu acest simbol. Aici verific dacă 
simbolul pe care l-am găsit înainte este variabilă globală sau locală ca
să știu dacă trebuie să expandez simbolul și să adaug toate regulile lareguli 
de producție. Finalul tranziției este marcat de „) ;”. Când ajung aici 
verific dacă toate tranzițiile din starea curentă au fost făcute cu simboluri 
diferite. Dacă am găsit mai mult de o tranziție cu același simbol, setez 
automatul ca fiind nedeterminist.

_GRAMATICA:_
* Din starea **GRAMATICA** pot căuta „start_symbol” ca să determin simbolul de start.
Pentru a determina ce tip de gramatică am, caut pattern-urile corespunzătoare
fiecărui tip și mă schimb în diferite stări în funcție de șirul cu care fac 
match. Pot avea stările GR, GIC, GDC, GFR. Pot schimba stările doar dacă sunt
în starea de început adică GRAMATICA sau dintr-un tip restrictiv în ceva mai 
puțin restrictiv, niciodată invers. De asemenea, fac verificări dacă se trece
direct direct din starea inițială doar în „e” sau dacă se respectă restricția
pentru lungimea părților.

* Când întâlnesc „) ;;” care marchează finalul unei declarații, apelez funcțiile 
de print, ca să afișez informațiile despre automat/gramatică în ordinea
corespunzătoare.
