function diffraction_loss = epstein_peterson(rng_km,z,frequencia);

%Epstein-Peterson Model

% Author: Jonas Nunes 
% Universidade do Estado do Rio de Janeiro
% 2017
% www.joneco.com.br

%This function script calculate the diffraction loss based in the Epstein-Peterson method.

distance = rng_km(end)*1000;
size = length(rng_km);
tops_position = rng_km(1); % vector that store the position of the tops (biggest height points), it initialize with the transmitter position
h_tops = z(1); % vector that store the height of the tops (biggest height points), it initialize with the transmitter position
ref = 1; % itialize the x postion reference of the transmitter
proxima_ref = 2;

%Fiding the main obstacles
while(tops_position(end)~=rng_km(end));
    %store first upper/superior fresnel boundary
    ultima_boundary = (z(ref+1)-z(ref))/(rng_km(ref+1)-rng_km(ref));
    %runs from the last peak found to the end and compares to find new
    %upper/superior fresnel boundary
    for i=ref+2:size;
        %calculates new tangent
        actual_boundary = (z(i)-z(ref))/(rng_km(i)-rng_km(ref));
        % compare, if actual > then the last one findend it refreshes the references
        if ultima_boundary < actual_boundary;
            ultima_boundary = actual_boundary;
            proxima_ref = i; 
        end
    end
    
    % here confirms if a new peak was found, if not it gets out of the
    % statement because all peaks were founded
    if (ref < proxima_ref); 
        ref = proxima_ref;
    else
        ref = ref + 1;
    end
    tops_position = [tops_position rng_km(ref)];
    h_tops = [h_tops z(ref)];
end
%desenha linhas
for i=2:length(tops_position);
    plot([tops_position(i-1) tops_position(i)],[h_tops(i-1) h_tops(i)],'Color','black');
end

%additional loss calculation (diffraction loss) if there are more than 2
%tops_position, 2 = transmitter + receiver point
tops_position = tops_position * 1000; %distances to meters
diffraction_loss = 0; %dB
if length(tops_position)>2
    
    for i=1:length(tops_position)-2;
        hr = h_tops(i+2);
        ht = h_tops(i);
        hobs = h_tops(i+1);
        distance = tops_position(i+2)-tops_position(i);
        d1 = tops_position(i+1)-tops_position(i);
        d2 = distance - d1;
        hv = hr-(hr-ht)/distance*d2;
        ro = sqrt((d1*d2*3e8)/(distance*frequencia));
        H = hobs-hv;
        Vo = sqrt(2)*H/ro;
        % its an aproximation, is possible to replace using sine and cosine
        % fresnel integral calculation provided in an external code for a
        % more accurate result (in pratctice was not too relevant)
        diffraction_loss = diffraction_loss + (-20*log10(0.5*exp(-0.95*Vo))) ;
    end

end
end
