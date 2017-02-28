clear variables
close all
clc
pause
%% This is an auto generated MATLAB file from Optimization Tool.
nvars = 3;
lb = [0.04, 0.165 ,0.5];
ub = [0.15, 0.5, 0.99];
%% Start with the default options
options = gaoptimset;
%% Modify options setting
options = gaoptimset(options,'Display', 'iter');
options = gaoptimset(options,'PlotFcns', {  @gaplotbestf @gaplotbestindiv @gaplotrange @gaplotscorediversity });
options = gaoptimset(options,'Vectorized', 'off');
options = gaoptimset(options,'UseParallel', 1 );
[x,fval,exitflag,output,population,score] = ...
ga(@getNumConfig,nvars,[],[],[],[],lb,ub,[],[],options);
