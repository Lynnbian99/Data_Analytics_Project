SELECT * FROM Myporfolio_Lynn.nashville_housing;
-- change column format
alter table nashville_housing
modify column YearBuilt year;

-- Standard Date format
select SaleDate, str_to_date(SaleDate,'%M %d, %Y') as SaleDate
from nashville_housing;

update nashville_housing
Set SaleDate = str_to_date(SaleDate,'%M %d, %Y');

set sql_safe_updates=0;
-- Populate Property Address Data

update nashville_housing
set PropertyAddress = NULL
where PropertyAddress = '';

update nashville_housing
set 
ParcelID = NULLIF(ParcelID,''),
LandUse = NULLif(LandUse,''),
SaleDate = NULLif(SaleDate,''),
SalePrice = NULLif(SalePrice,''),
LegalReference = NULLif(LegalReference,''),
SoldAsVacant = NULLif(SoldAsVacant,''),
OwnerName = NULLif(OwnerName,''),
OwnerAddress = NULLif(OwnerAddress,''),
Acreage = NULLif(Acreage,''),
TaxDistrict = NULLif(TaxDistrict,''),
LandValue = NULLif(LandValue,''),
BuildingValue = NULLif(BuildingValue,''),
TotalValue = NULLif(TotalValue,''),
YearBuilt = NULLif(YearBuilt,''),
Bedrooms = NULLif(Bedrooms,''),
FullBath = NULLif(FullBath,''),
HalfBath = NULLif(HalfBath,'');

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
from nashville_housing a
join nashville_housing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL;

update nashville_housing a
join nashville_housing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
set a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
where a.PropertyAddress is NULL;

set sql_safe_updates =0;
select*from nashville_housing;

-- Breaking out PropertyAddress into Individual columns (Address, City, State)
select PropertyAddress,
substring_index(PropertyAddress, ' ', 4) as Address,
substring_index(PropertyAddress, ',', -1) as State
from nashville_housing; 

alter table nashville_housing
add column Address varchar(255);

update nashville_housing
set Address = substring_index(PropertyAddress, ' ', 4);

alter table nashville_housing
add column State varchar(255);

update nashville_housing
set State = substring_index(PropertyAddress, ',', -1);


-- clean data OwnerName, ownerAddress
select OwnerAddress from nashville_housing;

select 
substring_index(OwnerAddress, ',' , 1), 
substring_index(substring_index(OwnerAddress,',', 2), ',', -1),
substring_index(OwnerAddress, ',' , -1) 
from nashville_housing;

alter table nashville_housing
add column OwnerSplitAddress varchar(255);

update nashville_housing
set OwnerSplitAddress = substring_index(OwnerAddress, ',' , 1);

alter table nashville_housing
add column OwnerSplitCity varchar(255);

update nashville_housing
set OwnerSplitCity = substring_index(substring_index(OwnerAddress,',', 2), ',', -1);

alter table nashville_housing
add column OwnerSplitState varchar(255);

update nashville_housing
set OwnerSplitState = substring_index(OwnerAddress, ',' , -1);

-- change Y and N to yes and no 
select SoldAsVacant
from nashville_housing group by SoldAsVacant;

select 
	case  
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end as SoldAsVacant
from nashville_housing;

update nashville_housing
set SoldAsVacant = case  
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end;
    
set sql_safe_updates = 0;

-- Remove duplicates

select* from nashville_housing;

with RankingCTE as (
select*,
row_number()over 
(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) as Ranking
from nashville_housing)

select* 
from rankingCTE
where ranking >1
order by UniqueID asc;


with RankingCTE as (
select*,
row_number()over 
(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) as Ranking
from nashville_housing)

delete from nashville_housing
where UniqueID in (
select UniqueID
from RankingCTE
where Ranking > 1);

Set sql_safe_updates = 0;
-- delete unused columns
select * from nashville_housing;

alter table nashville_housing
drop column OwnerAddress;
alter table nashville_housing
drop column TaxDistrict;


































