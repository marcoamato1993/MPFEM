function model = solverSystem(model)
    
    model = feval(model.solver, model);

end

