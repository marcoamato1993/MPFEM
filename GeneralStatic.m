function model = GeneralStatic(model)

    tvalues = timediscretizer(model);

    for i = 1:numel(model.boundaryConditions)
        ltfID = model.boundaryConditions(i).loadTimeFunctionID;
        ltftype = model.loadtimefunctions(ltfID).type;
        ftfun = feval(ltftype, model, ltfID, tvalues);
        model.boundaryConditions(i).globalValues = model.boundaryConditions(i).globalValues*ftfun;
    end

    for i = 1:numel(model.forces)
        ltfID = model.forces(i).loadTimeFunctionID;
        ltftype = model.loadtimefunctions(ltfID).type;
        ftfun = feval(ltftype, model, ltfID, tvalues);
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

