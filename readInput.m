function model = readInput(inputFileDirectory,inputFileName);

    filepath = fullfile(inputFileDirectory, inputFileName);
    
    %=========================================================
    %  FILE OPENING
    %=========================================================

    fid = fopen(filepath, 'r');

    if fid == -1 
        error('Unable to open the file: %s', filepath); 
    end

    %=========================================================
    %  INITIALIZATION
    %=========================================================

    model = struct();

    model.solver = struct();
    model.domain = struct();
    model.nodes = struct();
    model.elements = struct();
    model.materials = struct();
    model.crossSections = struct();
    model.boundaryConditions = struct();
    model.forces = struct();
    model.sets = struct();
    model.loadtimefunctions = struct();

    section = '';

    %=========================================================
    %  FILE READING
    %=========================================================

    while ~feof(fid)

        % Read a line
        line = fgetl(fid);

        % Remove leading and trailing spaces
        line = strtrim(line);

        % Skip empty lines
        if isempty(line)
            continue
        end

        %=====================================================
        %  SECTION IDENTIFICATION
        %=====================================================

        if startsWith(line, '#')

            section = line;

            continue
        end


        %=====================================================
        %  PARSING
        %=====================================================

        switch section

            case '# SOLVER'

                model.solver = string(strtrim(line));

            case '# DOMAIN'

                model.domain = string(strtrim(line));

            case '# NODES'

                tokens = split(line);

                nodeID = str2double(tokens{2});

                nCoords = str2double(tokens{4});

                coords = str2double(tokens(5 : 4+nCoords));

                model.nodes(nodeID).coords = coords;


            case '# ELEMENTS'

                tokens = split(line);

                elementType = tokens{1};

                elementID = str2double(tokens{2});

                nNodes = str2double(tokens{4});

                nodeIDs = str2double(tokens(5 : 4+nNodes));

                model.elements(elementID).type = elementType;
                model.elements(elementID).nodes = nodeIDs;


            case '# MATERIALS'

                tokens = split(line);

                materialType = tokens{1};

                materialID = str2double(tokens{2});

                setIndex = find(strcmp(tokens, 'set'), 1);

                parameters = struct();

                for tokenID = 3 : 2 : setIndex - 1

                    parameterName = tokens{tokenID};
                    parameterValue = str2double(tokens{tokenID + 1});

                    parameters.(parameterName) = parameterValue;

                end

                model.materials(materialID).type = tokens{1};
                model.materials(materialID).parameters = parameters;
                model.materials(materialID).setID = str2double(tokens{setIndex + 1});


            case '# CROSSSECTIONS'

                tokens = split(line);

                crossSectionType = tokens{1};

                crossSectionID = str2double(tokens{2});

                setIndex = find(strcmp(tokens, 'set'), 1);

                parameters = struct();

                for tokenID = 3 : 2 : setIndex - 1

                    parameterName = tokens{tokenID};
                    parameterValue = str2double(tokens{tokenID + 1});

                    parameters.(parameterName) = parameterValue;

                end

                model.crossSections(crossSectionID).type = tokens{1};
                model.crossSections(crossSectionID).parameters = parameters;
                model.crossSections(crossSectionID).setID = str2double(tokens{setIndex + 1});


            case '# BOUNDARYCONDITIONS'

                tokens = split(line);

                bcID = str2double(tokens{2});

                nDofs = str2double(tokens{6});

                localDofs = str2double(tokens(7 : 6+nDofs));
                values = str2double(tokens(7+nDofs : 6+2*nDofs));

                setKeywordIndex = 7 + 2*nDofs;

                if ~strcmp(tokens{setKeywordIndex}, 'set')
                    error('Expected "set" in boundary condition %d.', bcID);
                end

                model.boundaryConditions(bcID).type = tokens{1};
                model.boundaryConditions(bcID).loadTimeFunctionType = tokens{3};
                model.boundaryConditions(bcID).loadTimeFunctionID = str2double(tokens{4});
                model.boundaryConditions(bcID).localDofs = localDofs;
                model.boundaryConditions(bcID).values = values;
                model.boundaryConditions(bcID).setID = str2double(tokens{setKeywordIndex + 1});


            case '# FORCES'

                tokens = split(line);

                forceID = str2double(tokens{2});

                nDofs = str2double(tokens{6});

                localDofs = str2double(tokens(7 : 6+nDofs));
                values = str2double(tokens(7+nDofs : 6+2*nDofs));

                setKeywordIndex = 7 + 2*nDofs;

                if ~strcmp(tokens{setKeywordIndex}, 'set')
                    error('Expected "set" in force %d.', forceID);
                end

                model.forces(forceID).type = tokens{1};
                model.forces(forceID).loadTimeFunctionType = tokens{3};
                model.forces(forceID).loadTimeFunctionID = str2double(tokens{4});
                model.forces(forceID).localDofs = localDofs;
                model.forces(forceID).values = values;
                model.forces(forceID).setID = str2double(tokens{setKeywordIndex + 1});


            case '# SETS'

                tokens = split(line);

                setID = str2double(tokens{2});

                setType = tokens{3};

                nEntities = str2double(tokens{4});

                entityIDs = str2double(tokens(5 : 4+nEntities));

                model.sets(setID).type = setType;
                model.sets(setID).ids = entityIDs;

            case '# LOADTIMEFUNCTIONS'

                tokens = split(line);

                ltfType = tokens{1};

                ltfID = str2double(tokens{2});

                nsteps = str2double(tokens{4});

                tvalue = str2double(tokens(5 : 4+nsteps));

                ftvalue = str2double(tokens(7 + nsteps : 6 + 2*nsteps));

                nIntervals = str2double(tokens{8 + 2*nsteps});

                model.loadtimefunctions(ltfID).type = ltfType;
                model.loadtimefunctions(ltfID).nsteps = nsteps;
                model.loadtimefunctions(ltfID).tvalue = tvalue;
                model.loadtimefunctions(ltfID).ftvalue = ftvalue;
                model.loadtimefunctions(ltfID).nIntervals = nIntervals;

            otherwise

                warning('Unrecognized section: %s', section);

        end

    end


    %=========================================================
    %  FILE CLOSING
    %=========================================================

    fclose(fid);

end
