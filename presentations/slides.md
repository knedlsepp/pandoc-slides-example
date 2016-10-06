<<<<<<< Updated upstream
% Was bisher geschah...

# Geschehen 

## 

- Liste
- Liste


# Klassendiagramme

## Geographische Abstraktionen

##




# API-Showcase

## 

Ein räumliches Bezugssystem `ref`

```C++
auto ref =
    SpatialReferenceSystem{"+proj=longlat +el=WGS84 "
                           "+datum=WGS84 +no_defs"};
```

##

Ein Punkt auf der Erde bezüglich `ref`

   
```C++
auto p = ref(16.3, 48.2, 0);
```

##
Koordinaten eines Punktes bezüglich eines beliebigen SRS

```C++
auto inca_ref = SpatialReferenceSystem{"+init=epsg:31287 +no_defs"};
auto coords = inca_ref.coordinates_of(p);
```

------------------

# Horizontal

## Vertikal

## Vertikal 2
![picture of spaghetti](https://upload.wikimedia.org/wikipedia/commons/3/33/Spaghettata.JPG)

## Vertikal 3 {data-background="./4_diff.png"}

------------------
=======
% Höhenkorrektur
>>>>>>> Stashed changes

# Vergleich

## 

![](./2_with.png)
![](./3_without.png)


##

![](./4_diff.png)

------------------

# Gradient

## 

![](5_orograd.png)

##
![](6_orograd-changed.png)


- Get in bed
- Count sheep

# Was bisher geschah

## foo

- 15min Niederschlagsanalyse

## Maximen:

- The best code is no code at all
- Zehn mal mehr Code => Zehn mal so viele Bugs
- Zehn mal mehr Code => Zehn mal so lange um ihn zu verstehen
- Es muss möglich sein einen Bug von einem Feature zu unterscheiden
- Dazu ist es nötig, dass aus dem Namen und den Parametern der Funktion klar hervorgeht, was passieren soll


## Quiz
Was sollen folgende Funktionen bewirken

- `daycorr(RM)`
- `sp_correction(RM)`
- `w_inca(10.)`
- `make_snow()`




