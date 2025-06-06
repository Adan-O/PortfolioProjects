--------- Cleaning Data with Queries--------

Select *
From NashvilleHousing

----------Standardize Date Format-----------

Select SaleDateConverted, Convert (Date, SaleDate)
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)


-------Populate Property Adress-------

Select *
From NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is NULL

Update a
Set PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is NULL

-------Breaking Address into City, State, Streeet------
Select PropertyAddress
From NashvilleHousing

Select 
Substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress )-1) as Address
, Substring(PropertyAddress,CHARINDEX(',', PropertyAddress )+1 , LEN(PropertyAddress)) as Address

From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress )-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',', PropertyAddress )+1 , LEN(PropertyAddress))

Select *
From NashvilleHousing





Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From NashvilleHousing

-----Change Y and N to Yes and No-----

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


----------Dropping Unused Columns---------

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
