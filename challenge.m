%% Computer Vision Challenge 2019

% Group number:
group_number = 23;

% Group members:
% members = {'Max Mustermann', 'Johannes Daten'};
members = {'Dhaouadi, Oussema','Lin, Kang','Patsch, Constantin','Sukianto, Tobias','Yan, Kevin Tong'};

% Email-Address (from Moodle!):
% mail = {'ga99abc@tum.de', 'daten.hannes@tum.de'};
mail = {'oussema.dhaouadi@tum.de','ga45fav@mytum.de','constantin.patsch@tum.de','ga42zex@mytum.de','kevin.yan@tum.de'};

%% Start timer here
tic;

%% Disparity Map
% Specify path to scene folder containing img0 img1 and calib
scene_path = '';
%
% Calculate disparity map and Euclidean motion
% Try ('preprocess',"sobel",'customMaxWidth',700) if current setting is too slow and Dmap from
% option "histeq" looks bad, or change parameters completly. Stricter
% Parameters tend to reduce PSNR.
[D, R, T] = disparity_map(scene_path,'preprocess',"histeq",'customMaxWidth',1000); 

%% Validation
% Specify path to ground truth disparity map
gt_path = '';
%
% Load the ground truth
G = readpfm(gt_path);

% Estimate the quality of the calculated disparity map
p = verify_dmap(D, G);

%% Stop timer here
elapsed_time = toc;


%% Print Results
% R, T, p, elapsed_time
write('Rotation Matrix:\n');
write('%+5.3f %+5.3f %+5.3f\n',R);
write('\nTranslation Vector:\n');
write('%+4.2f m\n',T);
write('\nPSNR: ');
write('%4.2f dB\n',p);
write('Elapsed time: ');
write('%4.2f s \n',elapsed_time);

%% Display Disparity
figure
image(D);
axis image;
colormap(gray(256))
set(gca,'xtick',[])
set(gca,'ytick',[])
colorbar;

% Normalization of the Ground-Truth in order to compare Matlabs PSNR
% Implementation with our Implementation in the Unittest
if min(G(:))==0 && max(G(:))==255
else
    % Normalization of Ground-Truth between 0 and 255
    G=255*(G-min(G(:)))./(max(G(:))-min(G(:)));
end
save('challenge.mat','group_number','members','mail','elapsed_time','D','R','T','p','G')

