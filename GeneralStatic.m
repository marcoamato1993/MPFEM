function model = GeneralStatic(model)

    K = model.K;
    f = model.f;

    freeDofs = model.freeDofs;
    constrainedDofs = model.constrainedDofs;

    u = zeros(model.nDofs, model.solver.intervals);

    u(constrainedDofs,:) = transpose(model.constrainedValues);

    Kff = K(freeDofs, freeDofs);
    Kfc = K(freeDofs, constrainedDofs);
    
    for i = 1:model.solver.intervals
        rhs = f(freeDofs,i) - Kfc * u(constrainedDofs,i);
    
        u(freeDofs,i) = Kff \ rhs;
    
        model.u = u;
    
        model.r = K * model.u - model.f;
    end

end

