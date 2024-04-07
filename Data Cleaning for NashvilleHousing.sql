/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProjectSQL.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProjectSQL.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProjectSQL.dbo.NashvilleHousing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectSQL.dbo.NashvilleHousing a
Join PortfolioProjectSQL.dbo.NashvilleHousing b
    On a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectSQL.dbo.NashvilleHousing a
Join PortfolioProjectSQL.dbo.NashvilleHousing b
    On a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
	where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProjectSQL.dbo.NashvilleHousing
--order by ParcelID


--selecting a specific value and popstition in the PropertyAddress
select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
As Address 
from PortfolioProjectSQL.dbo.NashvilleHousing

--selecting the 1st, second the second value in the PropertyAddress
select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
As Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,
LEN(PropertyAddress)) As Address 

from PortfolioProjectSQL.dbo.NashvilleHousing


 --when we separete 2 values from 1 column, we have to create 
 -- 2 new columns for those values.

 ALTER TABLE NashvilleHousing
Add PropertySplitAddress Varchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX
(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Varchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX
(',', PropertyAddress)+1,LEN(PropertyAddress))

select * 
from PortfolioProjectSQL.dbo.NashvilleHousing

-- Splitting values in the OwnerAddress

select OwnerAddress 
from PortfolioProjectSQL.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

from PortfolioProjectSQL.dbo.NashvilleHousing

--Adding columns for the sepatated values
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Varchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.')
, 3)

ALTER TABLE NashvilleHousing
Add OnwnerSplitCity Varchar(255);

update NashvilleHousing
set OnwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.')
, 2)

ALTER TABLE NashvilleHousing
Add OnwnerSplitState Varchar(255);

update NashvilleHousing
set OnwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.')
 , 1)

 select * 
from PortfolioProjectSQL.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProjectSQL.dbo.NashvilleHousing

--unique update stetement

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProjectSQL.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- identify duplicate rows

WITH RowNumCTE As(
select *,
      ROW_NUMBER() over (
	  partition by ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   order by 
				     UniqueID
					 )row_num
from PortfolioProjectSQL.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num >1
order by PropertyAddress

--Now delete we delete them

WITH RowNumCTE As(
select *,
      ROW_NUMBER() over (
	  partition by ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   order by 
				     UniqueID
					 )row_num
from PortfolioProjectSQL.dbo.NashvilleHousing
--order by ParcelID
)
delete 
from RowNumCTE
where row_num >1
--order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProjectSQL.dbo.NashvilleHousing

Alter table PortfolioProjectSQL.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProjectSQL.dbo.NashvilleHousing
Drop column SaleDate

























