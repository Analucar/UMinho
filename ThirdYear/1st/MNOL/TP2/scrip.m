% Reolução


%options = optimset('ObjectiveLimit',-5e200, 'MaxFunEvals',2.000000e+010)
%[xmin,fmin,exitflag,output]=fminunc('profit',[2 1])

[xmin,fmin,exitflag,output]=fminsearch('profit',[0 0]);

%[xmin,fmin,exitflag,output]=fminsearch('box',[0 0]);
options = optimset('ObjectiveLimit',-5e500, 'MaxFunEvals',2.000000e+010 );
[xmin,fmin,exitflag,output]=fminunc('profit',[0 0], options);

%RESOLUÇÃO COM PEPINOS

a = [2 3 4];
% options = optimset('MaxFunEvals', 3000000, 'MaxIter', 3000000)
%[xmin,fmin,exitflag,output]=fminunc('profit',[0 -1 0],[],a)

%[xmin,fmin,exitflag,output]=fminunc('profit',[1 2 1],[],a)
options = optimset('MaxFunEvals', 300000, 'MaxIter', 300000,'HessUpdate','dfp');
[xmin,fmin,exitflag,output]= fminunc('profit',[0 2 1] ,[],a);
[xmin,fmin,exitflag,output]= fminunc('profit',[0 2 1] ,options,a);

%[xmin,fmin,exitflag,output]=fminunc('profit',[1 2 3],[],a)
%[xmin,fmin,exitflag,output]=fminunc('profit',[3 1 2],[],a) - %NAO DA
%[xmin,fmin,exitflag,output]=fminunc('profit',[1 0 1],[],a) - % NAO DA


%[xmin,fmin,exitflag,output]=fminsearch('profit',[0 -1 0],[],a)

%[xmin,fmin,exitflag,output]=fminsearch('profit',[1 2 1],[],a)
%[xmin,fmin,exitflag,output]=fminsearch('profit',[0 2 1],[],a)
%[xmin,fmin,exitflag,output]=fminsearch('profit',[1 2 3],[],a)
%[xmin,fmin,exitflag,output]=fminsearch('profit',[3 1 2],[],a)
%[xmin,fmin,exitflag,output]=fminsearch('profit',[1 0 1],[],a) % NAO DA

%optimset fminsearch
% options = optimset('HessUpdate',');

options = optimset('HessUpdate','dfp');

fsurf('profit',[-100 100]);

fmesh(@(x,a)profit(x,a));


t=-2:0.01:2;
plot3(cos(2*pi*t),sin(2*pi*t),t)