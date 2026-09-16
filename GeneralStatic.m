function model = GeneralStatic(model)

    for i = 1:numel(model.boundaryConditions)
        
    end

    for i = 1:numel(model.forces)
        
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

