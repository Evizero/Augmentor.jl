Supported Operations
======================

This page lists and describes all supported image operations, and
is mainly intended as a quick preview of the available
functionality.

Affine Transformations
------------------------

Flip Axis
**********

.. class:: FlipX

   Reverses the x-order of each pixel row. Another way of describing
   it would be to mirror the image on the y-axis, or to mirror the
   image horizontally.

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``FlipX()``                                                                   |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/FlipX.png  |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

.. class:: FlipY

   Reverses the y-order of each pixel column. Another way of
   describing it would be to mirror the image on the x-axis, or to
   mirror the image vertically.

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``FlipY()``                                                                   |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/FlipY.png  |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+


Rotations
*************

.. class:: Rotate90

   Rotates the image upwards 90 degrees. This is a special case
   rotation because it can be performed very efficiently by simply
   rearranging the existing pixels. However, it is generally not the
   case that the output image will have the same size as the input
   image, which is something to be aware of.

+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------+
| Input                                                                                      | Output for ``Rotate90()``                                                                  |
+============================================================================================+============================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png   | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate90.png |
+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------+

.. class:: Rotate180

   Rotates the image 180 degrees. This is a special case rotation
   because it can be performed very efficiently by simply rearranging
   the existing pixels. Furthermore, the output images is guaranteed
   to have the same dimensions as the input image.

+---------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------+
| Input                                                                                       | Output for ``Rotate180()``                                                                  |
+=============================================================================================+=============================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png    | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate180.png |
+---------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------+

.. class:: Rotate270

   Rotates the image upwards 270 degrees, which can also be described
   as rotating the image downwards 90 degrees. This is a special case
   rotation, because it can be performed very efficiently by simply
   rearranging the existing pixels. However, it is generally not the
   case that the output image will have the same size as the input
   image, which is something to be aware of.

+---------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------+
| Input                                                                                       | Output for ``Rotate270()``                                                                  |
+=============================================================================================+=============================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png    | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate270.png |
+---------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------+


.. class:: Rotate

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``Rotate(15)``                                                                |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate.png |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Sampled outputs for ``Rotate(-10:10)``                                                   |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate.gif |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+


Shearing
***********

.. class:: ShearX

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``ShearX(10)``                                                                |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/ShearX.png |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Sampled outputs for ``ShearX(-10:10)``                                                   |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/ShearX.gif |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

.. class:: ShearY

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``ShearY(10)``                                                                |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/ShearY.png |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Sampled outputs for ``ShearY(-10:10)``                                                   |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/ShearY.gif |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+


Scaling
**********

.. class:: Scale

   Multiplies the image height and image width by individually specified
   constant factors. This means that the size of the output image
   depends on the size of the input image.

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``Scale(0.9,0.5)``                                                            |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Scale.png  |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``Scale(1.2)``                                                                |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Scale2.png |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Sampled outputs for ``Scale(0.9:0.05:1.3)``                                              |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Scale.gif  |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

.. class:: Zoom

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``Zoom(1.2)``                                                                 |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Zoom.png   |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Sampled outputs for ``Zoom(0.9:0.05:1.3)``                                               |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Zoom.gif   |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+


Resizing and Subsetting
-------------------------


Cropping
*********

.. class:: Crop

   Crops out the area of the specified pixel dimensions starting
   at a specified position, which in turn denotes the top-left corner
   of the crop. A position of ``x = 1``, and ``y = 1`` would mean that
   the crop is located in the top-left corner of the given image

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``Crop(70:140,25:155)``                                                       |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Crop.png   |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

.. class:: CropSize

   Crops out the area of the specified pixel dimensions
   around the center of the given image.

+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------+
| Input                                                                                      | Output for ``CropSize(45,225)``                                                            |
+============================================================================================+============================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png   | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/CropSize.png |
+--------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------+


Resizing
***********

.. class:: Resize

   Transforms the image into a fixed specified pixel size. This
   operation does not take any measures to preserve aspect ratio
   of the source image. Instead, the original image will simply be
   resized to the given dimensions. This is useful when one needs a
   set of images to all be of the exact same size.

+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Input                                                                                    | Output for ``Resize(100,150)``                                                           |
+==========================================================================================+==========================================================================================+
| .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://rawgit.com/JuliaML/FileStorage/master/Augmentor/operations/Resize.png |
+------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+


Utilities
----------

Either
*******

.. class:: Either

   Allows for choosing between different ImageOperations at
   random. This is particularly useful if one for example wants
   to first either rotate the image 90 degree clockwise or
   anticlockwise (but never both) and then apply some other
   operation(s) afterwards.

   By default each specified image operation has the same
   probability of occurance. This default behaviour can be
   overwritten by specifying the parameter ``chance`` manually

