function flatM = flatten(M)
% flatten Function
%
% The 'flatten' function takes a 3D matrix and flattens it into a 2D matrix 
% by stacking the slices of the 3rd dimension vertically. Each slice along 
% the 3rd dimension of the input matrix becomes a consecutive block of rows 
% in the output matrix.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% flatM = flatten(M)
%
% Inputs:
% -------
% - 'M': A 3D matrix of size '(h x w x l)' to be flattened, where:
%    - 'h': Number of rows in each slice (1st dimension).
%    - 'w': Number of columns in each slice (2nd dimension).
%    - 'l': Number of slices along the 3rd dimension.
%
% Outputs:
% --------
% - 'flatM': A 2D matrix of size '(h*l x w)', where each block of 'h' rows 
%   corresponds to a slice of 'M' along the 3rd dimension.
%
% Description:
% ------------
% The function rearranges the elements of the input 3D matrix 'M' into a 
% single 2D matrix 'flatM' by stacking the 'l' slices along the 3rd 
% dimension of 'M' into vertical blocks. The output matrix has a number of 
% rows equal to the total rows in all slices ('h*l') and the same number of 
% columns as the input ('w').
%
% Example:
% --------
% Input:
% M = cat(3, [1 2; 3 4], [5 6; 7 8], [9 10; 11 12]);
% Output:
% flatM = [ 1  2;
%           3  4;
%           5  6;
%           7  8;
%           9 10;
%          11 12];
%
% Algorithm:
% ----------
% 1. Determine the number of slices ('l') in the 3rd dimension.
% 2. Compute the number of rows per slice ('h').
% 3. Initialize an empty 2D matrix 'flatM' with dimensions '(h*l x w)'.
% 4. Loop through each slice in the 3rd dimension and assign its contents 
%    to the corresponding block of rows in 'flatM'.
%
% Notes:
% ------
% - The function assumes that the input matrix 'M' is non-empty and has 
%   consistent dimensions.
% - This operation is useful for data reshaping or preparing 3D data for 
%   algorithms that require 2D inputs.
%
% See also:
% ---------
% - reshape: MATLAB function for reshaping arrays.
% - cat.m : MATLAB function for concatenating arrays.


    l = size(M,3);
    h = size(M,1);
    flatM = zeros(size(M,1)*l,size(M,2));
    
    for i = 1:1:size(M,3)
        flatM(h*(i-1)+1:h*i,:) = M(:,:,i);
    end
end

