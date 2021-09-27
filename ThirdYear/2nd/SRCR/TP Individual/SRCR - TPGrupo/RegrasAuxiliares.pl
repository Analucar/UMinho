%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Trabalho Prático Individual - REGRAS AUXILIARES

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
%--------------------- Funções auxiliares -------------

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Lista de adjacentes (unidirecional) de um ponto: Ponto, Lista de adjacencia -> {V,F}

adjacente(Id,Lista) :- ponto(La,Lo,Id,_,LAdj,_,_,_,_), 
                        distanciaAdjacente(La,Lo,LAdj,[],Lista).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Ajdacentes de um ponto (bidirecional): Ponto, Prox Ponto -> {V,F}

adjacenteBidirecional(Nodo,ProxNodo) :-
    ponto(_,_,Nodo,_,Vizinhos,_,_,_,_),
    membro(ProxNodo,Vizinhos).
adjacenteBidirecional(Nodo,ProxNodo) :-
    ponto(_,_,ProxNodo,_,Vizinhos,_,_,_,_),
    membro(Nodo,Vizinhos).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calculo da distancia entre dois pontos: Ponto, Prox Ponto, Distancia -> {V,F}

calculoDistancia(Nodo,ProxNodo,Res) :- 
    ponto(La,Lo,Nodo,_,_,_,_,_,_),
    ponto(La1,Lo1,ProxNodo,_,_,_,_,_,_),
    pow(La-La1,2,Pot), pow(Lo-Lo1,2,Pot1), Res is sqrt(Pot + Pot1). 

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calculo da distancia entre Ponto e adjacentes: Latitude, Longitude, Lista de adjacencia, Lista inical, Lista com distancias  -> {V,F}

distanciaAdjacente(_,_,[],Res,Res) :- !.
distanciaAdjacente(La,Lo,[X|Y],L,Res) :- 
    ponto(La1,Lo1,X,_,_,_,_,_,_),
    pow(La-La1,2,Pot), pow(Lo-Lo1,2,Pot1), 
    D is sqrt(Pot + Pot1), 
    distanciaAdjacente(La,Lo,Y,[(X,D)|L],Res).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calculo do compriemento de um caminho com idas ao deposito: Caminho, Distancia  -> {V,F}

distanciaTotal([],0).
distanciaTotal([C],0).
distanciaTotal([C,C1|T],Dist) :- 
    distanciaTotal([C1|T],Dist1),
    calculoDistancia(C,C1,Dist0),
    Dist is Dist0 + Dist1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calculo dos elementos que não estrão na lista dos visitados mas estão na lista de adjacencia: Lista Adjacencia, Visitados, Lista Inicial, Lista Resultado -> {V,F}

visitadosMembro([], Visitados, Ls,Ls) :- !.
visitadosMembro([(X,D)|Lista], Visitados, Ls,Res) :- 
    nao(membro(X,Visitados)), 
    visitadosMembro(Lista, Visitados, [X|Ls],Res).
visitadosMembro([(X,D)|Lista], Visitados, Ls, Res) :- 
    membro(X,Visitados), 
    visitadosMembro(Lista, Visitados, Ls,Res).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calculo De heuristica entre um ponto e a garagem: Ponto, Garagem-> {V,F}

heuristica(Id,Res) :- ponto(La,Lo,Id,_,_,_,_,_,_),
        deposito(N), ponto(La1,Lo1,N,_,_,_,_,_,_), 
        pow(La-La1,2,Pot), pow(Lo-Lo1,2,Pot1), 
        Res is sqrt(Pot + Pot1).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Distancia de um ponto na lista de adjacencia: Ponto, Adjacencia -> {V,F}

distanciaPonto(Nodo,[(Nodo,D)|Y],D).
distanciaPonto(Nodo,[(X,D)|Y],Dist) :- distanciaPonto(Nodo,Y,Dist).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Obtem o melhor caminho para a procura gulosa -> {V,F}

obtem_melhor_g([Caminho],Caminho) :- !.
obtem_melhor_g([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
			Est1 =< Est2, !,
			obtem_melhor_g([Caminho1/Custo1/Est1|Caminhos],MelhorCaminho).
obtem_melhor_g([_|Caminhos],MelhorCaminho) :- 
			obtem_melhor_g(Caminhos,MelhorCaminho).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Expande a procura do algoritmo gulosa-> {V,F}

expande_gulosa(Caminho,ExpCaminhos) :- 
    findall(NovoCaminho,adjacenteInformada(Caminho,NovoCaminho), ExpCaminhos).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Obtem o melhor caminho para a procura a estrela -> {V,F}

obtem_melhor_gestrela([Caminho],Caminho) :- !.
obtem_melhor_gestrela([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos],MelhorCaminho) :-
			(Est1+Custo1) =< (Est2+Custo2), !,
			obtem_melhor_gestrela([Caminho1/Custo1/Est1|Caminhos],MelhorCaminho).
obtem_melhor_gestrela([_|Caminhos],MelhorCaminho) :- 
			obtem_melhor_gestrela(Caminhos,MelhorCaminho).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Expande a procura do algoritmo a estrela -> {V,F}

expande_estrela(Caminho,ExpCaminhos) :- 
    findall(NovoCaminho, adjacenteInformada(Caminho,NovoCaminho), ExpCaminhos).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Lista de pontos adjacentes para a pesquisa informada -> {V,F}

adjacenteInformada([Nodo|Caminho]/Custo/_,[ProxNodo,Nodo|Caminho]/NovoCusto/Est) :- 
            adjacente(Nodo,Lista),
            membroLista(ProxNodo,Lista),
            nao(membro(ProxNodo,Caminho)),
            distanciaPonto(ProxNodo,Lista,PassoCusto),
			NovoCusto is Custo + PassoCusto,
			heuristica(ProxNodo,Est). 
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Lista de pontos adjacentes para a pesquisa informada -> bidirecional -> {V,F}

adjacenteInformadaBi([Nodo|Caminho]/Custo/_,[ProxNodo,Nodo|Caminho]/NovoCusto/Est) :- 
            adjacenteBidirecional(Nodo,ProxNodo),
            nao(membro(ProxNodo,Caminho)),
            calculoDistancia(Nodo,ProxNodo,PassoCusto),
			NovoCusto is Custo + PassoCusto,
			heuristica(ProxNodo,Est).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Adiciona a um caminho as várias idas aos depositos necessárias para cumprir com a capacidade. -> {V,F}

adicionaDeposito(Caminho,Novo,Acc) :-
    deposito(N),
    adicionaDepositoAux(Caminho,[N],Novo,Acc).

adicionaDepositoAux([],Novo,Novo,0).
adicionaDepositoAux([Nodo|Caminho],Aux,Novo,AccTotal) :-
    ponto(_,_,Nodo,_,_,_,_,_,T),  
    adicionaDepositoAux(Caminho,Lst,Novo,AccFinal),
    ( AccFinal + T < 15000 -> Lst = [Nodo|Aux], AccTotal is AccFinal + T;
        deposito(N),
     Lst = [N,Nodo|Aux], AccTotal is 0).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Adiciona a um caminho as várias idas aos depositos com seleção de lixo necessárias para cumprir com a capacidade. -> {V,F}

adicionaTipoDeposito(Tipo,Caminho,Novo,Acc) :-
    deposito(N),
    adicionaTipoDepositoAux(Tipo,Caminho,[N],Novo,Acc).

adicionaTipoDepositoAux(Tipo,[],Novo,Novo,0).
adicionaTipoDepositoAux(Tipo, [Nodo|Caminho],Aux,Novo,AccTotal) :-
    ponto(_,_,Nodo,_,_,Select,_,_,T),  
    adicionaDepositoAux(Caminho,Lst,Novo,AccFinal),
    (Select==Tipo -> ( AccFinal + T < 15000 -> Lst = [Nodo|Aux], 
                        AccTotal is AccFinal + T;
                        deposito(N),
                        Lst = [N,Nodo|Aux], AccTotal is 0); 
                    Lst = [Nodo|Aux] ).
     

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Determina o caminho da lista com mais pontos de recolha: Lista, Caminho -> {V,F}

maisPontoRecolha([(S,Lixo,D,C)],(S,Lixo,D,C)) :- !, true.
maisPontoRecolha([(S,Lixo,D,C)|H],(S1,Lixo1,D1,C1)) :- 
    maisPontoRecolha(H,(S1,Lixo1,D1,C1)), 
    C1 >= C.
maisPontoRecolha([(S,Lixo,D,C)|H],(S,Lixo,D,C)) :- 
    maisPontoRecolha(H,(S1,Lixo1,D1,C1)), 
    C > C1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Determina o caminho da lista com mais rapido: Lista, Caminho -> {V,F}

maisRapido([(S,Lixo,D,C)],(S,Lixo,D,C)).
maisRapido([(S,Lixo,D,C)|H],(S1,Lixo1,D1,C1)) :-
    maisRapido(H,(S1,Lixo1,D1,C1)), 
    D1 < D.
maisRapido([(S,Lixo,D,C)|H],(S,Lixo,D,C)) :- 
    maisRapido(H,(S1,Lixo1,D1,C1)), 
    D =< D1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Determina o caminho da lista mais efeciente: Lista, Caminho -> {V,F}

maisEfeciente([(S,Lixo,D,C)],(S,Lixo,D,C)).
maisEfeciente([(S,Lixo,D,C)|H],(S1,Lixo1,D1,C1)) :- 
    maisEfeciente(H,(S1,Lixo1,D1,C1)), 
    efeciencia((S1,Lixo1,D1,C1),(S,Lixo,D,C),E1,E), 
    E1 >= E.
maisEfeciente([(S,Lixo,D,C)|H],(S,Lixo,D,C)) :- 
    maisEfeciente(H,(S1,Lixo1,D1,C1)),  
    efeciencia((S1,Lixo1,D1,C1),(S,Lixo,D,C),E1,E), 
    E > E1.

efeciencia((S,Lixo,D,C),(S1,Lixo1,D1,C1),E,E1) :- E is Lixo/C, E1 is Lixo1/C1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Determina os caminhos segundo a distancia percorrida: Lista, Caminho -> {V,F}

produtividadeDistancia([],Produtividade,Produtividade).
produtividadeDistancia([(S,Lixo,D,C)|H],Res, Produtividade) :- 
    produtividadeDistancia(H, [(S,D)|Res], Produtividade).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Determina os caminhos segundo a lixo recolhido: Lista, Caminho -> {V,F}

produtividadeLixo([],Produtividade,Produtividade).
produtividadeLixo([(S,Lixo,D,C)|H],Res, Produtividade) :- 
    produtividadeLixo(H, [(S,Lixo)|Res], Produtividade).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
%-------------------- Outras Funções -----------------

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Adiciona um ponto ao fim da lista: Ponto, Lista -> {V,F}

adicionarFim(Fim,B,[B|Fim]).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Adiciona um ponto ao incio da lista: Ponto, Lista -> {V,F}

adicionarInicio(Inicio,S1,[Inicio|S1]).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Seleciona um elemento de uma lista  -> {V,F}

seleciona(E,[E|Xs],Xs).
seleciona(E,[X|Xs],[X|Ys]) :- seleciona(E,Xs,Ys).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calcula o percurso com menor custo: Lista, Menor Percurso -> {V,F}

minimo([(P,X)],(P,X)).
minimo([(Px,X)|L],(Py,Y)) :- minimo(L,(Py,Y)), X > Y.
minimo([(Px,X)|L],(Px,X)) :- minimo(L,(Py,Y)),X =< Y.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Determina se um elemento pertence à lista: Elemento, Lista -> {V,F}

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Determina se um elemento pertence à lista de distancias: Elemento, Lista -> {V,F}

membroLista(X, [(X,D)|_]).
membroLista(X, [_|Xs]):- membroLista(X, Xs).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calcula o inveros de uma lista: Lista -> {V,F}

inverso(Xs, Ys) :-
	inverso(Xs, [], Ys).

inverso([], Xs, Xs).
inverso([X|Xs], Ys, Zs) :- inverso(Xs, [X|Ys], Zs).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Meta predicado da negação: Lista -> {V,F}

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Escreve uma lista completa em prolog: Lista -> {V,F}

escrever([]).
escrever([X|L]):- write(X), nl, escrever(L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Copia os elementos de uma lista para outra: Lista1, Lista2 -> {V,F}

copiarArray([],[]).
copiarArray([H|T1],[H|T2]) :- copiarArray(T1,T2).