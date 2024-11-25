function score = compareMO(x1,x2,t1,t2)
    % 
    tCommon = linspace(min([t1,t2]),max([t1,t2]),1000);
    x1Interp = interp1(t1,x1',tCommon,"spline")';
    x2Interp = interp1(t2,x2',tCommon,"spline")';
    
    diff = x1Interp - x2Interp;
    score = norm(diff,'fro');

    disp(score)
    if score < 1e-3
        disp('Tolerance within numerical tolerance.')
    else
        disp('The solutions are not similar.')
    end

end