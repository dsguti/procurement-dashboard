---
theme: dashboard
toc: false
sql:
  tenders: ./lib/count-commune-year.parquet
---

# Tenders by Commune and Year

```js
const communes = await sql`select distinct commune, sum(n) as total from tenders group by commune order by total desc`;
const munic = view(Inputs.select(communes, {label: "Commune"}))
```

```sql id=tenders
select * from tenders
where commune = ${munic.commune} and t > 2006
order by commune, t;
```

```js
function communePlot(data, {width} = {}) {
  return Plot.lineY(tenders, {x: "t", y: "n"}).plot({y: {grid: true}});
}
```


<div class="grid grid-cols-2">
  <div class="card">${Inputs.table(tenders)}</div>
  <div class="card">${resize((width) => communePlot(tenders, {width}))}</div>
</div>
