%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Trabalho Prático Individual - MAIN

%--------------------- Definições Inicais --------------

:- use_module(library(csv)).
:- set_prolog_flag(answer_write_options, [max_depth(0)]).
:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- style_check(-singleton).


:- include('Algoritmos.pl').
:- include('RegrasAuxiliares.pl').
:- include('Funcionalidades.pl').

% load folder : working_directory(_,'c:/users/ana luísa carneiro/desktop/uminho/2 semestre 3º ano/srcr/tp-individual')

%---------------------  Leitura do ficheiro CSV --------------

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Descarrega o ficheiro csv como base de conhecimento -> {V,F}

load(Data) :- csv_read_file('Dataset.csv', Data, [functor(recolha), arity(9), separator(0';)]), %'
                            defineTerms(Data). 

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Cria os vários predicados inserindos na base de conhecimento -> {V,F}

defineTerms([recolha(A,B,C,D,E,F,G,H,I)]) :- assert(ponto(A,B,C,D,[],F,G,H,I)), !.
defineTerms([recolha(A,B,C,D,E,F,G,H,I)|X]) :- atom(E), split_string(E, "/"," ", L), 
                                                fromStringToInt(L,Q,R), 
                                                assert(ponto(A,B,C,D,[Q,R],F,G,H,I)), defineTerms(X).
defineTerms([recolha(A,B,C,D,E,F,G,H,I)|X]) :- integer(E), 
                                                assert(ponto(A,B,C,D,[E],F,G,H,I)), 
                                                defineTerms(X).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Transforma uma lista de strings para inteiros -> {V,F}

fromStringToInt([Y],A,B) :- atom_number(Y,B).
fromStringToInt([X|Y],A,B) :- atom_number(X,A), fromStringToInt(Y,A,B).