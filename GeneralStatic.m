function model = GeneralStatic(model)
    
    stepsmatrix = zeros(numel(model.loadtimefunctions), max([model.loadtimefunctions.nsteps]));
    for i = 1:numel(model.loadtimefunctions)
        for j = 1:model.loadtimefunctions(i).nsteps
            stepsmatrix(i,j) = model.loadtimefunctions(i).tvalue(j);
        end
    end
    tvalues = unique(sort(stepsmatrix(:)'));

    for i = 1:numel(model.boundaryConditions)
        ltfID = model.boundaryConditions(i).loadTimeFunctionID;
        ltftype = model.loadtimefunctions(ltfID).type;
        [tfun, ftfun] = feval(ltftype, model, ltfID);
        model.boundaryConditions(i).globalValues = model.boundaryConditions(i).globalValues*ftfun;
    end

    for i = 1:numel(model.forces)
        ltfID = model.forces(i).loadTimeFunctionID;
        ltftype = model.loadtimefunctions(ltfID).type;
        [tfun, ftfun] = feval(ltftype, model, ltfID);
        model.forces(i).globalValues = model.forces(i).globalValues*ftfun;
    end

    K = model.K;
    f = model.f;

    freeDofs = model.freeDofs;
    constrainedDofs = model.constrainedDofs;

    u = zeros(model.nDofs, 1);

    u(constrainedDofs) = model.constrainedValues(:);

    Kff = K(freeDofs, freeDofs);
    Kfc = K(freeDofs, constrainedDofs);

    rhs = f(freeDofs) - Kfc * u(constrainedDofs);

    u(freeDofs) = Kff \ rhs;

    model.u = u;

    model.r = K * model.u - model.f;

end

