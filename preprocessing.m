function model = preprocessing(model)

    %=========================================================
    %  DOFs PER NODE
    %=========================================================
    
    referenceDofNames = ["ux", "uy", "uz"];
    
    switch model.domain
        case "Plane2D"
            dofNames = ["ux", "uy"];

        case "Space3D"
            dofNames = ["ux", "uy", "uz"];

        otherwise
            error('Unsupported domain: %s', model.domain);
    end

    model.dofNames = dofNames;

    nDofsPerNode = numel(model.dofNames);

    nReferenceDofsPerNode = numel(referenceDofNames);

    activeDofsPerNode = find(ismember(referenceDofNames, model.dofNames));

    model.ActiveDofs = [activeDofsPerNode, nReferenceDofsPerNode + activeDofsPerNode];

    %=========================================================
    %  GLOBAL DOFs PER NODE AND ELEMENT
    %=========================================================
    
    for nodeID = 1:numel(model.nodes)
        firstGlobalDof = (nodeID - 1) * nDofsPerNode + 1;

        model.nodes(nodeID).dofs = firstGlobalDof : firstGlobalDof + nDofsPerNode - 1;
    end

    model.nDofs = numel(model.nodes) * nDofsPerNode;

    for elementID = 1:numel(model.elements)

        nodeIDs = model.elements(elementID).nodes;

        model.elements(elementID).dofs = [model.nodes(nodeIDs).dofs];

    end

    %=========================================================
    %  GLOBAL BOUNDARY CONDITIONS
    %=========================================================

    model.constrainedDofs = [];
    model.constrainedValues = [];

    for bcID = 1:numel(model.boundaryConditions)

        bc = model.boundaryConditions(bcID);

        if ~strcmp(model.sets(bc.setID).type, 'nodes')
            error('Boundary condition %d must reference a node set.', bcID);
        end

        if any(bc.localDofs < 1) || any(bc.localDofs > nDofsPerNode) || any(mod(bc.localDofs, 1) ~= 0)
            error('Boundary condition %d contains invalid local DOF indices.', bcID);
        end

        nodeIDs = model.sets(bc.setID).ids;
        globalDofs = [];
        globalValues = [];

        for nodeID = nodeIDs
            globalDofs = [globalDofs, model.nodes(nodeID).dofs(bc.localDofs)];
            globalValues = [globalValues, bc.values];
        end

        if any(ismember(globalDofs, model.constrainedDofs))
            error('Boundary condition %d constrains a DOF that is already constrained.', bcID);
        end

        model.boundaryConditions(bcID).globalDofs = globalDofs;
        model.boundaryConditions(bcID).globalValues = globalValues;

        model.constrainedDofs = [model.constrainedDofs, globalDofs];
        model.constrainedValues = [model.constrainedValues, transpose(globalValues)];

    end

    model.freeDofs = setdiff(1:model.nDofs, model.constrainedDofs);

    %=========================================================
    %  GLOBAL EXTERNAL FORCES
    %=========================================================

    model.f = zeros(model.nDofs, 1);

    for forceID = 1:numel(model.forces)

        force = model.forces(forceID);

        if ~strcmp(model.sets(force.setID).type, 'nodes')
            error('Force %d must reference a node set.', forceID);
        end

        if any(force.localDofs < 1) || any(force.localDofs > nDofsPerNode) || ...
                any(mod(force.localDofs, 1) ~= 0)
            error('Force %d contains invalid local DOF indices.', forceID);
        end

        nodeIDs = model.sets(force.setID).ids;
        globalDofs = [];
        globalValues = [];

        for nodeID = nodeIDs
            globalDofs = [globalDofs, model.nodes(nodeID).dofs(force.localDofs)];
            globalValues = [globalValues, force.values];
        end

        model.forces(forceID).globalDofs = globalDofs;
        model.forces(forceID).globalValues = globalValues;

        model.f(globalDofs) = model.f(globalDofs) + globalValues.';
    end

end
