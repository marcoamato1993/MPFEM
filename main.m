% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%                                                                         % 
%               %   % %%%  %%%% %%%% %   %                                % 
%               %% %% %  % %    %    %% %%                                % 
%               % % % %  % %%%  %    % % %                                % 
%               %   % %%%  %    %%%  %   %                                % 
%               %   % %    %    %    %   %                                % 
%               %   % %    %    %%%% %   %                                % 
%                                                                         % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

cleanmemory();

inputFileDirectory = 'C:\Users\amato\Documents\GitHub\MPFEM\inputfiles';

inputFileName = 'ret2d.in';

model = readInput(inputFileDirectory,inputFileName);

model = preprocessing(model);

model = stiffness(model);

model = solverSystem(model);

writeVTK(model, 'output');