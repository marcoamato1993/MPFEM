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

inputFileDirectory = '/home/marco/Documents/MPFEMFiles/inputfiles';
outputFileDirectory = '/home/marco/Documents/MPFEMFiles/outputfiles';

inputFileName = 'ret2d';
outputFileName = 'ret2d';

model = readInput(inputFileDirectory, inputFileName);

model = preprocessing(model);

model = stiffness(model);

model = solverSystem(model);

exporterOutput(model, outputFileDirectory, outputFileName);

disp('Analysis Finished')