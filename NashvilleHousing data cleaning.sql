/* 

Cleaning Data in SQL Queries

*/

SELECT * 
FROM NashvilleHouse.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHouse.dbo.NashvilleHousing

UPDATE NashvilleHouse.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHouse.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHouse.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouse.dbo.NashvilleHousing a
JOIN NashvilleHouse.dbo.NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouse.dbo.NashvilleHousing a
JOIN NashvilleHouse.dbo.NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL



------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHouse.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHouse.dbo.NashvilleHousing


ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHouse.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHouse.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT * 
FROM NashvilleHouse.dbo.NashvilleHousing




SELECT OwnerAddress
FROM NashvilleHouse.dbo.NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHouse.dbo.NashvilleHousing


ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHouse.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHouse.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHouse.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



SELECT * 
FROM NashvilleHouse.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------------

-- Change Y and N as Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHouse.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM NashvilleHouse.dbo.NashvilleHousing


UPDATE NashvilleHouse.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END




------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY 
                    UniqueID 
                )   row_num
FROM NashvilleHouse.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM NashvilleHouse.dbo.NashvilleHousing


ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHouse.dbo.NashvilleHousing
DROP COLUMN SaleDate