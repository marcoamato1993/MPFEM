function tvalues = timediscretizer(model)
    stepsmatrix = zeros(numel(model.loadtimefunctions), max([model.loadtimefunctions.nsteps])+1);
    for i = 1:numel(model.loadtimefunctions)
        for j = 1:model.loadtimefunctions(i).nsteps+1
            stepsmatrix(i,j) = model.loadtimefunctions(i).tvalue(j);
        end
    end
    tvalues = unique(sort(stepsmatrix(:)'));
    N = model.solver.intervals;
    
    dtvalues = diff(tvalues);
    
    n = round(dtvalues / sum(dtvalues) * (N - 1));
    
    while sum(n) ~= N-1
        if sum(n) < N-1
            [~, idx] = max(dtvalues ./ n);
            n(idx) = n(idx) + 1;
        else
            [~, idx] = max(n ./ dtvalues);
            n(idx) = n(idx) - 1;
        end
    end
    
    % Discretizzazione
    tvaluesd = [];
    
    for i = 1:length(tvalues)-1
        tvaluesi = linspace(tvalues(i), tvalues(i+1), n(i)+1);
        
        % Evita di duplicare il punto iniziale del segmento successivo
        if i > 1
            tvaluesi = tvaluesi(2:end);
        end
        
        tvaluesd = [tvaluesd tvaluesi];
    end
    tvalues = tvaluesd;
end

