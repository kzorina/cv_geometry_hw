initial = imread('pokemon_00.jpg');
to_fill = imread('pokemon_05.jpg');
to_fill_gray = rgb2gray(to_fill); 

meanIntensity = mean(to_fill(:));
meanIntensity_initial = mean(initial(:));

ims = {to_fill, initial};

% Pick correspondence points
e = [];
u1 = []; u2 = []; 
[u,e] = edit_points( ims, { u1, u2 }, e );
u1 = u{1}; u2 = u{2};

% Calculate and save best homography
u1 = cat(1, u1, ones(1,size(u1, 2)));
u2 = cat(1, u2, ones(1,size(u2, 2)));

[h_best, points] = u2h_optim(u1, u2);
save( '05_homography.mat', 'h_best', 'u1', 'u2', 'points', '-v6' )





% find both black region and bounding box
stats = [regionprops(bw); regionprops(not(bw))];
[~,index] = sortrows([stats.Area].'); 
stats = stats(index(end:-1:1)); clear index
x = round(stats(2).BoundingBox(1));
delta_x = round(stats(2).BoundingBox(3));
y = round(stats(2).BoundingBox(2));
delta_y = round(stats(2).BoundingBox(4));


% Calculate coordinates of region in second image
u = ones(delta_x*delta_y,3);
u0 = ones(delta_x*delta_y,2);
count = 1;
for i=x:x+delta_x
    for j = y:y+delta_y
        u(count,:) = [i,j,1];
        u0(count,:) = apply_homography(u(count,:), h_best);
        count = count + 1; 
    end
end

% Pick color + try to normalize
for i = 1 : delta_x*delta_y
    rgb = initial(round(u0(i,2)),round(u0(i,1)),:); % here we take all values (':') along the third dimension
    to_fill(u(i,2), u(i,1),:) = rgb*(meanIntensity/meanIntensity_initial);
end
fig1 = figure;
imshow( to_fill);
saveas(fig1,'05_corrected.png')

points_u = {u1, u2};


fig2 = figure;
colormap gray
ax = {};
s = subplot(1,2,1);
hold on;
ax{1} = s;
imshow( ims{1} )
axis equal
title('Labeled points in my image');
ylabel('y [px]');
xlabel('x [px]');
hold on

s2 = subplot(1,2,2);
ax{2} = s2;
imshow( ims{2} )
axis equal
title('Labeled points in the reference image');
ylabel('y[px]');
xlabel('x[px]');
hold on

for j = 1:numel( ims )
  set( fig2, 'currentaxes',  ax{j} );
  
  for i = 1:size( points_u{j}, 2 )
      u = points_u{j}(:,i);
      if any(i == points)
        plot( u(1), u(2), 'marker', 'o',  'MarkerEdgeColor','r',...
                'MarkerFaceColor', 'y' , 'markersize', 5);
    
        text( u(1), u(2) - 25, sprintf( '%i', i ), ...
             'verticalalign', 'bottom', 'horizontalalign', 'center', ...
              'backgroundcolor', 'r', ...
                   'fontsize', 7, 'color', 'y');

      else
        plot( u(1), u(2), 'marker', 'x', 'color', 'r', 'markersize', 7 );
    
        text( u(1), u(2) - 25, sprintf( '%i', i ), ...
             'verticalalign', 'bottom', 'horizontalalign', 'center', ...
             'backgroundcolor', 'w', ...
                   'fontsize', 7 );

      end
  end
end

saveas(fig2,'05_homography.pdf')

