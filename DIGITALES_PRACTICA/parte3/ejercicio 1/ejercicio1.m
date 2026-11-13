clear all; close all; clc; 

Nfft = 512; 
fs = 62.5e3; 
Nstage    = log2(Nfft);          % 9 etapas
Bin       = 12;  % bits de la entrada

Nframes   = 20;                  % 1 trama de tonos + 19 de ruido

tones= [2e6 5e6 9e6 12e6];
amplitude= 0.5;
[t, finput]= genInput (amplitude, tones, Nfft, fs);



