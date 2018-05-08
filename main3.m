clc;
close all;
clear all;
addpath isotropy;
addpath misc;
addpath hierarchy;
%filename = 'data_spiral.txt';
filename = 'data_crescents.txt';
%filename = 'sample_data.txt';
%filename = 'data_set_1_8_1_gaussian.txt';
fname = sprintf('rich%s.mat',filename);
load(fname)
%data is the normalized rich data, %data_rich is the unnormalized rich data
%data_original is the original data in the original space
no_properties = size(data,2);
T = 10;
alpha = 0.01; %learning rate
w = rand(no_properties,1);
w = softmax(w);
%For each dataset do the following
N = size(data,1);
D = size(data,2);
%neighbors_criterion = 'Fixed_number';
neighbors_criterion = 'Fixed_radius';
% Precompute Neighbors
if strcmp(neighbors_criterion, 'Fixed_number')
    data_neighbors = precompute_nearest_neighbors(data, params.Kmax);
else
    [data_neighbors, nbr_radius] = precompute_neighbors_fixedradius(data_original);        
end
y_orig = data(:,10);%Uniformity isotropy is the 10th dimension
meany = median(y_orig);
%stdy = std(y_orig);
stdy = 0;
y = y_orig > meany - stdy;
weights = zeros(T+1,no_properties);
weights(1,:) = w';
T = 5;
labels = zeros(T, N);
f = figure;
scatter(data_original(:,1), data_original(:,2), 1,y);
for iter = 1:1:T
    %Minimise energy to find yhat (n X 1)
    weight=weights(iter,:);
    yhat = energy_minimisation(data, weight,data_neighbors);
    yhat = logical(yhat);
    labels(iter,:) = yhat';
    f = figure;
    scatter(data_original(:,1), data_original(:,2), 1,yhat);
    %yhat = data(:,9);
    %yhat = yhat > mean(yhat);
    loss = sumsqr(yhat - y);
    fprintf('\nIteration: %d , loss: %d', iter, loss);
    %2. Compute weights w using grad-descent
    derivative = compute_derivate(weights(iter,:), data, y, yhat, data_neighbors);
    w = weights(iter,:) - alpha*derivative';
    w2 = (w-min(w))/(max(w)-min(w));
    weights(iter+1,:) = softmax(w2');
end
%{
%Visualising the neighbors in the high dimensional space
for i = 1:1:N
    close all;
    i = 321;
   nbrs = data_neighbors{i};
   plot(data_original(:,1), data_original(:,2), 'r.');
   hold on;
   plot(data_original(nbrs,1), data_original(nbrs,2), 'b.');
   hold on;
   plot(data_original(i,1), data_original(i,2), 'g.');
end
%}