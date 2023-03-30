function [Vr] = rotation(x, y, z, a)
    
    
    %Vertices matrix
    V=[x(:) y(:) z(:)];
    
    V_centre=mean(V,1); %Centre, of line
    Vc=V-ones(size(V,1),1)*V_centre; %Centering coordinates
    a_rad=((a*pi)./180); %Angle in radians
    
    E=[0  0 a_rad]; %Euler angles for X,Y,Z-axis rotations
    
    %Direction Cosines (rotation matrix) construction
    Rx=[1        0        0;...
        0        cos(E(1))  -sin(E(1));...
        0        sin(E(1))  cos(E(1))]; %X-Axis rotation
    
    Ry=[cos(E(2))  0        sin(E(2));...
        0        1        0;...
        -sin(E(2)) 0        cos(E(2))]; %Y-axis rotation
    
    Rz=[cos(E(3))  -sin(E(3)) 0;...
        sin(E(3))  cos(E(3))  0;...
        0        0        1]; %Z-axis rotation
    
    R=Rx*Ry*Rz; %Rotation matrix
    Vrc=[R*Vc']'; %Rotating centred coordinates
    %Vruc=[R*V']'; %Rotating un-centred coordinates
    Vr=Vrc+ones(size(V,1),1)*V_centre; %Shifting back to original location
    
    figure;
    plot3(V(:,1),V(:,2),V(:,3), 'g.-', MarkerSize=25);  
    hold on; %Original
    plot3(Vr(:,1),Vr(:,2),Vr(:,3),'r.-', MarkerSize=25); %Rotated around centre of line
    %scatter3(Vruc(:,1),Vruc(:,2),Vruc(:,3),'b'); %Rotated around origin
    grid on;
end