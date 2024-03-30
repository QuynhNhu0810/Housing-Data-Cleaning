
select *
from Portfolio.dbo.NashvilleHousing

--Standardize Date Format

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

-- Populate Property Address Data
Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--Breaking out Address into Address, City, State

Alter table NashvilleHousing
Add AddressSplit Nvarchar(255);

Update NashvilleHousing
set AddressSplit = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


Alter table NashvilleHousing
Add Statesplit Nvarchar(255);

Update NashvilleHousing
set Statesplit = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--OWNER ADDRESS SPLIT--

Alter table NashvilleHousing
Add Owner_City Nvarchar(255);

Update NashvilleHousing
set Owner_City  = Parsename(replace(OwnerAddress,',','.'),2)


Alter table NashvilleHousing
Add Owner_state Nvarchar(255);

Update NashvilleHousing
set Owner_state = Parsename(replace(OwnerAddress,',','.'),1)

Alter table NashvilleHousing
Add Owner_address Nvarchar(255);

Update NashvilleHousing
set Owner_address = Parsename(replace(OwnerAddress,',','.'),3)

--Change Y and N to Yes and No 

select Distinct(SoldAsVacant)
From dbo.NashvilleHousing


Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

--remove duplicates--
with cte as(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
From dbo.NashvilleHousing
)
delete 
from cte
where row_num > 1

--delete unused columns

alter table NashvilleHousing
drop column TaxDistrict, SaleDate, OwnerAddress, PropertyAddress