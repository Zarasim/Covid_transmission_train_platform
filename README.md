# covid-transmission-train-platform

## Introduction of the project

Transportation through trains is a common mean of travel by the general public throughout the globe. However, the extent of the risk of the Covid-19 disease transmission among train passengers has been not fully understood yet. Therefore, the formulation of an appropriate mathematical model can help assess that risk on the UK rail network. This work simulates with an agen-based model the passenger flow across the binary platform and explores how different commuter'position distributions affect the spread of the disease.

The main purpose of this simulation is to show that with an assigned seat in the ticket the number of infected commuters is lower than a scenario where random seat allocation is assigned. 

## Description of the Simulation 

The commuter's spatial distribution can be specified as Gaussian or uniform. In the former case, we assume that passengers are not provided with an assigned seat and tend to cluster at the entrance of the binary platform, whilst in the other scenario the ticket has an assigned seat and passengers tend to distributed evenly across the platofrm. 

The commuters have an initial probability of being infected by Covid-19 (red-filled) and are able to spread the disease to not-infected people (yellow-filled) within a specific distance from their position or through droplets released by sneezing during the route to the binary. In case those people get infected, they are considered asymptomatic (orange-filled) and cannot infect other healthy people. The simulation also accounts for passengers wearing a face mask, which affects the probability of infecting or being infected. 

Finally, other commuters access to the platform at a constant rate and their number follows a Poisson distribution. 


### Variables of the Simulation 

These are the variables reporting the probabilities described above:

probInitialInfected - probability that an initial passenger waiting for the train is infected by Covid-19;

probMask - probability that any passenger is wearing a face mask;

probInfectionMask - probability that an infected passenger wearing a face mask spreads the virus;

probInfectionNoMask - probability that an infected passenger not wearing a face mask spreads the virus;

probSneeze - probability that an infected passenger not wearing a face mask sneezes and release a droplet;

probInfectionSneeze - probability that a droplet infects sane passengers if they pass over it;

#### Color Properties

Fill:

Yellow: not infected

Orange: infected and asymptomatic (not able to transmit infection)

Red: infected (able to infect others through contact or droplets)

Stroke:

Black: no Mask

Blue: Mask

#### Debug mode

Circle around each person represent the area of collision where two or more people interact.

Green arrow: direction of velocity.


