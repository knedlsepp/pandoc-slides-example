% SEAMLESS - Precipitation analysis

# What do we wish for from a good analysis software?

## Wishlist

- Accuracy of results
- Speed
- Reproducibility
- Ease of use / setup
- Flexibility in
    - Domain
    - Resolution
    - Amount / format of input data
    - Output format
- Easy to understand, maintain, improve

# Status April
## Accuracy

- Good. (unknown?)

## Speed

- Fine for production
- How about reanalysis for cross validation?

## Reproducibility

- Temporary observation files
- Are we confident for reanalysis?
- What must be computed so that the results are reproducible? One/Two hours before?
- Can we compute 31.06.2016-06:00 after 01.01.2016-06:00 with confidence of using wrong input data?

## Ease of use / setup
- Good

## Flexibility
- Domain: Fixed
- Resolution: Fixed
- Amount / format of input data: 
    - Stations: flexible with preprocessing step
    - Radars: hardcoded in analysis by name
- Output Data:
    - No self describing formats: Just 701*401 floats, rowwise/columnwise? big-/little-endian?
    - No georeferencing

## Easy to understand, maintain, improve

- Different versions all intertwined with varying functionality
- SVN
    - 15m / 15m_cz / 15m_hyd / 15m_sk 
    - 1h 
    - 24h / 24h_cz / 24h_sk

vvhmod-dev:~mgruppe:

- INCA 
- INCA4ROAD 
- INCA_1h 
- INCA_1h_rerun 
- INCA_24h 
- INCA_CZ 
- INCA_DEV 
- INCA_EX 
- INCA_HYD 

## 

- INCA_L 
- INCA_L_ARO 
- INCA_L_HYD 
- INCA_L_rerun 
- INCA_MEDIA 
- INCA_RU 
- INCA_SK 
- INCA_SVN


## Structural changes made
<!-- Show gource -->
<!-- Show differences in analysis -->

## Status October

### Accuracy

- No (scientific) changes
- Some differences in results due to 


241 STATIONS MOVED IN DATABASE!!!


## API Showcase

### Central class `SpatialReferenceSystem` and `SpatialPoint`

```C++
auto inca_ref = SpatialReferenceSystem{"+init=epsg:31287 +no_defs"}
auto longlat = SpatialReferenceSystem{"+proj=longlat +el=WGS84 +datum=WGS84 +no_defs"};
auto vienna = longlat(16.372778, 48.209206, 180.);
auto xyz = inca_ref.coordinates_of(vienna);

CHECK(xyz[0] == Approx(625.84308) && 
      xyz[1] == Approx(483.29598) &&
      xyz[2] == Approx(180.));
```

--------------------


### Computing distances between points

```C++
auto villach = longlat(13.8506, 46.6086, 0.);
auto linz = longlat(14.2858, 48.3069, 0);
CHECK(linz.horizontal_distance_in_meters(villach) ==
      Approx(191646.074).epsilon(0.2e-2));
```


### Bearing (angle to north) can be computed
```C++
auto center = longlat(0., 0., 0.);
auto east = longlat(1., 0., 0);
CHECK(center.bearing(east) == Approx(90.));
```

## Fields

- Model state of the atmosphere/ground.
- A function which returns a value for a given SpatialPoint.

```
auto degrees = current_temperature(vienna);
```


### Technical Implementations


- GenericField
- PiecewiseConstantRegularProjectedField
- InverseDistanceWeightedField
- NearestNeighborField

## Class GenericField


For a SpatialPoint `p`, 

```C++
logarithm_of_height = GenericField<double>{[](SpatialPoint p){
   auto xyz = longlat.coordinates_of(p);
   return xyz[2];
}};
```




## Class RegularProjectedGrid
```C++
auto ref = SpatialReferenceSystem{"+init=epsg:31287 +no_defs"};
auto saphir_domain = RegularProjectedGrid{ref, linspace(20., 721, 701), linspace(220, 621, 401)};
auto p = longlat(16.37277, 48.20920, 0);
if (saphir_domain.contains(p)){
   cout << "Der Punkt liegt innerhalb der Domain."
}
```


## Class P0Field = PiecewiseConstantRegularProjectedField

```C++
auto grid = RegularProjectedGrid{ref, {-2, 0, 2}, {-2, 0, 2}};
auto data = Array<double, 2>{{1, 2}, {3, 4}};
auto field = P0Field<double>{grid, data};
```



### Evaluating field at given location
```C++
auto p = longlat(16.37277, 48.20920, 0);
auto value = field(p);
```

### Field supports arithmetic
```C++
auto radar_composite = P0Field<double>{...};
radar_composite = 100*radar_composite + 3;
```


## Class InverseDistanceWeightedInterpolator


```C++
auto ref = SpatialReferenceSystem{"+proj=longlat +el=WGS84 +datum=WGS84 +no_defs"};
auto points = std::vector<SpatialPoint>{{ref, 16.1, 40.},
                                        {ref, 15.7, 41.}};
auto values = std::vector<double>{1.3, 0.5};
auto field = InverseDistanceWeightedInterpolator<double>{points, values};
```

### Field can be evaluated

```C++
auto p = longlat(16.37277, 48.20920, 0);
auto value = field(p);
```

## class GDALReader

```C++
auto reader = GDALReader{"/data/topography_central_europe.tiff"};
auto orography = reader[0];
```

### class L2Projector

- Converts any Field to a P0Field (mathematically an L2Projection) 



# Outlook

- Integration of Tundra Radar-Composite:  
- Replace methods that can only work in Austria
- Accuracy:
   - D

