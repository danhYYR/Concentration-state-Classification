function decomp_signal=get_waveletdata(x,Fs,f,name)
if ~isvector(f)
    f=[0 f];
end
level_min=ceil(log2(Fs/max(f)));
level_max= ceil(log2(Fs/min(f)));
f_range={[Fs/2^level_min Fs/2^(level_min-1)];[Fs/2^level_max Fs/2^level_min]};
assignin('base','f_range',f_range)
if isempty(name)
    name='coif3';
end
decomp_signal=wavelet_analyze(x,level_min,level_max,name);
end