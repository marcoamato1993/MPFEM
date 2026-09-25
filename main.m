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

inputFileDirectory = '/home/marco/Documents/MPFEM/inputfiles';
outputFileDirectory = '/home/marco/Documents/MPFEM/outputfiles';

inputFileName = 'ret2d';
outputFileName = 'ret2d';

model = readInput(inputFileDirectory, inputFileName);

model = preprocessing(model);

model = stiffness(model);

model = solverSystem(model);

exporterOutput(model, outputFileDirectory, outputFileName);

disp('Analysis Finished')