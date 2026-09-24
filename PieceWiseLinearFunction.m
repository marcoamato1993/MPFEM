function ftvalues = PieceWiseLinearFunction(model, ltfID, tvalues)
    nsteps = model.loadtimefunctions(ltfID).nsteps;
    t = model.loadtimefunctions(ltfID).tvalue;
    ft = model.loadtimefunctions(ltfID).ftvalue;
    for i = 1:nsteps
        m(i) = (ft(i+1)-ft(i))/(t(i+1)-t(i));
        q(i) = ft(i) - t(i)*(ft(i+1)-ft(i))/(t(i+1)-t(i));
    end
    for i = 1:length(tvalues)
        for j = 1:nsteps 
            if tvalues(i) >= t(j) && tvalues(i) <= t(j+1)
                ftvalues(i) = m(j)*tvalues(i) + q(j);
                break
            end
        end
    end
end

