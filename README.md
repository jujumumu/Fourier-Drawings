# Fourier-Drawings
Visualization of using Fourier Series to draw. You can draw your own paths and it will calculate and render the visualization. Note the UI is very ugly but you can always change it :)

## How to Use
* Pressing the NEW PATH button starts a new path. Allowing you to draw a continous line.
* Pressing the DRAWING button displays/hides your own drawing(The red line is your own drawing and the yellow line is the one generated).
* Pressing the FOLLOW POINT button makes the camera follow the current point.
* Pressing the RETURN button returns the camera back to the origin with original zoom.
* You can zoom by using the scroll wheel.
* The slider on the top controls the speed.
* The Label shows the current state.

## Exported Variables
* Step controls how the code interpolates your drawing for more data points. Default value of 0.05(The smaller the more data points, lower values take longer to calculate).
* Num Of Vectors controls the amount of vectors used. The more the more accurate the algorithm will be to your own drawing but it will also take longer. (The actual number of vectors is 2xNum_Of_Vectors-1)

## Notes
* You should always return before you start drawing a new path.
* Drawing a path that is too short leading to low amounts of data points will result in a spike at the start as there are not enough data points.
* The computation may take a while if you draw a long path.


## Known Bugs
* Drawing the arrows for a very small radius leads to an error. So zooming in on the point you may see many circles missing arrows. Your debugger will probably have thousands of errors. If anyone knows how to fix this please create an issue. 

## How the Code Works
[This Video](https://www.youtube.com/watch?v=r6sGWTCMz2k&t) by 3Blue1Brown explains the math/algorithm. You don't need to undertand the math to understand the code. The math behind this is pretty complicated but is very neat. Take a look if you have the time. 
