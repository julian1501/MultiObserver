bigSize = 30;
smallSize = 14;
numCombs = nchoosek(bigSize,smallSize);
ids = nchoosek(1:1:bigSize,smallSize);

tic
    for i = 1:1:numCombs
        for j = 1:1:smallSize
            ids(i,j);
        end
    end
toc

tic
    for i = 1:1:numCombs
        for j = 1:1:smallSize
            c = generateCombination(i,bigSize,smallSize);
            c(j);
        end
    end
toc

    

