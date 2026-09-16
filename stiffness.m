function model = stiffness(model)
    
    K = zeros(model.nDofs, model.nDofs);

    for elementID = 1:numel(model.elements)

        element = model.elements(elementID);
        
        for setID = 1:numel(model.sets)

            set = model.sets(setID);

            if strcmp(set.type, 'elements') && ismember(elementID, set.ids)
                elementSetID = setID;
                break
            end

        end

        %=========================================================
        %  ELEMENT NODES
        %=========================================================
        
        node1 = element.nodes(1);
        node2 = element.nodes(2);

        %=========================================================
        %  NODES COORDINATES
        %=========================================================
       
        coords1 = model.nodes(node1).coords;
        coords2 = model.nodes(node2).coords;

        %=========================================================
        %  ELEMENTS PROPERTIES
        %=========================================================

        Lx = coords2(1) - coords1(1);
        Ly = coords2(2) - coords1(2);
        Lz = coords2(3) - coords1(3);
        L = sqrt(Lx^2 + Ly^2 + Lz^2);

        alpha = atan2(Ly, Lx);
        beta = atan2(Lz, hypot(Lx, Ly));

        RotAlpha = [cos(alpha) -sin(alpha) 0;
                    sin(alpha) cos(alpha) 0;
                    0          0          1];

        RotBeta = [cos(beta) 0 -sin(beta);
                   0         1 0;           
                   sin(beta) 0 cos(beta)];

        Rot = RotAlpha * RotBeta;

        T = blkdiag(Rot, Rot);

        material_type = model.materials([model.materials.setID] == elementSetID).type;
        for materialID = 1:numel(model.materials)

            material = model.materials(materialID);
        
            if material.setID == elementSetID
                break
            end
        
        end

        cs_type = model.crossSections( [model.crossSections.setID] == elementSetID).type;
        for csID = 1:numel(model.crossSections)

            crossSection = model.crossSections(csID);
        
            if crossSection.setID == elementSetID
                break
            end
        
        end

        [E, nu] = feval(material_type, model, materialID);
        [A, Ix] = feval(cs_type, model, csID);
        
        %=========================================================
        %  LOCAL STIFFNESS
        %=========================================================

        KeLocal = feval(element.type, L, E, A);
        
        KeLocalRot = T * KeLocal * transpose(T);

        KeLocalRotActive = KeLocalRot(model.ActiveDofs, model.ActiveDofs);

        %=========================================================
        %  GLOBAL STIFFNESS
        %=========================================================

        dofs = element.dofs;
        K(dofs, dofs) = K(dofs, dofs) + KeLocalRotActive;

    end

    model.K = K;
    
end