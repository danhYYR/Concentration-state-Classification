%% Prepare
close all;clc;clear all;
run('..\..\Function\load_function.m')
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
path_file='C:\Users\LAPTOP\My Drive\EEG\Result\Attention\Data';
path_folder=uigetdir(path_file,'Choose folder to encoding');
%%
% encodding(path_folder,'Folder');
%%
encodding(path_folder,'File');
