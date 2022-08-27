function I=Loadimage(path)
     I = imread(path);
    if size(I, 3) == 3
        I = rgb2gray(I);
    end
end