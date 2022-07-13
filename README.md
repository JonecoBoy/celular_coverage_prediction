# celular_coverage_prediction
I've done this for study purpose at the end of my engineering undergraduation in 2017. This code is free for any use.

## Description

Matlab set os scripts to predict a cellphone coverage area using a isotropic antenna with only free space loss and considering also diffraction loss using the Epstein-Peterson method.
Also a Script to calculate fresnel elipsoid, elevation path, received power and total loss between two radio links.

This Scripts does not utilize any info about constructions/building heights, just terrain elevation, if you have some infos of that you can use a dted file with those infos or utilize a matrix losses based in cluster infos like urban, semi-urban, dense urban or rural areas...

## Scripts Explanation

plot_google_map.m
```bash
This method script is optional. It is used as a background just for a pleasant background for data visualization.
this script was made by Zohar Bar-Yehuda, i use it to plot the sunrounding area of the link. It will automatically print based on the latlong dataset in the current plot, not need to pass any parameter.

All scripts are fully commented in english.
```

link_calculation.m
```bash
this script will calculate and plot the fresnel elipsoid, elevation path, received power and total loss between two radio links.
based in 4 parameters, frequency, transmission power transmitter antenna gain and receiver antenna gain
```

celular_prediction.m
```bash
This script will calculate and plot a celular coverage of a base station with free space loss only (ignoring the terrain elevation) and with diffraction losses (considering the terrain elevation) based on the Epstein-Peterson method. It's possible to utilize other models like Okumura-Hata model and it can be extendable to use a loss matrix based in cluster area, like urban, rural, dense urban etc...
```

epstein_peterson.m
```bash
This function script calculate the diffraction loss based in the Epstein-Peterson method.
```

fresnelCS.m
```bash
This function script calculate the fresnel cosine and sine integrals. This script was made by Venkata Sivakanth Telasula. 

This script is optinal, it can be used in the link_calculation.m. I didn't not used it in my final code, i've used an aproximation method.
But if you wish to use it, just go to the link_calculation.m, remove/comment line #61 (add_loss=), and place this:

[FresnelC, FresnelS] = fresnelCS(Vo)
 add_loss = add_loss + -20*log10((1/sqrt(2))*sqrt((0.5 - FresnelC)^2 + (0.5 - FresnelS)^2));

```



