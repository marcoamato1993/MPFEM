function [tfun, ftfun] = PieceWiseLinearFunction(model, ltfID)
    nsteps = model.loadtimefunctions(ltfID).nsteps;
    nintervals = model.loadtimefunctions(ltfID).nIntervals;
    nintervalspersteps = nintervals/nsteps;
    for i = 1:nsteps
        tf(1) = 0;
        fti(1) = 0;
        tf(i+1) = model.loadtimefunctions(ltfID).tvalue(i);
        ftf(i+1) = model.loadtimefunctions(ltfID).ftvalue(i);
    end
    tfun = zeros(nsteps,nintervalspersteps);
    ftfun = zeros(nsteps,nintervalspersteps);
    for i = 1:nsteps
        tfun(i,:) = linspace(tf(i),tf(i+1),nintervalspersteps);
        ftfun(i,:) = linspace(ftf(i),ftf(i+1),nintervalspersteps);
    end
    tfun = [tfun(1,:), reshape(tfun(2:end, 2:end).', 1, [])];
    ftfun = [ftfun(1,:), reshape(ftfun(2:end, 2:end).', 1, [])];
end

