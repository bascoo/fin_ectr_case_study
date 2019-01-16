function [av]=char_to_string(FF)
      av = strings([size(FF,1),1]); 
      for i = 1 : size(FF,1)
          av(i) = convertCharsToStrings(FF(i,:));
      end
      av; 
end