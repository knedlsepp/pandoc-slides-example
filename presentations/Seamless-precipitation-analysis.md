% SEAMLESS - Precipitation analysis


## 


**What I want to show you today**

- Changes I made over the course of the last 6 months
- What impact did the refactoring make on the the code
    - Numerically
    - Usability




# What do we wish for from a good analysis software?

## 

**Wishlist**

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

##

**Where do we stand now**

## 

**Accuracy**

- (Pretty much) equal results as INCA (was actually the hardest part of this work!)
- How good are we really?
    - Built in cross-validation binary for easy verification!

## 

**Speed**

- Same as before for gridded analysis
- Enormous potential for boosting speed in station-based analysis for verification
    - Core components don't need to compute entire grid, but can be evaluated station based!
    - What if we could compare two different analysis methods for a 10 year dataset in a couple of days?
    - Bottleneck is only the IO for gridded radar data / Should we consider using PostGIS?
    - Current height-correction and radar-composite algorithms do not yet support it

## 

**Reproducibility**

- INCA heavily relies on temporary files being changed by multiple scripts/binaries
    - Temporary files: Gone
- Was necessary to compute INCA 10:30, ... 11:45 to compute INCA 12:00
    - not anymore!
- Changes in stationlist/blacklist/database still problematic. We need a better DB scheme for this!


## 

**Ease of use / setup**

- Initial setup for each developer now requires libraries to be installed on the system
    - But I used only libraries which are easily user-installable via conda!
- No more need to compile for each user, due to removal of temporary files
    - Single install per machine due to single binary
- Zero install for other users via RESTful API: http://vsaphir/api/analysis?t="2016-05-03 03:00"


## 

**Flexibility**

- Domain: Was fixed; now generic
- Resolution: Was fixed; now generic
- Amount / format of input data:
    - Gridded data: Large amount of newly supported file formats
    - Stations: Additional optional direct access to Sybase
    - Radars: Still hardcoded. Next step: Tundra library
- Output Data:
    - Initially: No self describing formats: Just 701*401 floats, rowwise/columnwise? big-/little-endian?
    - Now: Georeferenced self-describing data thanks to GDAL

## 

**Easy to understand, maintain, improve**

Difficult to measure objectively, but

- Used to be: 
    - mixture of multiple bash/fortran/C programs
    - one binary per setup (AUT/SK/CZ/HYD)
- Now:
    - Single binary for multiple domains/resolutions

- Comprehensive suite of unit tests, which proof correctness and doubles as "executable documentation"

##

- INCA2 nwpgrib2inca.cpp: **2138 LOC** in a single file!
- Core components of SAPHIR:
Array, Field, GDALReader, GDALWriter, GenericField, IDWInterpolator, NearestNeighborInterpolator, POField,
QuadratureRule, Radar, RegularGrid, ScatteredInterpolatorBase, SpatialPoint, SpatialReferenceSystem, Station, 
TimePoint: **1467 LOC**

- Entire SAPHIR precipitation analysis: **3443 LOC**
- Entire INCA precip code: ~13000 LOC C+Fortran, ~11000 LOC Bash, ~4000 LOC Makefiles
- Entire INCA2 UV/T/Q code: **17037 LOC**
## 

**Structural changes made**
<!-- Show gource -->
<!-- Show differences in analysis -->

## 

241 STATIONS MOVED IN DATABASE!!!




## API-Showcase

# Locations

##

**`SpatialPoint` and `SpatialReferenceSystem`**


- A `SpatialPoint` models a point on (or above) earth
- A `SpatialReferenceSystem` models a horizontal and vertical coordinate system


## 


**Coordinates**

Given a `SpatialPoint`, we can compute the coordinates with respect to a specific `SpatialReferenceSystem`

```C++
auto inca_ref = SpatialReferenceSystem{"+init=epsg:31287 +no_defs"}
auto longlat = SpatialReferenceSystem{"+proj=longlat +el=WGS84 "
                                      "+datum=WGS84 +no_defs"};
auto vienna = longlat(16.372778, 48.209206, 180.);
auto xyz = inca_ref.coordinates_of(vienna);

CHECK(xyz[0] == Approx(625.84308) && 
      xyz[1] == Approx(483.29598) &&
      xyz[2] == Approx(180.));
```

##

**Distances**

The distance between two points can be computed using the member function `horizontal_distance_in_meters`

```C++
auto villach = longlat(13.8506, 46.6086);
auto linz = longlat(14.2858, 48.3069);
CHECK(linz.horizontal_distance_in_meters(villach) == Approx(191646));
```

---

##

**Bearing**

The angle between two points and the northpole can be computed using `bearing`

```C++
auto vienna = longlat(16.372, 48.209206.);
auto somewhere = longlat(20., 48.209206.);
CHECK(vienna.bearing(somewhere) == Approx(90.));
```

# Fields

##

**Class `Field` and derived classes**

- Model state of earth's atmosphere or surface.
- A function which returns a value for a given point in space.
- Can be evaluated using a `SpatialPoint`
- Enables us to program in more abstract terms than `data[i][j][k]`


```C++
auto degrees = temperature_field(vienna);
```

---

## 


**Implemented classes**

- `GenericField`
- `PiecewiseConstantRegularProjectedField`
- `InverseDistanceWeightedInterpolator`
- `NearestNeighborInterpolator`

---


## 

**GenericField**

- Most flexible version of `Field`
- Can wrap both data and/or a mathematical function

```C++
logarithm_of_height = GenericField<double>{[](SpatialPoint p){
   auto xyz = longlat.coordinates_of(p);
   return log(xyz[2]);
}};
```

---


## 

**`PiecewiseConstantRegularProjectedField`**

- Models 2D/3D gridded data ("Georeferenced array")
- Can be used with *any* projection
- Can be used with *any* grid size
- Can handle 3D volume data
- Based on `RegularProjectedGrid`

##

**`RegularProjectedGrid`**

- Models a regular rectangular grid
- Is defined by:
    - A `SpatialReferenceSystem`
    - The coordinates of the grid's cell's corners


```C++
auto ref = SpatialReferenceSystem{"+init=epsg:31287 +no_defs"};
auto INCA_domain = RegularProjectedGrid{ref, linspace(20., 721, 702),
                                             linspace(220, 621, 402)};
auto p = longlat(16.37277, 48.20920, 0);
if (INCA_domain.contains(p)){
   cout << "The point lies inside of the domain."
}
```


---

## 

**`PiecewiseConstantRegularProjectedField`**

- Defined by 
    - a `RegularProjectedGrid` 
    - a value for each grid cell

```C++
auto grid = RegularProjectedGrid{ref, {-2, 0, 2}, {-2, 0, 2}};
auto data = Array<double, 2>{{1, 2}, {3, 4}};
auto field = P0Field<double>{grid, data};
```

---

## 

**Evaluating field at given location**


```C++
auto p = longlat(16.37277, 48.20920, 0);
auto value = field(p);
```


---

## 

**`P0Field` supports arithmetic operations**

- Can add/subtract/divide/multiply all values in one line instead of using a loop

```C++
auto radar_composite = P0Field<double>{/* DATA */};
radar_composite = 100*radar_composite + 3;
```

----

## 

**`InverseDistanceWeightedInterpolator`**

- Inverse distance weighting of irregularly distributed values
- Defined by pairs of locations and values
- Can be evaluated at single locations without any need for grids!

```C++
auto longlat = SpatialReferenceSystem{"+proj=longlat +el=WGS84 "
                                      "+datum=WGS84 +no_defs"};
auto points = std::vector<SpatialPoint>{longlat(16.1, 40.),
                                        longlat(15.7, 41.)};
auto values = std::vector<double>{1.3, 0.5};
auto field = InverseDistanceWeightedInterpolator<double>{points,
                                                         values};
```

---------


## 

**`NearestNeighborInterpolator`**

- Similar to `IDWInterpolator`, but returns closest value

```C++
auto points = std::vector<SpatialPoint>{longlat(16.1, 40.),
                                        longlat(15.7, 41.)};
auto values = std::vector<double>{1.3, 0.5};
auto field = NearestNeighborInterpolator<double>{points,
                                                 values};
```

---------

## 

**`L2Projector`**

- Converts any `Field` to a `P0Field` (via the canonical $L^2$-Projection, i.e. average value within a cell)
- Is defined by
    - A grid 
    - an optional quadrature rule

```C++
auto grid = RegularProjectedGrid{ref, x, y, z};
auto projector = L2Projector{grid};
auto field = NearestNeighborInterpolator<double>{points, values};
auto gridded_field = projector(field);
```

# Input/Output

##

**`GDALReader` and `GDALWriter`**

- Can read/write in any format supported by GDAL (over 140)
    - GRIB, netcdf, hdf5, jpeg, geotiff, ascii, BIL, ...
- Georeferenced! (Produces/consumes `P0Field`s instead of plain arrays)

```C++
auto reader = GDALReader{"/data/orography_central_europe.tiff"};
auto orography = reader[0];
auto vienna = longlat(16.372778, 48.209206);
auto vienna_height = orography(vienna);
```

```C++
auto analysis = do_very_complicated_analysis();
GDALWriter{"analysis.tiff"}.write(analysis);
```

# Other abstractions

##

- `Radar` / `Station`
- `RadarMeasurement` / `PrecipitationMeasurement`
- `DataSource`
    - `SybaseDataSource`
    - `ArchivedINCADataSource`
    - `MemoryLoadedDataSource`


## 

**Outlook**

Next steps:
- Integration of nowcasting step (extrapolation)
- Replace methods that can only work in Austria
    - Height correction (Valley floor surface + hard coded areas)
    - Radar composite with hard coded radars
        - Integration of Tundra Radar-Composite

Further possible routes
- Accuracy:
   - Implement different interpolation methods
- Probabilistic analysis
- Huge potential in simplifying the UV/T/Q code!


