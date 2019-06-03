function main


    clear all; close all; clc;

    %% Récupération de l'image
    %Lecture
    im = im2double(imread('ode_a_la_joie.jpg'));

    im = im2bw(im, 0.9);
    [m, n] = size(im);
    
    % Affichage
    figure(1);
    imshow(im);
    
    im = 1 - im;
    %% Détection des portées
    % Masque
    M = ones(1, 55);

    % Dilatation
    lignes = imerode(im, M);

    % Suppréssion des doubles pixels sur les lignes 
    lignesSuppr = imerode(lignes, [1, 1 ; 1, 1]);
    l = imdilate(lignesSuppr, [1,1;1,1]);
    lignes = lignes -l + lignesSuppr;

    %Reconstruction géodésique
    lignes = imdilate(lignes, M);
    reconstruction = lignes;

    figure;
    imshow(reconstruction);
    title('Portées');


    %% Récupération des noires
    R = 4;
    SE = strel('disk', R);

    noires = imerode(im, SE);

    figure;
    imshow(noires);
    title('noires multipoints')

    noiresDilate = imdilate(noires, SE);
    reconstruction = reconstruction + noiresDilate;

    figure;
    imshow(reconstruction);
    title('Portées + Noires');
    
    visites = zeros(m, n);
    
    for i=1:m
        for j=1:n
            if(noires(i, j) == 1)
                [noires, visites] = erase_neighbours(noires, visites, i, j, 'k');
            end
        end
    end
    
    
    figure;
    imshow(noires);
    title('centres noires')
    


    %% Barres des noires
    M = ones(25, 1);

    barres = imerode(im, M);
    barres = imdilate(barres, M);
    reconstruction = reconstruction + barres;

    figure(4);
    imshow(reconstruction);
    title('Portées + Noires + barres');

    %% Coordonnées des lignes

    X = lignes(:, floor(m/2));
    Coords = find(X);

    Coords = reshape(Coords, 5, []);
    [q,p] = size(Coords);
    pas = mean((Coords(2:end, 1) - Coords (1:end-1, 1)) / 2);

    C = zeros(10, p); % Ré à fa, on rajoute la sol après
    for i=1:5
        for j=1:p
            C(i*2 - 1, j) = Coords(i, j);
            C(i*2, j) = Coords(i, j) + pas;
        end
    end
    C = [Coords(1, :) - pas; C];
    
    Coords = C
    
    
    
    
    %% Localisation des noires sur la portée
    [x, y] = size(Coords);
    for a = 1:y
        Portee = noires(Coords(1, a) - 10 : Coords(end, a) + 10, 1:end);
        ecart = Coords(1, 1) - 10;

        figure;
        imshow(Portee);
        [p, q] = size(Portee);
        Pos = [;];
        for j = 1: q
            for i = 1:p
                if (Portee(i, j) == 1)
                    Pos = [Pos, [i+ecart;j]];
                end
            end
        end


        [p, q] = size(Pos);
        for i=1:q
            [nom, octave] = note(Coords(:, 1), Pos(1, i));
            disp(nom);
            disp(octave);
            generate_sound(nom, octave);

        end
    end
end



%% functions


%TODO : conditions aux bords
function [M, V] = erase_neighbours(M, V, i, j, action)
    V(i,j) = 1;
    if (action == 'e')
        M(i, j) = 0;
    end
    
    if ((M(i+1, j) == 1) && (V(i+1, j) == 0))
        [M, V] = erase_neighbours(M, V, i + 1, j, 'e');
    end
    
    if ((M(i+1, j+1) == 1) && (V(i+1, j+1) == 0))
        [M, V] = erase_neighbours(M, V, i+1, j+1, 'e');
    end
    
    if ((M(i, j+1) == 1) && (V(i, j+1) == 0))
        [M, V] = erase_neighbours(M, V, i, j+1, 'e');
    end
    
    if ((M(i-1, j+1) == 1) && (V(i-1, j+1) == 0))
        [M, V] = erase_neighbours(M, V, i - 1, j+1, 'e');
    end
    
    if ((M(i-1, j) == 1) && (V(i-1, j) == 0))
        [M, V] = erase_neighbours(M, V, i - 1, j, 'e');
    end
    if ((M(i-1, j-1) == 1) && (V(i-1, j-1) == 0))
        [M, V] = erase_neighbours(M, V, i - 1, j-1, 'e');
    end
    
    if ((M(i, j-1) == 1) && (V(i, j-1) == 0))
        [M, V] = erase_neighbours(M, V, i, j-1, 'e');
    end
    
    if ((M(i+1, j-1) == 1) && (V(i+1, j-1) == 0))
        [M, V] = erase_neighbours(M, V, i + 1, j-1, 'e');
    end
end


function [nom, octave] = note(Coords, y)
    dist = abs(Coords - y);
    [p, i] = min(dist);
    switch i
        case 1
            nom = "sol";
            octave = 4;
        case 2
            nom = "fa";
            octave = 4;
        case 3
            nom = "mi";
            octave = 4;
        case 4
            nom = "re";
            octave = 4;
        case 5
            nom = "do";
            octave = 4;
        case 6
            nom = "si";
            octave = 3;
        case 7
            nom = "la";
            octave = 3;
        case 8
            nom = "sol";
            octave = 3;
        case 9
            nom = "fa";
            octave = 3;
        case 10
            nom = "mi";
            octave = 3;
        case 11
            nom = "re";
            octave = 3;
    end
           
end




function generate_sound(note, octave)
    
    freq = parse(note, octave);

    amp=0.1;
    fs=20500;  % sampling frequency
    duration=0.3;
    values=0:1/fs:duration;
    a=amp*(2*(sin(2*pi*freq*values) > 0) - 1);
    sound(a, fs);
    pause(duration);
end
    

function freq = parse(note, octave)
    freq = 110;
    switch note
        case 'do'
            freq = 65.41  ;
        case 're'
            freq = 73.42;
        case 'mi'
            freq = 82.41;
        case 'fa'
            freq = 87.31;
        case 'sol'
            freq = 98;
        case 'la'
            freq = 110;
        case 'si'
            freq = 123.47;
    end
    freq = freq * 2^(octave-3);

end
