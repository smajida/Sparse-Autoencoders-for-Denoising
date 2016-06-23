%% Comment out whichever step to switch between either training or cross validation.
%%======================================================================
%% STEP 0: Here we provide the relevant parameters values that will
%  allow your sparse autoencoder to get good filters; you do not need to 
%  change the parameters below.

visibleSize = 21*21;   % number of input units 
hiddenSize = 600;     % number of hidden units 
sparsityParam = 0.01;   % desired average activation of the hidden units.
                     % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		     %  in the lecture notes). 
lambda = 0.0001;     % weight decay parameter       
beta = 3;            % weight of sparsity penalty term       
train_type = 0; % 0 or 1 depending on repeated and non repeated case
%%======================================================================
%% STEP 1: Implement sampleIMAGES
%
%  After implementing sampleIMAGES, the display_network command should
%  display a random sample of 200 patches from the dataset

patches = sampleIMAGES;
display_network(patches(:,randi(size(patches,2),200,1),1),8);


%  Obtain random parameters theta
theta = initializeParameters(hiddenSize, visibleSize);

%%======================================================================
%% STEP 2: Implement sparseAutoencoderCost
%  Feel free to change the training settings when debugging your
%  code.  (For example, reducing the training set size or 
%  number of hidden units may make your code run faster; and setting beta 
%  and/or lambda to zero may be helpful for debugging.)  However, in your 
%  final submission of the visualized weights, please use parameters we 
%  gave in Step 0 above.

[cost, grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, lambda, ...
                                     sparsityParam, beta, patches,train_type);

%%======================================================================
%% STEP 3: Gradient Checking
%
% Hint: If you are debugging your code, performing gradient checking on smaller models 
% and smaller training sets (e.g., using only 10 training examples and 1-2 hidden 
% units) may speed things up.

% First, lets make sure your numerical gradient computation is correct for a
% simple function.  After you have implemented computeNumericalGradient.m,
% run the following: 
checkNumericalGradient();

% Now we can use it to check your cost function and derivative calculations
% for the sparse autoencoder.  
numgrad = computeNumericalGradient( @(x) sparseAutoencoderCost(x, visibleSize, ...
                                                 hiddenSize, lambda, ...
                                                  sparsityParam, beta, ...
                                                 patches,train_type), theta);

% Use this to visually compare the gradients side by side
disp([numgrad grad]); 

% Compare numerically computed gradients with the ones obtained from backpropagation
diff = norm(numgrad-grad)/norm(numgrad+grad);
disp(diff); % Should be small. In our implementation, these values are
            % usually less than 1e-9.

            % When you got this working, Congratulations!!! 

%%======================================================================
%% STEP 4: After verifying that your implementation of
%  sparseAutoencoderCost is correct, You can start training your sparse
%  autoencoder with minFunc (L-BFGS).

%  Randomly initialize the parameters
theta = initializeParameters(hiddenSize, visibleSize);

%  Use minFunc to minimize the function
%addpath minFunc/
%options.Method = 'lbfgs'; % Here, we use conjugate gradient to optimize our cost
                          % function. L-BFGS can also be used as in the original exercise 
                          % code
options = optimset('MaxIter', 400);	  % Maximum number of iterations of L-BFGS to run 
%options.display = 'on';


[opttheta, cost] = fmincg( @(p) sparseAutoencoderCost(p, ...
                                   visibleSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, patches,train_type), ...
                              theta, options);

%%======================================================================
%% STEP 5: Visualization 

W1 = reshape(opttheta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
display_network(W1', 12); 
  % save the visualization to a file 
%%======================================================================
%% STEP 6: Prediction
testData = imread('');
output = feedForwardAutoencoder(opttheta, hiddenSize, visibleSize, testData);
output_image = reshape(output, [21 21]);
%%======================================================================
%% OPTIONAL: Cross Validation
[error_train,error_val] = crossValidate(X_train_clean,X_train_noise,X_val_clean,X_val_noise,lambda, sparsityParam, beta,...
                                                   hiddenSize,visibleSize);
                                                   

