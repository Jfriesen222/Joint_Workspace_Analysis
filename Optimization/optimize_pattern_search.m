
clc
clear variables
close all
j = 0;
lb = [0.03, 0.15 ,0.01];
ub = [0.17, 0.6, 0.10];
x0 = (lb+ub)/2;
% [X,Y,Z] = meshgrid(lb(1):0.005:ub(1),lb(2):0.005:ub(2),0.8827);%lb(3):0.01:ub(3));
% X = X(:);
% Y = Y(:);
% Z = Z(:);
% vals = zeros(1, length(X));
% length(X)
% for i = 1:length(X)
%     tic
%     vals(i) = getNumConfig([X(i) Y(i) Z(i)]);
%     disp(i)
%     toc
% end
    
%% Start with the default options
options = psoptimset;
%% Modify options setting
options = psoptimset(options,'Display', 'iter');
options = psoptimset(options,'PlotFcns', {  @psplotbestf @psplotfuncount @psplotbestx });
options = psoptimset(options,'Vectorized', 'off');
options = psoptimset(options,'CompletePoll', 'on');
options = psoptimset(options,'UseParallel', 0 );
[x,fval,exitflag,output] = ...
patternsearch(@getNumConfig,x0,[],[],[],[],lb,ub,[],options);
