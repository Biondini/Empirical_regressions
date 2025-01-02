% Copyright (C) 2024:
% Alma Mater Studiorum Università di Bologna, UNIBO, Bologna, Italy.
% Istituto Nazionale di Geofisica e Vulcanologia, Sezione di Bologna, 
% Italy.
% This program is free software: you can redistribute it and/or modify it
% under  the terms of MIT License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% opinion) any later version. 
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PORPOSE. See the GNU Affero General Public
% License for more details. 
%
% You should have recieved a copy of the GNU Affero General Public License
% along with this program. If not, see http://www.gnu.org/licenses/.

function merged_table = MergeTables(varargin)
    % MergeTables merges multiple tables and preserves the original order of rows.
    %
    %   merged_table = MergeTables(table1, table2, ..., tableN) 
    %   merges the input tables into a single table. The function adds an index 
    %   to each table to keep track of the original order of rows, performs an 
    %   outer join to merge them, and restores the original row order.
    %
    % Input:
    %   varargin : One or more tables to be merged.
    %
    % Output:
    %   merged_table : A single table with all the input tables merged, retaining 
    %                  the original row order.
    
    % Initialize the merged table
    merged_table = varargin{1};  % Start with the first table
    
    % Loop through the remaining tables and add an 'Index' column to each table
    for i = 1:nargin
        % Add an index column to each table to preserve the original order
        varargin{i}.Index = (1:height(varargin{i}))';
    end
    
    % Merge the tables one by one using outer join
    for i = 2:nargin
        merged_table = outerjoin(merged_table, varargin{i}, 'MergeKeys', true);
    end
    
    % Sort the merged table by the Index column to restore the original order
    merged_table = sortrows(merged_table, 'Index');
    
    % Remove the Index column if you no longer need it
    merged_table.Index = [];
end
