function LG = logGabor(rows,cols,omega0,sigmaF)
     [u1, u2] = meshgrid(([1:cols]-(fix(cols/2)+1))/(cols-mod(cols,2)), ...
			            ([1:rows]-(fix(rows/2)+1))/(rows-mod(rows,2)));
     mask = ones(rows, cols);
     for rowIndex = 1:rows
         for colIndex = 1:cols
             if u1(rowIndex, colIndex)^2 + u2(rowIndex, colIndex)^2 > 0.25
                 mask(rowIndex, colIndex) = 0;
             end
         end
     end
     u1 = u1 .* mask;
     u2 = u2 .* mask;
     
     u1 = ifftshift(u1);  
     u2 = ifftshift(u2);
     
     radius = sqrt(u1.^2 + u2.^2);    
     radius(1,1) = 1;
            
     LG = exp((-(log(radius/omega0)).^2) / (2 * (sigmaF^2)));  
     LG(1,1) = 0; 
return;
