function [E, nu] = LinearElastic(model,materialID)
    
    E = model.materials(materialID).parameters.E;
    nu = model.materials(materialID).parameters.nu;

end

