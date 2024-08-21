select *
from PortfolioProject..NashvilleHousing

-- populate property address data
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
-- * finding null values in Property Address
select *
from PortfolioProject..NashvilleHousing
order by ParcelID
-- * finding that same Parcel ID will have same Property Address

-- joining housing data twice to fill null property address with exising parcel id's address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- update the table
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- breaking address to separate columns (address & city)
select SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

-- update with original table
alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(225);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(225);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

-- split owner address
select parsename(replace(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject..NashvilleHousing

-- update original table with splitted owner address
alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(225);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(225);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'),2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(225);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'),1)

-- change 'Y' and 'N' to Yes and No in "Sold as Vacant"
select distinct(SoldAsVacant), count(*)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by COUNT(*)

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes' 
    when SoldAsVacant='N' then 'No' 
    else SoldAsVacant end
from PortfolioProject..NashvilleHousing
where SoldAsVacant='Y'

-- update original table
update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes' 
    when SoldAsVacant='N' then 'No' 
    else SoldAsVacant end

-- remove duplicates
-- defining duplicate by same parcel id, property address, sale price, sale date and legal reference
with RowNumCTE as(
select *,
row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from PortfolioProject..NashvilleHousing
)
delete 
from RowNumCTE
where row_num > 1

-- delete unused columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict

alter table PortfolioProject..NashvilleHousing
drop column SaleDate




