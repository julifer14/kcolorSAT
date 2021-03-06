%Aitor Mallol
%Julian Fernandez
%%%%%%%%%%%%
% sat(F,I,M)
% si F es satisfactible, M sera el model de F afegit a la interpretacio I (a la primera crida I sera buida).
% Assumim invariant que no hi ha literals repetits a les clausules ni la clausula buida inicialment.
sat([],I,I):-     write('SAT!!'),nl,!. 
sat(CNF,I,M):-
   % Ha de triar un literal d’una clausula unitaria, si no n’hi ha cap, llavors un literal pendent qualsevol.
   tria(CNF,Lit),
   % Simplifica la CNF amb el Lit triat (compte pq pot fallar, es a dir si troba la clausula buida fallara i fara backtraking).
   simplif(Lit,CNF,CNFS),
   append(I,[Lit],IntAct),
   % crida recursiva amb la CNF i la interpretacio actualitzada
   sat(CNFS , IntAct ,M).


%%%%%%%%%%%%%%%%%%
% tria(F, Lit)
% Donat una CNF,
% -> el segon parametre sera un literal de CNF
%  - si hi ha una clausula unitaria sera aquest literal, sino
%  - un qualsevol o el seu negat. (De l'ultima clausula)
tria([X|_],Lit) :-   length(X,Mida), 
                     Mida =:= 1, extreure(X,Lit),!. % Clausula unitaria

tria([X|Xs],Lit) :-  length(X,Mida), 
                     Mida =\= 1, 
                     tria(Xs,Lit). % no hi ha clausula unitaria

tria([X|_],Lit) :-   extreure(X,Lit). %agafa un literal qualsevol




%extreure(F,Lit)
%Extreu un literal d'una llista.
extreure([],_) :- write('No es pot treure del buit!'),n1,!.
extreure([X|_],X).

%%%%%%%%%%%%%%%%%%%%%
% simlipf(Lit, F, FS)
% Donat un literal Lit i una CNF,
% -> el tercer parametre sera la CNF que ens han donat simplificada:
%  - sense les clausules que tenen lit
%  - treient -Lit de les clausules on hi es, si apareix la clausula buida fallara.
% ...
simplif(Lit,F,Fs) :- eliminaPositiu(Lit, F,Fss),!, 
                     eliminaNegatiu(Lit,Fss,Fs),!, 
                     \+ member([],Fs),!.



%eliminaPositiu(Lit, F, FS)
%Donat un literal i una CNF, elimina la clausula que conté el literal 
eliminaPositiu(_,[],[]) :- !.

eliminaPositiu(Lit, [X|Xs],Fs) :-   member(Lit,X), 
                                    eliminaPositiu(Lit, Xs, Fs),!.

eliminaPositiu(Lit, [X|Xs],Fs) :-   eliminaPositiu(Lit,Xs,Retorn), 
                                    append([X],Retorn,Fs),!.

%eliminaNegatiu(Lit, F, Fs)
%Donat un literal i una CNF, elimana el literal de signe contrari a Lit.  
eliminaNegatiu(_,[],[]).
eliminaNegatiu(Lit, [X|Xs], Fs) :-  LitNeg is (-Lit), 
                                    member(LitNeg,X), 
                                    delete(X,LitNeg,ClauSenseLit), 
                                    eliminaNegatiu(Lit, Xs, Retorn), 
                                    append([ClauSenseLit],Retorn,Fs),!.

eliminaNegatiu(Lit, [X|Xs],Fs) :-   eliminaNegatiu(Lit, Xs, Retorn),
                                    append([X], Retorn, Fs),!.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%
% unCert(L,CNF)
% Donat una llista de variables booleanes,
% -> el segon parametre sera la CNF que codifica que exactament una sigui certa.
% ... pots crear i utilitzar els auxiliars comaminimUn i nomesdUn
unCert([],_).
unCert(L,CNF) :- comaminimUn(L,CNF), nomesdUn(L,CNF).

%%%%%%%%%%%%%%%%%%%
% comaminimUn(L,CNF)
% Donat una llista de variables booleanes,
% -> el segon parametre sera la CNF que codifica que com a minim una sigui certa.
% ...
% p or q
comaminimUn([],_).
comaminimUn([X|Xs],CNF) :- X>0, !.
comaminimUn([X|Xs],CNF) :- X<0, comaminimUn(Xs,CNF).


%%%%%%%%%%%%%%%%%%%
% nomesdUn(L,CNF)
% Donat una llista de variables booleanes,
% -> el segon parametre sera la CNF que codifica que com a molt una sigui certa.
% ...
% p nand q ??
nomesdUn([],_).
nomesdUn(L,CNF) :- NUM is 0, iNomesdUn(L,CNF,NUM).

iNomesdUn([],_,_).
iNomesdUn([X|Xs],CNF,NUM) :- X>0, NUM=:=0, NUM2 is NUM+1, X2 is -X, append(CNF, [X2], CNF2), iNomesdUn(Xs,CNF2,NUM2).
iNomesdUn([X|Xs],CNF,NUM) :- X>0, NUM>0, append(CNF, [X], CNF2), iNomesdUn(Xs,CNF2,NUM).
iNomesdUn([X|Xs],CNF,NUM) :- X<0, append(CNF, [X], CNF2), iNomesdUn(Xs,CNF2,NUM).


%generarLlista(I, F, L).
%L és la llista de I fins F 
generaLLista(I, I, [I]).
generaLLista(I, F, LL):-  I < F,  K is I+1,
                          generaLLista(K, F, Cua),
                          append([I], Cua, LL),!. 

%treuN(N,L,X,Xs).
%Donada la llista L, extreu N elements de L (X) i la cua es Xs.
treuN(0, L, [], L).
treuN(N, L, X, Xs):- K is N-1, K >= 0, 
                     append([A], B, L),
                     treuN(K, B, X2, Xs),
                     append([A], X2, X).

%separar(K,L,Res)
%Donada una llista L de variables booleanes, Res serà la llista de llistes L con cada subllista té K elements
%Per exemple la llista [1,2,3,4] serà [[1,2],[3,4]] amb K=2
separar(_, [], []).
separar(K, L, Res) :- treuN(K, L, E, CUA),
                      separar(K, CUA, NE),
                      append([E], NE, Res).

%generarLlistaLlistes(N,K,L).
% N és el nombre de nodes, K és k-color i L és la llista de llistes que codifica el problema.
%Genera la llista de llistes de variables Booleanes. Per codificar de quin color es codifica cada node.
generarLlistaLlistes(N,K,L) :-   generaLLista(1,N,Llista), 
                                 separar(K,Llista,L),!.

%%%%%%%%%%%%%%%%%%%
% els nodes del graph son nombres consecutius d'1 a N.
% K es el nombre de colors a fer servir.
% Arestes es la llista d'arestes del graph com a parelles de nodes
% Inici es la llista de parelles (node,num_color) que s'han de forçar
% C sera la CNF que codifica graph coloring problem pel graph donat

%codifica(N,K,Arestes,Inici,C):-
%   crear la llista de llistes de variables pels colors de cada node
%   crear la CNF que fa que cada node tingui un color [unCert]
%   crear la CNF que força els colors dels nodes segons Inici [inicialitza]
%   crear la CNF que fa que dos nodes que es toquen tinguin colors diferents [ferMutexes]
%   C sera el resultat dajuntar les CNF creades

codifica(N,K,Arestes,Inici,C) :- generarLlistaLlistes(N,K,LLV),
                                 %unCert(LLV,CNFUNCERT),
                                 inicialitza(LLV,Inici,CNFINI),
                                 ferMutexes(LLV,Arestes,CNFMUT),
                                 append([],CNFINI,C1),
                                 append(C1,CNFMUT,C).


%actualitzarNode(+Node, Color, N)
% Donat un node [-1,-2,-3] i un color 3, N és el node amb el color actualitzat, és a dir,  N = [-1,-2,3] N indica que el node es pinta de color 3
actualitzarNode(Node,Color,N) :- ColorOk is Color-1, 
                                 nth0(ColorOk, Node, Valor), 
                                 ValorOk is -Valor, 
                                 replace(Node,ColorOk,ValorOk,N).

posarEnNegatiu([],[]).
posarEnNegatiu([X|Xs],[Y|Ys]) :- iposarEnNegatiu(X,Y), 
                                 posarEnNegatiu(Xs, Ys).

%posarEnNegatiu(+L,LN).
%Donada una llista de literals els posa tot en negatiu.
iposarEnNegatiu([],[]).
iposarEnNegatiu([X|Xs],[XOk|N]) :-  X>0, 
                                    XOk is -X, 
                                    iposarEnNegatiu(Xs,N),!.

iposarEnNegatiu([X|Xs],[X|N]) :-    X<0, 
                                    iposarEnNegatiu(Xs,N).

%Donada una llista de llistes de variables i una llista de parelles (nombre de node, color)
%  -> Genera CNF que faci que cada node inicialitzat tingui el color que es demana 
%inicialitza(+LLV, +Ini,CNF) 
inicialitza(_,[],[]).
inicialitza(LLV, Ini,CNF) :-  posarEnNegatiu(LLV,L),
                              inicialitzaBis(L, Ini,CNF).

%inicialitzaBis(+LLV, +Ini,CNF) 
% Dades prefixades. Donada una llista de llista de variables XIJ i un allista de perelles (nombre de cada node, color) 
%   -> Genera CNF que fa que cad anode inicializat tingui el color que es demana.
inicialitzaBis(_,[],[]).
inicialitzaBis(V, [(Node,Color)|Xs], [NouNode|R]) :-  NodeOk is Node-1, 
                                                      nth0(NodeOk,V,NodeACanviar),
                                                      actualitzarNode(NodeACanviar,Color,NouNode),
                                                      inicialitzaBis(V, Xs, R),!.
   


%Donat una llista, un index i un element, es canvia el valor del index 
replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]) :- I > 0, I1 is I-1, replace(T, I1, X, R),!.

% ferMutexes(+LLV, +Arestes, CNF).
% Nodes veins tinguin colors diferents.
% Donada una llista de llistes de variables i una llista d'arestes (les arestes seran parelles de nombres de nodes). 
% Generi CNF que eviti que dos veins tinguin el mateix color assignat
%IDEA: Per cada Element del Node, si es positiu indicar quins han de ser negatius forsosament. 
ferMutexes(_,_,[]).
%ferMutexes(V,[(Node1,Node2)|Xs], [[Node1,Resultat]|CNF]) :- midaSubLlista(V,K), Resultat is (Node2*K), write(Resultat), write('\n'),ferMutexes(V,Xs,CNF).%   ferMutexes(Xs,A,CNF).

%midaSubLlista([X|_], S) :- length(X,S).

                               
%%%%%%%%%%%%%%%%%%%%
% resolGraf(N,A,K,Inputs)
% Donat el nombre de nodes, el nombre de colors, les Arestes A, i les inicialitzacions,
% -> es mostra la solucio per pantalla si en te o es diu que no en te.

%resol(N,K,A, I):-
%   codifica(...),
%   write('SAT Solving ..................................'), nl,
%   crida a SAT
%   write('Graph (color number per node in order: '), nl,
%   mostrar el resultat

resol(N,K,A,I) :- codifica(N,K,A,I,CNF),
                  write(CNF),nl,
                  write('SAT Solving ..................................'), nl,
                  sat(CNF,I,M),
                  write('Graph (color number per node in order: '), nl,
                  write(M).
                  %mostrarResultatsSAT(M).
                  %mostrar el resultat


%%%%%%%%%%%%%%%%%%%%
% chromatic(N,A,Inputs)
% Donat el nombre de nodes,  les Arestes A, i les inicialitzacions,
% -> es mostra la solucio per pantalla si en te o es diu que no en te.
% Pista, us pot ser util fer una inmersio amb el nombre de colors permesos.

chromatic(N,A,Inputs) :- ichromatic(0,N,A,Inputs).

ichromatic(I,N,A,Inputs) :- I<N, K is I+1,
                           resol(N,K,A,I),write(K),nl,
                           ichromatic(K,N,A,Inputs).

ichromatic(I,N,A,Inputs) :- I<N, K is I+1,
                           \+ resol(N,K,A,I),write(K), write(' Error!'),nl,
                           ichromatic(K,N,A,Inputs).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% com a query podeu cridar:
% ?- graf1(N,A), chromatic(N,A,[]).
% i aixi amb altres grafs que us definiu com els que hi ha a continuacio:
   

% aquest graf te 21 nodes i nombre chromatic 4.
graf1(11,[(1,2),(1,4),(1,7),(1,9),(2,3),(2,6),(2,8),(3,5),(3,7),(3,10),
         (4,5),(4,6),(4,10),(5,8),(5,9),(6,11),(7,11),(8,11),(9,11),(10,11)]).

% aquest graf te 23 nodes i nombre chromatic 5.
graf2(23,[(1,2),(1,4),(1,7),(1,9),(1,13),(1,15),(1,18),(1,20),(2,3),(2,6),(2,8),(2,12),(2,14),(2,17),(2,19),
         (3,5),(3,7),(3,10),(3,13),(3,16),(3,18),(3,21),(4,5),(4,6),(4,10),(4,12),(4,16),(4,17),(4,21),
         (5,8),(5,9),(5,14),(5,15),(5,19),(5,20),(6,11),(6,13),(6,15),(6,22),(7,11),(7,12),(7,14),(7,22),
         (8,11),(8,13),(8,16),(8,22),(9,11),(9,12),(9,16),(9,22),(10,11),(10,14),(10,15),(10,22),
         (11,17),(11,18),(11,19),(11,20),(11,21),(12,23),(13,23),(14,23),(15,23),(16,23),(17,23),
         (18,23),(19,23),(20,23),(21,23),(22,23)]).


      
graf3(25,
      [(1,7),(1,5),(1,6),(1,11),(1,16),(1,21),(2,8),(2,14),(2,20),(2,6),(2,3),(2,4),(2,5),(2,7),(2,1),
      (3,9),(3,15),(3,7),(3,2),(3,1),(4,10),(4,8),(4,12),(4,16),(4,5),(4,9),(4,14),(4,19),
      (4,24),(4,3),(4,2),(4,1),(5,9),(5,13),(5,17),(5,21),(5,10),(5,15),(5,1),
      (6,12),(6,18),(6,24),(6,7),(6,8),(6,9),(6,10),(6,11),(6,16),(6,21),(6,2),(6,1),
      (7,13),(7,19),(7,25),(7,11),(7,8),(7,6),(7,3),(7,2),(7,1),(8,14),(8,20),
      (8,12),(8,16),(8,9),(8,7),(8,6),(8,4),(8,3),(8,2),(9,15),(9,13),(9,17),(9,21),
      (9,10),(9,14),(9,19),(9,24),(9,8),(9,7),(9,6),(9,5),(9,4),(9,3),(10,14),(10,18),
      (10,22),(10,15),(10,20),(10,25),(10,9),(10,8),(10,7),(10,6),(10,5),(10,4),
      (11,17),(11,23),(11,12),(11,13),(11,7),(12,16),(12,13),(12,14),(12,15),(12,17),
      (12,22),(12,4),(12,2),(13,19),(13,25),(13,17),(13,21),(13,14),(13,15),(13,18),
      (13,23),(13,12),(13,3),(13,1),(14,20),(14,18),(14,9),(14,8),(14,4),(14,2),(15,19),
      (15,23),(15,20),(15,25),(15,14),(15,13),(15,12),(15,11),(15,10),(15,9),(15,5),
      (15,3),(16,22),(16,17),(16,18),(16,19),(16,20),(16,21),(16,12),(16,11),(16,8),
      (16,6),(17,19),(17,20),(17,22),(17,16),(17,13),(17,12),(17,11),(17,9),(17,7),(17,5),
      (17,2),(18,24),(18,22),(18,19),(18,16),(18,14),(18,13),(18,12),(18,10),(18,8),(18,6),
      (19,24),(19,18),(19,17),(19,16),(19,15),(19,14),(19,13),(19,9),(19,7),(19,4),(19,1),
      (20,24),(20,25),(20,19),(20,18),(20,17),(20,16),(20,15),(20,14),(20,10),(20,8),(20,5),
      (20,2),(21,22),(21,5),(21,1),(22,23),(22,24),(22,25),(22,14),(22,12),(22,10),(22,7),
      (22,2),(23,24),(23,25),(23,22),(23,21),(23,19),(23,18),(23,17),(23,15),(23,13),(23,11),
      (23,8),(23,3),(24,25),(24,23),(24,22),(25,24),(25,23),(25,13)]).
