clear variables;
close all;
clc;

% Lecture de l'image
im = im2double(imread('images/photo1.jpg'));

% Nuance de gris
im = rgb2gray(im);

im = rot90(im, 3);

im = max(im(:)) - im;
im2 = edge(im, 'canny');
% Top-hat
SE = strel('disk',15);
im = imtophat(im, SE);

im = imadjust(im);

% Seuillage
bw = (im > 0.25);

% Transformee de Hough
[H,T,R] = hough(bw, 'Theta', -90:0.1:89, 'RhoResolution', 1);

P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');

figure(2);
lines = houghlines(bw,T,R,P,'FillGap',1000,'MinLength',100);
figure, imshow(im), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end


angle = mean(P(:, 2));
% imRotate = rotate(bw, -angle);


% % Ouverture
% SE = [0, 1, 0
%       1, 1, 1
%       0, 1, 0]
% bw = imopen(bw, SE);

% Affichage
figure(1);
subplot(121);
imshow(im, []);

subplot(122);
imshow(bw, []);

imwrite(bw,'image_tres_jolie.jpg','jpg','Quality',100);

figure(5);
imshow(rotate(bw, -angle), [])