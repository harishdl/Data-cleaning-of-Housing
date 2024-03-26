
----------------------------------------------------------------------------------------------------
----First Let's Fix Date
Select SaleDate, convert(date,SaleDate)
From Nashvillehousing

UPDATE Nashvillehousing
SET SaleDate = convert(date,SaleDate)
----Not Able to update Sale Date


ALTER TABLE Nashvillehousing
ADD SaleDate1 Date
----- Added New column And updated Date in Date format
UPDATE Nashvillehousing
SET SaleDate1 = convert(date,SaleDate)

-----------------------------------------------------------------------------------------------------

----- Lets Reomve Nulls and update them

select a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress
from Nashvillehousing a
join Nashvillehousing b
	on a.ParcelId = b.ParcelId
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

/* trying to update the PropertyAddress column in the Nashvillehousing table 
   by filling in missing values with corresponding values from another row 
   where the ParcelID matches, but the UniqueID values are different /*

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------- Updated Nulls From Property Address

---------------------------------------------------------------------------------------------------------

---Let's Break Property Address

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Property_address
,substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Property_city
From Nashvillehousing

---- Now update Table 

alter table Nashvillehousing
add Property_address nvarchar(255)

update Nashvillehousing
set Property_address = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table Nashvillehousing
add Property_city nvarchar(255)

update Nashvillehousing
set Property_city = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

---- Breaking OwnersAddress

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
from Nashvillehousing

alter table Nashvillehousing
add Owner_Address nvarchar(255)
update Nashvillehousing
set Owner_Address =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table Nashvillehousing
add Owner_city nvarchar(255)
update Nashvillehousing
set Owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


alter table Nashvillehousing
add Owner_state nvarchar(255)
update Nashvillehousing
set Owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

----------------------------------------------------------------------------------------------------

--------Update Sold AS Vacant 

select distinct(SoldAsVacant),count(SoldAsVacant)
from Nashvillehousing
Group by SoldAsVacant
order by 2

UPDATE Nashvillehousing
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END;
----------------------------------------------------------------------------------------------------
-----Remove Duplicates
with Rownumcte as(
select *,
		ROW_NUMBER() over(
		partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 order by
						UniqueID
						) Row_num
from Nashvillehousing
)
Delete
from Rownumcte
where Row_num > 1

------------------------------------------------------------------------------------------------------
-----Deleting unused columns
select *
from Nashvillehousing
alter table Nashvillehousing
drop column PropertyAddress,OwnerAddress,TaxDistrict, 

--------------------------------------------------------------------------------------------------------