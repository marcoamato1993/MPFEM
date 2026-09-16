function [A, Ix] = GeneralCS(model, csID)

    A = model.crossSections(csID).parameters.A;
    Ix = model.crossSections(csID).parameters.Ix;

end

