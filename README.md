This program can solve large grid.

With a Core i7 Ivy Bridge CPU, it solves a 8*8 grid with about 3 secs

## Note
The term 'shade' in the code means black out a cell
'unshade' means mark cell as white
unshadeGrid is a grid with the same size of the original grid that is used to keep track of which cells are marked white
'size' means the width or height of the grid. eg. if it's a 5 by 5 grid, then the size is 5

## Used Technique
* When it is confirmed that a cell must be black, one can see all orthogonally adjacent cells must not be black.
* If a number has been circled to show that it must be white, any cells containing the same number in that row and column must also be black.
* If a cell would separate a white area of the grid if it were painted black, the cell must be white.
* In a sequence of three identical, adjacent numbers; the centre number must be white (and cells on either must be black). If one of the end numbers were white this would result in two adjacent filled in cells which is not allowed.
* In a sequence of two identical, adjacent numbers; if the same row or column contains another cell of the same number the number standing on its own must be black. If it were white this would result in two adjacent filled in cells which is not allowed.

## Some sample 5*5 grid:

*Main> hitori [4,3,2,2,3, 3,4,1,5,2, 1,3,4,5,5, 4,3,5,4,1, 5,1,2,2,2]

4 0 2 0 3 

3 4 1 5 2 

1 0 4 0 5 

0 3 5 4 1 

5 1 0 2 0 

*Main> hitori [2,4,2,1,4, 4,5,1,3,2, 2,4,5,1,3, 1,1,1,5,4, 5,3,2,4,4]

0 4 0 1 0 

4 5 1 3 2 

2 0 5 0 3 

0 1 0 5 4 

5 3 2 4 0 

hitori [3,3,1,5,2, 1,3,4,4,5, 4,5,4,1,3, 5,3,2,1,4, 4,4,5,2,1]

3 0 1 5 2 

1 3 4 0 5 

4 5 0 1 3 

5 0 2 0 4 

0 4 5 2 1 

hitori [1,0,5,3,2, 3,4,1,2,5, 2,4,4,4,3, 4,2,3,1,2, 1,1,1,5,2]

1 0 5 3 2 

3 4 1 2 5 

2 0 4 0 3 

4 2 3 1 0 

0 1 0 5 0 

hitori [1,2,5,4,3, 4,1,5,2,4, 3,2,3,1,5, 2,5,1,2,4, 1,4,5,3,1]

1 0 5 4 3 

4 1 0 2 0 

0 2 3 1 5 

2 5 1 0 4 

0 4 0 3 1 

