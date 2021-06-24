--Project #3 (Cleaning Data in SQL)

select 
    * 
from 
    PortfolioProject.dbo.Nashvillehousing

----------------------------------------------------------------------------------------------------------------------
-- Standardize Sale Date Format

select 
    SaleDateConverted
from
    PortfolioProject.dbo.Nashvillehousing


-- adds a new column call "SaleDateConverted"
    -- alter table PortfolioProject.dbo.Nashvillehousing
    -- add SaleDateConverted Date; 

-- SalesDateConverted column = convert(date, saledates)
    -- Update PortfolioProject.dbo.Nashvillehousing
    -- set SaleDateConverted = convert(Date, SaleDate)

----------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data 

-- with temp as (
--     select
--         distinct ParcelID,
--         PropertyAddress
--     from 
--         PortfolioProject.dbo.Nashvillehousing
--     where 
--         PropertyAddress is not null
-- )

-- select
--     nv.*,
--     t.PropertyAddress as "PopulatedPropertyAddress"
-- from 
--     PortfolioProject.dbo.Nashvillehousing as nv
-- left join 
--     temp as t on nv.ParcelID = t.ParcelID
-- order by 
--     nv.parcelid;

select 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    isnull(a.PropertyAddress, b.PropertyAddress)
from 
    PortfolioProject.dbo.NashvilleHousing a 
join PortfolioProject.dbo.NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where 
    a.PropertyAddress is null


-- Updated the table where a.PropertyAddress is null with b.PropertyAddress
update a 
set Propertyaddress = isnull(a.PropertyAddress, b.PropertyAddress)
from 
    PortfolioProject.dbo.NashvilleHousing a 
join PortfolioProject.dbo.NashvilleHousing b on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where 
    a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------
--Breaking out Property & Owner Address into Individual Columns (Address, City, State)

-- Test to see how we split Property Address to their own columns
select
    substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as "address",
    substring(PropertyAddress, Charindex(',', PropertyAddress) +1, len(PropertyAddress)) as "city"
from 
    PortfolioProject.dbo.NashvilleHousing

-- Create a table for split address
alter table PortfolioProject.dbo.Nashvillehousing
add PropertySplitAddress Nvarchar(255); 

-- Fill the table with updated split address values
Update PortfolioProject.dbo.Nashvillehousing
set PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

-- Create a table for split city
alter table PortfolioProject.dbo.Nashvillehousing
add PropertyCitySplit Nvarchar(255); 

-- Fill the table with updated split city values
Update PortfolioProject.dbo.Nashvillehousing
set PropertyCitySplit = substring(PropertyAddress, Charindex(',', PropertyAddress) +1, len(PropertyAddress))

-- 2 new columns (PropertySplitAddress, PropertyCitySplit) should be added to the table now
select * from  PortfolioProject.dbo.NashvilleHousing

-------

-- parsename and replace to separate into different columns
select 
    Owneraddress,
    parsename(replace(OwnerAddress, ',', '.'), 3),
    parsename(replace(OwnerAddress, ',', '.'), 2),
    parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

-- create new split columns and update those columns with parsename data
alter table PortfolioProject.dbo.NashvilleHousing
add OwnersplitAddress Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
set OwnersplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnersplitCity Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
set OwnersplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject.dbo.NashvilleHousing
add Ownersplitstate Nvarchar(255);

Update PortfolioProject.dbo.Nashvillehousing
set Ownersplitstate = parsename(replace(OwnerAddress, ',', '.'), 1)

----------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Count distinct "Y", "N", "Yes", "No" values
select 
    distinct soldasvacant,
    count(SoldAsVacant) as "countsoldasvacant"
from 
    PortfolioProject.dbo.NashvilleHousing
group by
    SoldAsVacant

-- Case statement to update the table
select 
    SoldAsVacant,
    case 
        when SoldAsVacant = 'Y' then 'Yes'
        when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
    end
from 
    PortfolioProject.dbo.NashvilleHousing
order by 
    1

-- Update Columns with the case statement
Update PortfolioProject.dbo.Nashvillehousing
SET SoldAsVacant = case 
        when SoldAsVacant = 'Y' then 'Yes'
        when SoldAsVacant = 'N' then 'No'
        else SoldAsVacant
    end

----------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

-- Temp table holds all duplicate values
with RowNumCTE as (
    select 
        *,
        row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by uniqueid) as row_num
    from 
        PortfolioProject.dbo.NashvilleHousing
    )

-- delete all duplicate values from temp table
delete from 
    RowNumCTE
where
    row_num > 1

----------------------------------------------------------------------------------------------------------------------

-- Delete Unused columns

-- Select rows from a Table or View 'TableOrViewName' in schema '*

select
    *
from 
    PortfolioProject.dbo.NashvilleHousing

-- Drop unncessary data
alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate