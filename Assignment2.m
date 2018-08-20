%assignment 2 scale space blob detection

%     Generate a Laplacian of Gaussian filter.
%     Build a Laplacian scale space, starting with some initial scale and going for n iterations:
%         Filter image with scale-normalized Laplacian at current scale.
%         Save square of Laplacian response for current level of scale space.
%         Increase scale by a factor k. 
%     Perform nonmaximum suppression in scale space.
%     Display resulting circles at their characteristic scales.

imname = 'sunflowers.jpg';
% read in the image
fullim = imread(imname);
fullim = rgb2gray(fullim);
fullim = im2double(fullim);
disp(size(fullim));
[h,w] = size(fullim);
n = 15;%13; is good for increasing filter size, 10 is good for downsampling

tic;
scale_space = zeros(h,w,n); % [h,w] - dimensions of image, n - number of levels in scale space
sigma = 2;
k = 2^(1/4);
sigmas_used = zeros(n,1);
is_downsampling = 1;

if is_downsampling == 0
    for i = 1:n     %increasing filter size by factor of k
        filter_size =  2*ceil(3*sigma)+1;
        log_filter = sigma^2* fspecial('log', filter_size, sigma);
        filtered_im = imfilter(fullim, log_filter, 'same', 'replicate');
        sigmas_used(i,1) = sigma;
        scale_space(:,:,i) = filtered_im;
        sigma = sigma*k;
    end
else
    sigma_changes = 2;
    downsampled_im = fullim;
    for i = 1:n     %downsample image by a factor of 1/k
        filter_size =  2*ceil(3*sigma)+1;
        log_filter = sigma_changes^2 * fspecial('log',60, sigma_changes);
        filtered_im = imfilter(downsampled_im, log_filter, 'same', 'replicate');
        sigmas_used(i,1) = sigma_changes;
        if i > 1
           filtered_im = upsample(filtered_im,2^(i-1));
        end
        filtered_im = imresize(filtered_im,[h w]);
        scale_space(:,:,i) = filtered_im;
        downsampled_im = downsample(downsampled_im,2);
        sigma_changes = sigma_changes*3;
    end
end
disp(toc);
%mesh(log_filter); %show 3d plot of filter created


nonmaximum_suppresion_scale_space = zeros(h,w,n);
%nonmaximum suppresion
for i=1:n
    nonmaximum_suppresion_scale_space(:,:,i) = nlfilter(scale_space(:,:,i),[9 9],@nonmaximal_suppression); % 5 5 good for filter size, 9 9 good for downsampling
end
final_filtered_im = zeros(h,w);
for x =1:h
    for y= 1:w
        curr_max = nonmaximum_suppresion_scale_space(x,y,1);
        curr_radius = sqrt(2)*sigmas_used(1,1);
        for slice=2:n
            if nonmaximum_suppresion_scale_space(x,y,slice) > curr_max
                curr_max = nonmaximum_suppresion_scale_space(x,y,slice);
                curr_radius = sqrt(2)*sigmas_used(slice,1);
            end
        end
        if curr_max > .08  %.12 is a good value for increasing filter size, .08 good for downsampling
            final_filtered_im(x,y) = curr_radius;
        end
    end
end
final_filtered_im = nlfilter(final_filtered_im,[9 9],@nonmaximum_suppression); %9 9 good for both
[cx, cy, rad] = find(final_filtered_im > 0);
threshold_final_filter_im = final_filtered_im(final_filtered_im > 0);
show_all_circles(fullim,cy,cx,threshold_final_filter_im);

%suppresion on each image with either nlfilter, colfilt or ordfilt2