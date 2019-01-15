function [av]=char_to_string(FF)
    av = strings([size(FF, 1),1]);
    for i = 1 : size(FF, 1)
        for j = 1 : size(FF , 2) 
            av(i) = strcat(av(i), FF(i,j));
        end
    end    
    av;
end