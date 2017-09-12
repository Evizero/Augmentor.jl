#' # Test Tutorial
#'
#' This is a test tutorial

using Augmentor, Images

#' First we load the sample image using the function `testpattern`.

img = testpattern()
#md save("tstimg.png", img) # hide
#md nothing # hide

#md #' ![img](tstimg.png)

#' Lets see if custom treatment for jupyter works

#jp [rand(RGB,10,10) for i in 1:5]
#md println("Hello World")
