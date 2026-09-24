function model = solverSystem(model)
    
    model = feval(model.solver.solverType, model);

end

