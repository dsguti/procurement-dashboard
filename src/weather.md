---
theme: dashboard
toc: false
sql:
  tenders: ./lib/data-years-communes-regions-municpalities.parquet
---

```js
const communes = await sql`select distinct commune, region, sum(n) as total from tenders group by commune, region order by total desc`;
const region = await sql`select distinct region, sum(n) as total from tenders group by region order by total desc`
const sectors = await sql`select distinct sector, sum(n) as total from tenders group by sector order by total desc`
```

```js
const chl = await FileAttachment("./lib/CHL-3.json").json().then(data => ({
  type: "FeatureCollection",
  features: data.features.filter(d => d.properties.NAME_2 != "IsladePascua").filter(d => d.properties.NAME_1.toLowerCase() === dropdownViewRegion)
}));


const filteredCommunes = communes.toArray().filter(
  c => c.region?.toLowerCase() === dropdownViewRegion.toLowerCase()
);


const chlC = await FileAttachment("./lib/CHL-1.json").json().then(data => ({
  type: "FeatureCollection",
  features: data.features//.filter(d => d.properties.NAME_1.toLowerCase() === dropdownViewRegion)
}));
```

# Tenders by Commune and Year

```js
function communeMapPlot(data, {height, selectedCommune} = {}) {
  return Plot.plot({
    projection: {
      type: "mercator",
      domain: data,
      inset: 2
    },
    height: height,
    width: height,
    marks: [
      // Plot.geo(d3.geoGraticule().step([1, 1])(), { strokeOpacity: 0.1 }),
      Plot.geo(data, {
        fill: d => d.properties.NAME_3.toLowerCase() === selectedCommune ? "steelblue" : "lightgrey",
        stroke: "white",
        strokeWidth: 0.5,
        tip: true,
        channels: {
          Region: d => d.properties.NAME_1,
          Commune: d => d.properties.NAME_3,
        }
      }),
    ]
  });
}
```

```js
function countryPlot(data, {height, selectedRegion} = {}) {
  return Plot.plot({
    projection: {
      type: "mercator",
      domain:  d3.geoCircle().center([-71, -39]).radius(7)(),
      inset: 2
    },
    height: height,
    width: height * 0.35,
    marks: [
      // Plot.geo(d3.geoGraticule().step([1, 1])(), { strokeOpacity: 0.1 }),
      Plot.geo(data, {
        fill: d => d.properties.NAME_1.toLowerCase() === selectedRegion ? "steelblue" : "lightgrey",
        stroke: "white",
        strokeWidth: 0.5,
        tip: true,
        channels: {
          Region: d => d.properties.NAME_1,
        }
      }),
    ]
  });
}
```

<!-- ```js -->
<!-- const commune = Mutable("Arauco"); -->
<!-- const setCommune = (value) => commune.value = value; -->
<!-- ``` -->

```js
const regionDropdown = Inputs.select(region, {
  label: "Select Region",
  value: "Santiago",
  format: d => d.region,
  valueof: d => d.region
});

const dropdownViewRegion = view(regionDropdown);

// setCommune(dropdownView);
```

```js
const communeDropdown = Inputs.select(filteredCommunes, {
  label: "Select Commune",
  value: "Santiago",
  format: d => d.commune,
  valueof: d => d.commune,
});

const dropdownView = view(communeDropdown);

// setCommune(dropdownView);
```

```js
const sectorDropdown = Inputs.select(sectors, {
  label: "Select Sector",
  value: "FFAA",
  format: d => d.sector,
  valueof: d => d.sector,
});

const dropdownSectorView = view(sectorDropdown);

// setCommune(dropdownView);
```

```js
const mapPlot = communeMapPlot(chl, {
  height: 250,
  selectedCommune: dropdownView
});

const mapCommuneView = view(mapPlot);
```

```js
const mapCountryPlot = countryPlot(chlC, {
  height: 1000,
  selectedRegion: dropdownViewRegion
});

const mapCountryView = view(mapCountryPlot);
```


```js
function regionLinePlot(data, {width, regionName} = {}) {
  return Plot.lineY(data, {x: "year_creation", y: "n"}).plot({
    y: {grid: true},
    title: "Number of yearly tenders in " + dropdownViewRegion
  });
}
```

```js
function communeLinePlot(data, {width, communeName} = {}) {
  return Plot.lineY(data, {x: "year_creation", y: "n"}).plot({
    y: {grid: true},
    title: "Number of yearly tenders in " + dropdownView
  });
}
```

```js
function communeSectorLinePlot(data, {width, communeName} = {}) {
  return Plot.lineY(data, {x: "year_creation", y: "n"}).plot({
    y: {grid: true},
    title: "Number of yearly tenders in " + dropdownView + " in sector " + dropdownSectorView
  });
}
```

```sql id=tendersRegionTotal
select region, year_creation, cast(sum(n) as int) as n from tenders
where region = ${dropdownViewRegion} and year_creation > 2006
group by year_creation, region
order by year_creation, region;
```
```sql id=tendersCommuneTotal
select commune, year_creation, cast(sum(n) as int) as n from tenders
where commune = ${dropdownView} and year_creation > 2006
group by year_creation, commune
order by year_creation, commune;
```
```sql id=tendersSector
select commune, year_creation, cast(sum(n) as int) as n from tenders
where commune = ${dropdownView} AND sector = ${dropdownSectorView} and year_creation > 2006
group by year_creation, commune
order by year_creation, commune;
```


<!-- ```js
display(mapCountryView.properties.NAME_1);
``` -->



<style>
.map-container .card {
  background: transparent;
  border: none;
  box-shadow: none;
}
</style>

<div class="grid grid-cols-4 grid-rows-3">
<!-- country map section -->
    <div class="map-container grid-colspan-1 grid-rowspan-3" style="display: flex; align-items: center; justfiy-center: center;" >
      <div class="card">
        ${mapCountryPlot}
      </div>
    </div>

  <div>
        ${regionDropdown}
        ${communeDropdown}
        ${sectorDropdown}
  </div>

  <div class="card grid-colspan-1 grid-rowspan-1">
    ${resize((width) => regionLinePlot(tendersRegionTotal, {width}))}
  </div>

  <div class="card grid-colspan-1 grid-rowspan-1"> </div>
  
  <div style="display: flex; align-items: center; justify-content: center;">
    ${mapPlot}    
  </div>

  <div class="card grid-colspan-1 grid-rowspan-1"> 
  ${resize((width) => communeLinePlot(tendersCommuneTotal, {width}))}
  </div>

  <div class="card grid-colspan-1 grid-rowspan-1"> </div>

  <div class="card grid-colspan-1 grid-rowspan-1"></div>
  
  <div class="card grid-colspan-1 grid-rowspan-1">
    ${resize((width) => communeSectorLinePlot(tendersSector, {width}))}
  </div>
  
  <div class="card grid-colspan-1 grid-rowspan-1"> </div>
</div>

