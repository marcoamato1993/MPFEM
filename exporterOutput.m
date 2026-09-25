function exporterOutput(model, outputFileDirectory, outputFileName)

    if nargin < 2
        outputFileDirectory = 'outputfiles';
    end

    if ~exist(outputFileDirectory, 'dir')
        mkdir(outputFileDirectory);
    end

    nNodes = numel(model.nodes);
    nElements = numel(model.elements);
    nSteps = size(model.u, 2);
    nDofsPerNode = numel(model.dofNames);
    timeValues = timediscretizer(model);

    if numel(timeValues) ~= nSteps
        error('The number of time values does not match the number of solution steps.');
    end

    coordinates = zeros(nNodes, 3);
    for nodeID = 1:nNodes
        nodeCoordinates = model.nodes(nodeID).coords(:)';
        coordinates(nodeID, 1:numel(nodeCoordinates)) = nodeCoordinates;
    end

    pvdPath = fullfile(outputFileDirectory, [outputFileName '.pvd']);
    pvdFile = fopen(pvdPath, 'w');
    if pvdFile == -1
        error('Unable to create PVD file: %s', pvdPath);
    end

    cleanupPvd = onCleanup(@() fclose(pvdFile));

    fprintf(pvdFile, '<?xml version="1.0"?>\n');
    fprintf(pvdFile, '<VTKFile type="Collection" version="0.1" byte_order="LittleEndian">\n');
    fprintf(pvdFile, '  <Collection>\n');

    for stepID = 1:nSteps
        fileName = sprintf([outputFileName '_%04d.vtk'], stepID - 1);
        filePath = fullfile(outputFileDirectory, fileName);
        vtkFile = fopen(filePath, 'w');
        if vtkFile == -1
            error('Unable to create VTK file: %s', filePath);
        end

        cleanupVtk = onCleanup(@() fclose(vtkFile));

        fprintf(vtkFile, '# vtk DataFile Version 3.0\n');
        fprintf(vtkFile, 'MPFEM result at time %.16g\n', timeValues(stepID));
        fprintf(vtkFile, 'ASCII\n');
        fprintf(vtkFile, 'DATASET UNSTRUCTURED_GRID\n');
        fprintf(vtkFile, 'POINTS %d double\n', nNodes);
        fprintf(vtkFile, '%.16g %.16g %.16g\n', coordinates');

        fprintf(vtkFile, 'CELLS %d %d\n', nElements, 3 * nElements);
        for elementID = 1:nElements
            nodeIDs = model.elements(elementID).nodes - 1;
            if numel(nodeIDs) ~= 2
                error('VTK line export supports two-node elements only.');
            end
            fprintf(vtkFile, '2 %d %d\n', nodeIDs);
        end

        fprintf(vtkFile, 'CELL_TYPES %d\n', nElements);
        fprintf(vtkFile, repmat('3\n', 1, nElements));

        displacement = zeros(nNodes, 3);
        for nodeID = 1:nNodes
            nodeDofs = model.nodes(nodeID).dofs;
            displacement(nodeID, 1:nDofsPerNode) = model.u(nodeDofs, stepID)';
        end

        fprintf(vtkFile, 'POINT_DATA %d\n', nNodes);
        fprintf(vtkFile, 'VECTORS displacement double\n');
        fprintf(vtkFile, '%.16g %.16g %.16g\n', displacement');

        displacementMagnitude = sqrt(sum(displacement.^2, 2));
        fprintf(vtkFile, 'SCALARS displacement_magnitude double 1\n');
        fprintf(vtkFile, 'LOOKUP_TABLE default\n');
        fprintf(vtkFile, '%.16g\n', displacementMagnitude);

        fprintf(pvdFile, '    <DataSet timestep="%.16g" group="" part="0" file="%s"/>\n', ...
            timeValues(stepID), fileName);

        clear cleanupVtk
    end

    fprintf(pvdFile, '  </Collection>\n');
    fprintf(pvdFile, '</VTKFile>\n');
end
