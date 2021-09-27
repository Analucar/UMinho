%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Trabalho Prático Individual - Funcionalidades

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Circuitos de Recolha Indiferenciada
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% ----------- DEPTH FIRST com seleção de lixo-----------%
percursoTipoDF(Fim,Tipo,S,L,D,C) :- 
    garagem(Inicio), 
    resolveTipoDF(Tipo,Inicio,Fim,S,L,D,C).

allPercursoTipoDF(Fim,Tipo,L) :- findall((S,Lixo,D,C),percursoTipoDF(Fim,Tipo,S,Lixo,D,C),L).

resolveTipoDF(Tipo,PInicio,PFim,Percurso,Lixo,D,C) :- 
    caminhoTipoDF(Tipo,PInicio,PFim,[PInicio],SFinal,Lixo1,D,C1), 
    ponto(_,_,PInicio,_,_,Select,_,_,L),
    ( Select==Tipo -> Lixo is L + Lixo1, C is C1+1 ; Lixo is Lixo1, C is C1),
    inverso([PInicio|SFinal],Caminho),
    adicionaTipoDeposito(Tipo,Caminho,Percurso,Acc),
    distanciaTotal(Percurso,DTotal).                        

caminhoTipoDF(_,Estado,Fim,_,[],0,0,0) :- Estado == Fim, !.
caminhoTipoDF(Select,Estado,Fim,Historico,[P|Solucao],LixoTotal,CustoTotal, PontosTotal) :- 
    adjacente(Estado,Lista),
    membroLista(P,Lista),
    nao(membro(P,Historico)),
    ponto(_,_,P,_,_,Tipo,_,_,T),
    distanciaPonto(P,Lista,D),
	caminhoTipoDF(Select,P,Fim,[P|Historico],Solucao, LixoFinal, CustoFinal, PontosFinal),
    (Select==Tipo -> LixoTotal is LixoFinal + T, 
                    PontosTotal is PontosFinal+1; 
                LixoTotal is LixoFinal, PontosTotal is PontosFinal ),
    CustoTotal is CustoFinal + D. 

% ----------- BREADTH FIRST com seleção de lixo----------- %

percursoTipoBF(Tipo,S,Fim,Lixo,D,C) :- garagem(Inicio),
                    resolveTipoBF(Tipo,Inicio,Fim,S,Lixo,D,C).

allPercursoTipoBF(Fim,Tipo,L) :- findall((S,Lixo,D,C),percursoTipoBF(Tipo,S,Fim,Lixo,D,C),L).

resolveTipoBF(Tipo,Inicial, Fim, Percurso,Lixo,D,C) :- 
            caminhoTipoBF(Tipo,Fim, [[Inicial]], Solucao,Lixo1,D,C1),
            ponto(_,_,Inicial,_,_,Select,_,_,LixoAtual), 
            (Select==Tipo -> LixoTotal is LixoFinal + T, C is C1+1; LixoTotal is LixoFinal, C is C1 ),
            inverso(Solucao,Caminho),
            adicionaTipoDeposito(Tipo,Caminho,Percurso,Acc),
            distanciaTotal(Percurso,DTotal).

caminhoTipoBF(Tipo,Fim, [[Fim| Visitados] | _ ], Caminho,0,0,0) :- 
    inverso([Fim| Visitados],Caminho).
caminhoTipoBF(Tipo,Fim, [Visitados|Resto], Solucao,LixoTotal,DistanciaTotal,PontosTotal) :-
    Visitados = [Inicio|_],
    Inicio \== Fim,
    adjacente(Inicio, Lista),
    visitadosMembro(Lista, Visitados,[],[T|Extensao]),
    ponto(_,_,T,_,_,Select,_,_,LixoAtual),
    distanciaPonto(T,Lista,DistanciaAtual),
    maplist(adicionarFim(Visitados), [T|Extensao], ExtensaoVst),
    append(Resto,ExtensaoVst, AtualizaFila),
    caminhoTipoBF(Tipo,Fim, AtualizaFila,Solucao,LixoFinal,DistanciaFinal, PontosFinal),
    (Select==Tipo -> LixoTotal is LixoFinal + T,
                     PontosTotal is PontosFinal +1; 
                LixoTotal is LixoFinal, PontosTotal is PontosFinal ),
    DistanciaTotal is DistanciaFinal + DistanciaAtual.

% ----------- DEPTH FIRST LIMITADO com seleção de lixo-----------%

percursoTipoDFLimitado(Tipo,S,Fim,Lixo,Dist,C,Limite) :- garagem(Inicio), 
                                            resolveTipoDFLimitado(Tipo,Inicio,Fim,S,Lixo,Dist,C,Limite).

allPercursoTipoDFLimitado(Tipo,Fim,Limite,L) :- findall((S,Lixo,Dist,C),percursoTipoDFLimitado(Tipo,S,Fim,Lixo,Dist,C,Limite),L).

resolveTipoDFLimitado(Tipo,PInicio,PFim,Percurso,Lixo,DTotal,C,Limite) :- 
        caminhoTipoDFLimitado(Tipo,PInicio,PFim,[PInicio],S1,Lixo1,Dist,C1, Limite),
        adicionarInicio(PInicio,S1,S),
        ponto(_,_,PInicio,_,_,Select,_,_,LixoAtual),
        inverso(S,Caminho),
        adicionaTipoDeposito(Tipo,Caminho,Percurso,Acc),
        distanciaTotal(Percurso,DTotal),
        (Select==Tipo -> LixoTotal is LixoFinal + LixoAtual, 
                            C is C1 +1; LixoTotal is LixoFinal, C is C1 ).

caminhoTipoDFLimitado(Tipo,Estado,Fim,_,[],0,0,0,_) :- Estado == Fim, !.
caminhoTipoDFLimitado(Tipo,Estado,Fim,Historico,[P|Solucao],LixoTotal,DistTotal,PontosTotal, Limite) :- 
    Limite > 1,
    adjacente(Estado,Lista),
    membroLista(P,Lista),
    nao(membro(P,Historico)),
    ponto(_,_,P,_,_,Select,_,_,T),
    distanciaPonto(P,Lista,D),
	caminhoTipoDFLimitado(Tipo,P,Fim,[P|Historico],Solucao, LixoFinal,DistFinal,PontosFinal,Limite-1),
    (Select==Tipo -> LixoTotal is LixoFinal + T, 
                        PontosTotal is PontosFinal +1; 
                    LixoTotal is LixoFinal, PontosTotal is PontosFinal ),
    DistTotal is DistFinal + D.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Circuitos com mais pontos de recolha
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Caminho com mais ponto de recolha com selecao de lixo apartir do algoritmo Depth First
maisPontoTipoRecolhaDF(Fim,Lixo,Recolha) :- 
                        allPercursoTipoDF(Fim,Lixo,L),
                        maisPontoRecolha(L,Recolha).

% Caminho com mais ponto de recolha com selecao de lixo apartir do algoritmo Breadth First
maisPontoTipoRecolhaBF(Fim,Lixo,Recolha) :- 
                        allPercursoTipoBF(Fim,Lixo,L),
                        maisPontoRecolha(L,Recolha).

% Caminho com mais ponto de recolha com selecao de lixo apartir do algoritmo Depth First Limitado
maisPontoTipoRecolhaDFLimitado(Fim,Lixo,Limite,Recolha) :- 
                        allPercursoTipoDFLimitado(Lixo,Fim,Limite,L),
                        maisPontoRecolha(L,Recolha).

% Caminho com mais ponto de recolha apartir do algoritmo Depth First
maisPontoRecolhaDF(Fim,Recolha) :- allPercursoDF(Fim,L),
                        maisPontoRecolha(L,Recolha).

% Caminho com mais ponto de recolha apartir do algoritmo Breadth First
maisPontoRecolhaBF(Fim,Recolha) :- allPercursoBF(Fim,L),
                        maisPontoRecolha(L,Recolha).

% Caminho com mais ponto de recolha apartir do algoritmo Depth First Limitado
maisPontoRecolhaDFLimitado(Fim,Limite,Recolha) :- 
                        allPercursoDFLimitado(Fim,Limite,L),
                        maisPontoRecolha(L,Recolha).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Circuitos com Indicadores de produtividade : Quantidade Recolhida
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

produtividadeLixoDF(Fim,Produtividade) :- allPercursoDF(Fim,L),
                        produtividadeLixo(L,[],Produtividade).

produtividadeLixoBF(Fim,Produtividade) :- allPercursoBF(Fim,L),
                        produtividadeLixo(L,[],Produtividade).

produtividadeLixoDFLimitado(Fim,Limite,Produtividade) :- 
                        allPercursoDFLimitado(Fim,Limite,L),
                        produtividadeLixo(L,[],Produtividade).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Circuitos com Indicadores de produtividade : Distancia Media percorrida
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

produtividadeDistanciaDF(Fim,Produtividade) :- allPercursoDF(Fim,L),
                        produtividadeDistancia(L,[],Produtividade).

produtividadeDistanciaBF(Fim,Produtividade) :- allPercursoBF(Fim,L),
                        produtividadeDistancia(L,[],Produtividade).

produtividadeDistanciaDFLimitado(Fim,Limite,Produtividade) :- 
                        allPercursoDFLimitado(Fim,Limite,L),
                        produtividadeDistancia(L,[],Produtividade).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Circuito mais rápido
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

maisRapidoDF(Fim,Rapido) :- allPercursoDF(Fim,L),
                        maisRapido(L,Rapido).

maisRapidoBF(Fim,Rapido) :- allPercursoBF(Fim,L),
                        maisRapido(L,Rapido).

maisRapidoDFLimitado(Fim,Limite,Rapido) :- 
                        allPercursoDFLimitado(Fim,Limite,L),
                        maisRapido(L,Rapido).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Circuito mais efeciente : ESCOLHA
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Efeciencia: O que apanhou mais lixo no menor caminho possivel 
%             lixo/pontos de recolha

maisEfecienteDF(Fim,Efeciencia) :- allPercursoDF(Fim,L),
                        maisEfeciente(L,Efeciencia).

maisEfecienteBF(Fim,Efeciencia) :- allPercursoBF(Fim,L),
                        maisEfeciente(L,Efeciencia).

maisEfecienteDFLimitado(Fim,Limite,Efeciencia) :- 
                        allPercursoDFLimitado(Fim,Limite,L),
                        maisEfeciente(L,Efeciencia).