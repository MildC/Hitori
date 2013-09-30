import Data.List

gridSize = truncate.sqrt.fromIntegral.length

hitori grid = showGrid(solve grid (replicate (length grid) 1) (gridSize grid) (0,0))

solve grid unshadeGrid size (x,y)
	| isConnect grid size == False = []
	| y == size && x == (size - 1) = grid
	| y == size = solve grid unshadeGrid size ((x + 1), 0)
	| not $ null dupInRow = shade grid unshadeGrid dupInRow size (x,y)
	| not $ null dupInCol = shade grid unshadeGrid dupInCol size (x,y)
	| otherwise = solve grid unshadeGrid size (x,(y+1))
	where dupInRow = duplicatesInRow grid size (x,y)
		; dupInCol = duplicatesInCol grid size (x,y)

-- check duplication in the row
-- return the duplication of current cell in the row
duplicatesInRow grid size (x,y)
	| null duplicates = []
	| otherwise = actualIndex duplicates (rowIndex x size)
	where row = extractRow x grid size
		 ; duplicates = findDuplicate cellValue row
		 ; cellValue = grid !! (x * size + y)

-- check duplication in the column
-- return the duplication of current cell in the column
duplicatesInCol grid size (x,y)
	| null duplicates = []
	| otherwise = actualIndex duplicates (colIndex y size)
	where col = extractCol y grid size
		 ; duplicates = findDuplicate cellValue col
		 ; cellValue = grid !! (x * size + y)

-- get the actual index from the list of indices in row/column
actualIndex xs indexList = map (\n->indexList !! n) xs

-- shade the list of shadable cells
shade grid unshadeGrid dupList size (x,y)
	| null shadable = []
	| otherwise = shadeList shadable 0 grid unshadeGrid size (x,y)
	where shadable = shadableList grid unshadeGrid size dupList []

-- do recursive call with different shading cell
shadeList dupList currIndex grid unshadeGrid size (x,y)
	| currIndex == (length dupList) = []
	-- special case of 3 duplicate cells in a row/col
	-- three cells connected
	-- keep the middle cell
	| isTripple dupList size = solve (shadeCells (removeAt 1 dupList) grid) (unshadeCells (removeAt 1 dupList) unshadeGrid size) size (x,y)
	-- two cells connected and another one in the same row/column
	| isDoublePlusOne dupList size = solve (shadeCell (dupList !! 2) grid) (unshade (dupList !! 2) unshadeGrid size) size (x,y)
	| isOnePlusDouble dupList size = solve (shadeCell (dupList !! 0) grid) (unshade (dupList !! 0) unshadeGrid size) size (x,y)
	-- if not solvable, then try to shade the next available in the duplication list
	| null testSolve = shadeList dupList (currIndex+1) grid unshadeGrid size (x,y)
	| otherwise = testSolve
	where unshadeCurrent = unshadeGrid
		; cellsToShade = removeCurrIndex dupList currIndex
		; shadedGrid = shadeCells cellsToShade grid
		; unshadedGrid = unshadeCells cellsToShade unshadeCurrent size
		; testSolve = solve shadedGrid unshadedGrid size (x,y)

removeCurrIndex dupList currIndex
	| length dupList == 1 = dupList
	| otherwise = removeAt currIndex dupList

-- check if three cells connected in dupList
isTripple dupList size
	| length dupList /= 3 = False
	| (dupList !! 1) - (dupList !! 0) == 1 && (dupList !! 2) - (dupList !! 1) == 1 = True
	| (dupList !! 1) - (dupList !! 0) == size && (dupList !! 2) - (dupList !! 1) == size = True
	| otherwise = False

-- should be used after isTripple test
-- check if two cells connected and another one in the same row/column
isDoublePlusOne dupList size
	| length dupList /= 3 = False
	| (dupList !! 1) - (dupList !! 0) == 1 = True
	| (dupList !! 1) - (dupList !! 0) == size = True
	| otherwise = False

isOnePlusDouble dupList size
	| length dupList /= 3 = False
	| (dupList !! 2) - (dupList !! 1) == 1 = True
	| (dupList !! 2) - (dupList !! 1) == size = True
	| otherwise = False

-- remove an element from a list
removeAt index list = removeElemAt index list 0 []
removeElemAt index (x:xs) currIndex acc
	| index == currIndex = acc ++ xs
	| otherwise = removeElemAt index xs (currIndex + 1) (acc ++ [x])

-- get unshadeGrid if shade cell x
unshadeCells [] unshadeGrid size = unshadeGrid
unshadeCells (x:xs) unshadeGrid size = unshadeCells xs (unshade x unshadeGrid size) size

unshade x unshadeGrid size = shadedCorner
	where shadedLeft = unshadeLeft x unshadeGrid size
		; shadedRight = unshadeRight x shadedLeft size
		; shadedUp = unshadeUp x shadedRight size
		; shadedDown = unshadeDown x shadedUp size
		; shadedCorner = unshadeCorner x shadedDown size

unshadeLeft x unshadeGrid size
	| (leftCellValue unshadeGrid size x /= -1) && (leftCellValue unshadeGrid size x /= 0) = shadeCell (x-1) unshadeGrid
	| otherwise = unshadeGrid
unshadeRight x unshadeGrid size
	| (rightCellValue unshadeGrid size x /= -1) && (rightCellValue unshadeGrid size x /= 0) = shadeCell (x+1) unshadeGrid
	| otherwise = unshadeGrid
unshadeUp x unshadeGrid size
	| (upCellValue unshadeGrid size x /= -1) && (upCellValue unshadeGrid size x /= 0) = shadeCell (x-size) unshadeGrid
	| otherwise = unshadeGrid
unshadeDown x unshadeGrid size
	| (downCellValue unshadeGrid size x /= -1) && (downCellValue unshadeGrid size x /= 0) = shadeCell (x+size) unshadeGrid
	| otherwise = unshadeGrid

unshadeCorner x unshadeGrid size
	-- upper left corner
	| x == 0 = shadeCell (size+1) unshadeGrid
	-- upper right corner
	| x == (size - 1) = shadeCell (2 * size - 2) unshadeGrid
	-- bottom left corner
	| x == (size*(size-1)) = shadeCell (size^2 - 2*size + 1) unshadeGrid
	-- bottom right corner
	| x == (size^2-1) = shadeCell (size^2 - size - 2) unshadeGrid
	| otherwise = unshadeGrid

-- unshade corner rule
isCellAtCorner x unshadeGrid size = length (filter (== -1) [(leftCellValue unshadeGrid size x), (rightCellValue unshadeGrid size x), (upCellValue unshadeGrid size x), (downCellValue unshadeGrid size x)]) == 3

-- shading list of cells
shadeCells [] grid = grid
shadeCells (x:xs) grid = shadeCells xs (shadeCell x grid)

-- shading cell
shadeCell index grid = shadeCellOfIndex index grid 0 []
shadeCellOfIndex index (x:xs) currIndex acc
	| index == currIndex = acc ++ [0] ++ xs
	| otherwise = shadeCellOfIndex index xs (currIndex + 1) (acc ++ [x])

-- take a list of cell index and return a list of indecies that are shadable
shadableList grid unshadeGrid size [] acc = acc
shadableList grid unshadeGrid size (x:xs) acc
	| isShadable grid unshadeGrid size x = shadableList grid unshadeGrid size xs (acc ++ [x])
	| otherwise = shadableList grid unshadeGrid size xs acc

-- check if cell is shadable
isShadable grid unshadeGrid size index = (isCellAvailable grid size index) && ((unshadeGrid !! index) == 1)

-- general availablity case
isCellAvailable grid size index = (leftCellValue grid size index /= 0) && (rightCellValue grid size index /= 0) && (upCellValue grid size index /= 0) && (downCellValue grid size index /= 0)

leftCellValue grid size index 
	| index `mod` size == 0 = -1
	| otherwise = grid !! (index - 1)

rightCellValue grid size index
	| index `mod` size == (size - 1) = -1
	| otherwise = grid !! (index + 1)

upCellValue grid size index
	| index < size = -1
	| otherwise = grid !! (index - size)

downCellValue grid size index
	| index >= (size * (size - 1)) = -1
	| otherwise = grid !! (index + size)

-- remove duplicates in a list
removeDuplicates [] = []
removeDuplicates (x:xs) = x : (removeDuplicates (filter (\y -> not (x == y)) xs))

-- get the list of index of a row/column
rowIndex x size = map (+ (x * size)) [0..(size - 1)]
colIndex x size = map (+x) (map (* size) [0..(size - 1)])

-- Extract row/column from a grid
extractRow row grid size = map (\x->grid !! x) (rowIndex row size)
extractCol col grid size = map (\x->grid !! x) (colIndex col size)


hasDuplicate x xs = length(filter (==x) xs) > 1

-- Check duplication of an element x in a list
-- return the list of index that contains that element
duplicateIndex _ [] acc _ = acc
duplicateIndex x xs acc droppedIndex
	| x <= 0 = []
	| elem x xs = duplicateIndex x (drop (fromIntegral(findposition x xs) + 1) xs) (acc ++ [(findposition x xs) + droppedIndex]) (droppedIndex + (findposition x xs) + 1)
	| otherwise = acc

findDuplicate x [] = []
findDuplicate x xs
	| hasDuplicate x xs = duplicateIndex x xs [] 0
	| otherwise = []

findposition x = (\(Just i)->i) . elemIndex (x)

-- display grid, the wrapper method
showGrid lst = putStr (showGridByRow lst (gridSize lst))
-- display grid
showGridByRow [] _ = "\n\n"
showGridByRow lst@(x:xs) size
	| (length lst) `mod` size == 0 = "\n" ++ (show x) ++ " " ++ showGridByRow xs size
	| otherwise = (show x) ++ " " ++ showGridByRow xs size

-- Check connectivity of a grid
isConnect grid size = null $ filter (>0) (traverse grid size 0)

-- traverse the grid and mark the traversed cell as 0
traverse grid size index
	| index == -1 = grid
	| null $ filter (>0) [leftIndex,rightIndex,upIndex,downIndex] = traversedCurrentCell
	| otherwise =  traversedDown
	where traversedCurrentCell = shadeCell index grid
		; traversedLeft = traverse traversedCurrentCell size leftIndex
		; traversedRight = traverse traversedLeft size rightIndex
		; traversedUp = traverse traversedRight size upIndex
		; traversedDown = traverse traversedUp size downIndex
		; leftIndex
			| leftCellValue grid size index > 0 = index - 1
			| otherwise = -1
		; rightIndex
			| rightCellValue grid size index > 0 = index + 1
			| otherwise = -1
		; upIndex
			| upCellValue grid size index > 0 = index - size
			| otherwise = -1
		; downIndex
			| downCellValue grid size index > 0 = index + size
			| otherwise = -1

