%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Trabalho Prático Individual - ALGORITMOS

%--------------------- Definições Iniciais --------------
garagem(385).
deposito(1).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo DEPTH FIRST
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Percurso(s) desde de uma fonte até ao destino -> {V,F}

%Percurso desde da garagem até ao deposito
percursoDF(S,Fim,L,D,C) :- garagem(Inicio), 
                            resolveDF(Inicio,Fim,S,L,D,C).

% Todos os Percursos entre a garagem e o deposito
allPercursoDF(Fim,L) :- findall((S,Lixo,D,C),percursoDF(S,Fim,Lixo,D,C),L).

% Todos os Percursos entre uma fonte e um destino
allResolveDF(PInicio,PFim,L) :- findall((S,Lixo,D,C),
                                resolveDF(PInicio,PFim,S,Lixo,D,C),L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algritmo de depth first recursivo -> {V,F}

%--- INICIALIZAÇÃO ----%
resolveDF(PInicio,PFim,Percurso,Lixo,DTotal,Custo) :- 
                                caminhoDF(PInicio,PFim,[PInicio],SFinal,Lixo1,DFinal),
                                ponto(_,_,PInicio,_,_,_,_,_,L),
                                Lixo is L + Lixo1,
                                inverso([PInicio|SFinal],Caminho),
                                adicionaDeposito(Caminho,Percurso,Acc),
                                distanciaTotal(Percurso,DTotal),
                                length(Percurso,Custo).

%--- PESQUISA ----%

% Caso de paragem:
caminhoDF(Estado,Fim,_,[],0,0) :- Estado == Fim, !.
% Caso Recursivo:
caminhoDF(Estado,Fim,Historico,[P|Solucao],LixoTotal,CustoTotal) :- 
    adjacente(Estado,Lista),
    membroLista(P,Lista),
    nao(membro(P,Historico)),
    ponto(_,_,P,_,_,_,_,_,T),
    distanciaPonto(P,Lista,D),
    caminhoDF(P,Fim,[P|Historico],Solucao,LixoFinal,CustoFinal),
    LixoTotal is LixoFinal + T,
    CustoTotal is CustoFinal + D.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo BREADTH FIRST
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Percurso(s) entre uma fonte e um destino: Percurso, Lixo, Distancia, Custo -> {V,F}

%Percurso entre uma garagem e um deposito
percursoBF(S,Fim,Lixo,D,C) :- garagem(Inicio),
                    resolveBF(Inicio,Fim,S,Lixo,D,C).

% Todos os Percursos entre a garagem e o deposito
allPercursoBF(Fim,L) :- findall((S,Lixo,D,C),percursoBF(S,Fim,Lixo,D,C),L).

% Todos os Percursos entre a garagem e o deposito
allResolveBF(Inicial,Final,L) :- findall((S,Lixo,D,C),resolveBF(Inicial,Final,S,Lixo,D,C),L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo de Breadth first recursivo -> {V,F}

%--- INICIALIZAÇÃO ----%
resolveBF(Inicial, Fim, Percurso,Lixo,DTotal,C) :- caminhoBF(Fim, [[Inicial]], Solucao,Lixo1,D),
                                    ponto(_,_,Inicial,_,_,_,_,_,LixoAtual), 
                                    Lixo is Lixo1 + LixoAtual,
                                    inverso(Solucao,Caminho),
                                    adicionaDeposito(Caminho,Percurso,Acc),
                                    distanciaTotal(Percurso,DTotal),
                                    length(Percurso,C).


%--- PESQUISA ----%

%Caso de Paragem: Quando o caminho chega ao fim 
caminhoBF(Fim, [[Fim| Visitados] | _ ], Caminho,0,0) :- 
    inverso([Fim| Visitados],Caminho).
%Caso de Recursivo:
caminhoBF(Fim, [Visitados|Resto], Solucao,LixoTotal,DistanciaTotal) :-
    Visitados = [Inicio|_],
    Inicio \== Fim,
    adjacente(Inicio, Lista),
    visitadosMembro(Lista, Visitados,[],[T|Extensao]),
    ponto(_,_,T,_,_,_,_,_,LixoAtual),
    distanciaPonto(T,Lista,DistanciaAtual),
    maplist(adicionarFim(Visitados), [T|Extensao], ExtensaoVst),
    append(Resto,ExtensaoVst, AtualizaFila),
    caminhoBF(Fim, AtualizaFila,Solucao,LixoFinal,DistanciaFinal),
    LixoTotal is LixoFinal + LixoAtual,
    DistanciaTotal is DistanciaFinal + DistanciaAtual.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo Limitado DEPTH FIRST
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Percurso(s) entre uma fonte e um destino -> {V,F}

% Percurso desde da garagem até ao deposito
percursoDFLimitado(S,Fim,Lixo,Dist,C,Limite) :- garagem(Inicio), 
                                            resolveDFLimitado(Inicio,Fim,S,Lixo,Dist,C,Limite).

% Todos os Percursos entre a garagem e o deposito
allPercursoDFLimitado(Fim,Limite,L) :- findall((S,Lixo,Dist,C),percursoDFLimitado(S,Fim,Lixo,Dist,C,Limite),L).

% Todos os Percursos entre uma fonte e um destino
allResolveDFLimitado(PInicio,PFim,Limite,L) :- findall((S,Lixo,Dist,C),
                                            resolveDFLimitado(PInicio,PFim,S,Lixo,Dist,C,Limite),L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algritmo de depth first limitado recursivo -> {V,F}

%--- INICIALIZAÇÃO ----%
resolveDFLimitado(PInicio,PFim,Percurso,Lixo,DTotal,C,Limite) :- 
        caminhoDFLimitado(PInicio,PFim,[PInicio],S1,Lixo1,Dist,Limite),
        adicionarInicio(PInicio,S1,S),
        ponto(_,_,PInicio,_,_,_,_,_,LixoAtual),
        inverso(S,Caminho),
        adicionaDeposito(Caminho,Percurso,Acc),
        distanciaTotal(Percurso,DTotal),
        length(Percurso,C), 
        Lixo is Lixo1 + LixoAtual.

%--- PESQUISA ----%

% Caso de paragem:
caminhoDFLimitado(Estado,Fim,_,[],0,0,_) :- Estado == Fim, !.
% Caso Recursivo:
caminhoDFLimitado(Estado,Fim,Historico,[P|Solucao],LixoTotal,DistTotal,Limite) :- 
    Limite > 1,
    adjacente(Estado,Lista),
    membroLista(P,Lista),
    nao(membro(P,Historico)),
    ponto(_,_,P,_,_,_,_,_,T),
    distanciaPonto(P,Lista,D),
	caminhoDFLimitado(P,Fim,[P|Historico],Solucao, LixoFinal,DistFinal,Limite-1),
    LixoTotal is LixoFinal + T,
    DistTotal is DistFinal + D.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo GULOSA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Percurso(s) desde da garagem até ao deposito -> {V,F}

% Percurso entre um inicio e a garagem
percursoGulosa(Fim,Caminho,Custo) :- garagem(Inicio),
                                    resolveGulosa(Inicio,Fim,Caminho,Custo).

% Todos os Percursos entre da garagem até ao deposito
allPercursoGulosa(Fim,L) :- findall((S,C),percursoGulosa(Fim,S,C),L).

% Todos os Percursos entre uma fonte e um destino
allResolveGulosa(Fim,Inicio,L) :- findall((S,C),resolveGulosa(Inicio,Fim,S,C),L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo GulosO recursivo  -> {V,F}

%--- INICIALIZAÇÃO ----%
resolveGulosa(Inicio,Fim,Percurso,CustoTotal) :- heuristica(Inicio,Estima),
					caminhoGulosa(Fim,[[Inicio]/0/Estima],InvCaminho/Custo/_),
                    adicionaDeposito(InvCaminho,Percurso,Acc),
                    distanciaTotal(Percurso,CustoTotal).

%--- PESQUISA ----%

%Caso de Paragem
caminhoGulosa(Fim,Caminhos,Caminho) :- obtem_melhor_g(Caminhos,Caminho),
								        Caminho = [Fim|_]/_/_.
%Caso de Recursividade
caminhoGulosa(Fim,Caminhos,SolucaoCaminho) :- obtem_melhor_g(Caminhos,MelhorCaminho), 
									seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
									expande_gulosa(MelhorCaminho,ExpCaminhos),
									append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
									    caminhoGulosa(Fim,NovoCaminhos,SolucaoCaminho).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo A ESTRELA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
%  Percurso(s) desde de um inicio até ao deposito -> {V,F}

%Percurso desde da garagem até ao deposito
percursoAEstrela(Fim, Caminho,Custo) :- garagem(Inicio),
                                    resolveAEstrela(Inicio,Fim,Caminho,Custo).

% Todos os Percursos entre da garagem até ao deposito
allPercursoAEstrela(Fim,L) :- findall((S,C),percursoAEstrela(Fim,S,C),L).

% Todos os Percursos entre um incio até ao deposito
allPercursoAEstrela(Inicio,Fim,L) :- findall((S,C),resolveAEstrela(Inicio,Fim,S,C),L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Algoritmo AEstrela recursivo -> {V,F}

%--- INICIALIZAÇÃO ----%
resolveAEstrela(Inicio,Fim,Percurso,CustoTotal) :- heuristica(Inicio,Estima),
					caminhoAestrela(Fim,[[Inicio]/0/Estima],InvCaminho/Custo/_),
                    adicionaDeposito(InvCaminho,Percurso,Acc),
                    distanciaTotal(Percurso,CustoTotal).

%--- PESQUISA ----%

%Caso de paragem
caminhoAestrela(Fim,Caminhos, Caminho) :- obtem_melhor_gestrela(Caminhos,Caminho),
								Caminho = [Fim|_]/_/_.
%Caso recursivo
caminhoAestrela(Fim,Caminhos, SolucaoCaminho) :- obtem_melhor_gestrela(Caminhos,MelhorCaminho), 
									seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
									expande_estrela(MelhorCaminho,ExpCaminhos),
									append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
									caminhoAestrela(Fim,NovoCaminhos,SolucaoCaminho). 

%--------------------- EXTRA - ESTATISTICAS -----------------

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Estatiscas de tempo de execução e memória utilizada para o algoritmo de Breadth First. 

statisticsBF(Inicio,Fim,L,Lixo,D,C,Mem) :-
    statistics(global_stack, [Use1,Free1]),
    time(resolveBF(Inicio,Fim,L,Lixo,D,C)),
    statistics(global_stack, [Use2,Free2]),
    Mem is Use2 - Use1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Estatiscas de tempo de execução e memória utilizada para o algoritmo de Depth First. 

statisticsDF(Inicio,Fim,L,Lixo,D,C,Mem) :-
    statistics(global_stack, [Use1,Free1]),
    time(resolveDF(Inicio,Fim,L,Lixo,D,C)),
    statistics(global_stack, [Use2,Free2]),
    Mem is Use2 - Use1.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Estatiscas de tempo de execução e memória utilizada para o algoritmo de Depth First Limitado. 

statisticsDFLimitado(PInicio,PFim,Percurso,Lixo,DTotal,C,Limite,Mem) :-
    statistics(global_stack, [Use1,Free1]),
    time(resolveDFLimitado(PInicio,PFim,Percurso,Lixo,DTotal,C,Limite)),
    statistics(global_stack, [Use2,Free2]),
    Mem is Use2 - Use1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Estatiscas de tempo de execução e memória utilizada para o algoritmo de Pesquisa Gulosa 

statisticsGulosa(Inicio,Fim,Percurso,CustoTotal,Mem) :-
    statistics(global_stack, [Use1,Free1]),
    time(resolveGulosa(Inicio,Fim,Percurso,CustoTotal)),
    statistics(global_stack, [Use2,Free2]),
    Mem is Use2 - Use1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Estatiscas de tempo de execução e memória utilizada para o algoritmo de Pesquisa A*

statisticsAEstrela(Inicio,Fim,Percurso,CustoTotal, Mem) :-
    statistics(global_stack, [Use1,Free1]),
    time(resolveAEstrela(Inicio,Fim,Percurso,CustoTotal)),
    statistics(global_stack, [Use2,Free2]),
    Mem is Use2 - Use1.
    