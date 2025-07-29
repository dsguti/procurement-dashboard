copy (
    select year(t.creation_date) as year_creation, 
    b.buyer_unit_commune as commune,
    any_value(b.buyer_unit_region) as region,
    b.buyer_sector as sector,
    any_value(p.Poblacion) as pop,
    count(distinct t.tender_id) as n,
    n / (pop / 1000) as n_per_1000hab
    from tenders t
    join buyers b on t.buyer_unit_id = b.buyer_unit_id
    join population p on b.buyer_unit_commune = p.buyer_unit_commune
    where year_creation >= 2007
    group by year_creation, commune, sector
    order by year_creation, commune, sector
) to 'src/lib/data-years-communes-regions-municpalities.parquet';
