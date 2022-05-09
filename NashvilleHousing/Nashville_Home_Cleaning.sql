--Cleaning Data Nashville Housing

Select *
FROM [Porfolio Project].dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Porfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------------


/* Populate Property Address Data to fill Nulls

Looking at the query below, it seems there are null property addresses that could be filled using a common Parcel ID from an entry that contains the address*/
Select *
From [Porfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


--Using a self join on the Parcel ID in order to fill Null Addresses
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Porfolio Project].dbo.NashvilleHousing a
JOIN [Porfolio Project].dbo.NashvilleHousing b
--selecting to join only where parcel ID is the same but with a different Unique ID
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Updating table using above query
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Porfolio Project].dbo.NashvilleHousing a
JOIN [Porfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------



--Create separated Address Columns for easier manipulation

--Slicing Address into separate columns
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as [Street Address],
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From [Porfolio Project].dbo.NashvilleHousing

--Creating new column for property address
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
--updating table to include address values
Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

--Creating new column for property city
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
--updating table to include city values 
Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 

--Checking to ensure updated columns are in table
Select *
From [Porfolio Project].dbo.NashvilleHousing

--Separating Owner Address Columns using PARSENAME instead of using a substring
Select
PARSENAME((REPLACE(OwnerAddress, ',' , '.')) , 3),
PARSENAME((REPLACE(OwnerAddress, ',' , '.')) , 2),
PARSENAME((REPLACE(OwnerAddress, ',' , '.')) , 1)
From [Porfolio Project].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
--updating table to include owner address values
Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME((REPLACE(OwnerAddress, ',' , '.')) , 3) 

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
--updating table to include owner city values
Update NashvilleHousing
Set OwnerSplitCity = PARSENAME((REPLACE(OwnerAddress, ',' , '.')) , 2) 

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
--updating table to include owner state values
Update NashvilleHousing
Set OwnerSplitState = PARSENAME((REPLACE(OwnerAddress, ',' , '.')) , 1) 

--Checking results
Select *
From [Porfolio Project].dbo.NashvilleHousing


--------------------------------------------------------------------------------------------


--After looking at the data, it appears there are multiple ways this column lists yes and no
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Porfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--Changing Y and N to Yes and No in "Sold as Vacant" field for consistency
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Porfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



----------------------------------------------------------------------------------------------



--Identify Duplicates

--Using a CTE with Row number to see if their are any duplicates matching on the partitioned columns.
--Duplicates should have a row_num of 2 and will be easy to identify 

WITH RowCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num

From [Porfolio Project].dbo.NashvilleHousing
)
Select *
From RowCTE
Where row_num > 1
Order by PropertyAddress


