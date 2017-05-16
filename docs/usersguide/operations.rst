Supported Operations
======================

This page lists and describes all supported image operations, and
is mainly intended as a quick preview of the available
functionality.

+-----------------------+----------------------------------------------------------------------------+
| Category              | Available Operations                                                       |
+=======================+============================================================================+
| Mirroring             | :class:`FlipX` :class:`FlipY`                                              |
+-----------------------+----------------------------------------------------------------------------+
| Rotating              | :class:`Rotate90` :class:`Rotate270` :class:`Rotate180` :class:`Rotate`    |
+-----------------------+----------------------------------------------------------------------------+
| Shearing              | :class:`ShearX` :class:`ShearY`                                            |
+-----------------------+----------------------------------------------------------------------------+
| Scaling and Resizing  | :class:`Scale` :class:`Zoom` :class:`Resize`                               |
+-----------------------+----------------------------------------------------------------------------+
| Cropping              | :class:`Crop` :class:`CropNative` :class:`CropSize`                        |
+-----------------------+----------------------------------------------------------------------------+
| Utility Operations    | :class:`NoOp` :class:`Either`                                              |
+-----------------------+----------------------------------------------------------------------------+

Affine Transformations
------------------------

A good portion of the provided operations fall under the category
of **affine transformations**. As such, they can be described
using what is known as an `affine map
<https://en.wikipedia.org/wiki/Affine_transformation>`_, which
are inherently compose-able if chained together. However,
utilizing such a affine formulation requires (costly)
interpolation, which may not always be needed to achieve the
desired effect. For that reason do some of the operations below
also provide a special purpose implementation to produce their
specified result. Those are usually preferred over the affine
formulation if sensible considering the complete pipeline.

Mirroring
**********

.. class:: FlipX

   Reverses the x-order of each pixel row. Another way of describing
   it would be to mirror the image on the y-axis, or to mirror the
   image horizontally.

.. code-block:: jlcon

   julia> FlipX()
   Flip the X axis

   julia> FlipX(0.3)
   Augmentor.Either (1 out of 2 operation(s)):
     - 30% chance to: Flip the X axis
     - 70% chance to: No operation

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``FlipX()``                                                                                  |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/FlipX.png  |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+


.. class:: FlipY

   Reverses the y-order of each pixel column. Another way of
   describing it would be to mirror the image on the x-axis, or to
   mirror the image vertically.

.. code-block:: jlcon

   julia> FlipY()
   Flip the Y axis

   julia> FlipY(0.3)
   Augmentor.Either (1 out of 2 operation(s)):
     - 30% chance to: Flip the Y axis
     - 70% chance to: No operation

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``FlipY()``                                                                                  |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/FlipY.png  |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+


Rotating
*************

.. class:: Rotate90

   Rotates the image upwards 90 degrees. This is a special case
   rotation because it can be performed very efficiently by simply
   rearranging the existing pixels. However, it is generally not the
   case that the output image will have the same size as the input
   image, which is something to be aware of.

.. code-block:: jlcon

   julia> Rotate90()
   Rotate 90 degree

   julia> Rotate90(0.3)
   Augmentor.Either (1 out of 2 operation(s)):
     - 30% chance to: Rotate 90 degree
     - 70% chance to: No operation

+-----------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------+
| Input                                                                                                     | Output for ``Rotate90()``                                                                                 |
+===========================================================================================================+===========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png   | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate90.png |
+-----------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------+

.. class:: Rotate180

   Rotates the image 180 degrees. This is a special case rotation
   because it can be performed very efficiently by simply
   rearranging the existing pixels. Furthermore, the output image
   will have the same dimensions as the input image.

.. code-block:: jlcon

   julia> Rotate180()
   Rotate 180 degree

   julia> Rotate180(0.3)
   Augmentor.Either (1 out of 2 operation(s)):
     - 30% chance to: Rotate 180 degree
     - 70% chance to: No operation

+------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------+
| Input                                                                                                      | Output for ``Rotate180()``                                                                                 |
+============================================================================================================+============================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png    | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate180.png |
+------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------+

.. class:: Rotate270

   Rotates the image upwards 270 degrees, which can also be described
   as rotating the image downwards 90 degrees. This is a special case
   rotation, because it can be performed very efficiently by simply
   rearranging the existing pixels. However, it is generally not the
   case that the output image will have the same size as the input
   image, which is something to be aware of.

.. code-block:: jlcon

   julia> Rotate270()
   Rotate 270 degree

   julia> Rotate270(0.3)
   Augmentor.Either (1 out of 2 operation(s)):
     - 30% chance to: Rotate 270 degree
     - 70% chance to: No operation

+------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------+
| Input                                                                                                      | Output for ``Rotate270()``                                                                                 |
+============================================================================================================+============================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png    | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate270.png |
+------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------+

.. class:: Rotate

   Rotate the image upwards for the given degrees. This operation
   can only be described as an affine transformation and will in
   general cause other operations of the pipeline to use their
   affine formulation as well (if they have one).

In contrast to the special case rotations outlined above, the
type :class:`Rotate` can describe any arbitrary number of degrees.
It will always perform the rotation around the center of the image.
This can be particularly useful when combining the operation with
:class:`CropNative`.

.. code-block:: jlcon

   julia> Rotate(15)
   Rotate 15 degree

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``Rotate(15)``                                                                               |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate.png |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

.. code-block:: jlcon

   julia> Rotate(-10:10)
   Rotate by θ ∈ -10:10 degree

   julia> Rotate([-3,-1,0,1,3])
   Rotate by θ ∈ [-3, -1, 0, 1, 3] degree

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Sampled outputs for ``Rotate(-10:10)``                                                                  |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Rotate.gif |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+


Shearing
***********

.. class:: ShearX

   Shear the image horizontally for the given degree. This
   operation can only be described as an affine transformation
   and will in general cause other operations of the pipeline to
   use their affine formulation as well (if they have one).

It will always perform the transformation around the center of
the image. This can be particularly useful when combining the
operation with :class:`CropNative`.

.. code-block:: jlcon

   julia> ShearX(10)
   ShearX 10 degree

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``ShearX(10)``                                                                               |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/ShearX.png |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

.. code-block:: jlcon

   julia> ShearX(-10:10)
   ShearX by ϕ ∈ -10:10 degree

   julia> ShearX([-3,-1,0,1,3])
   ShearX by ϕ ∈ [-3,-1,0,1,3] degree

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Sampled outputs for ``ShearX(-10:10)``                                                                  |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/ShearX.gif |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

.. class:: ShearY

   Shear the image vertically for the given degree. This
   operation can only be described as an affine transformation
   and will in general cause other operations of the pipeline to
   use their affine formulation as well (if they have one).

It will always perform the transformation around the center of
the image. This can be particularly useful when combining the
operation with :class:`CropNative`.

.. code-block:: jlcon

   julia> ShearY(10)
   ShearY 10 degree

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``ShearY(10)``                                                                               |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/ShearY.png |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

.. code-block:: jlcon

   julia> ShearY(-10:10)
   ShearY by ψ ∈ -10:10 degree

   julia> ShearY([-3,-1,0,1,3])
   ShearY by ψ ∈ [-3, -1, 0, 1, 3] degree

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Sampled outputs for ``ShearY(-10:10)``                                                                  |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/ShearY.gif |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+


Scaling
**********

.. class:: Scale

   Multiplies the image height and image width by individually
   specified constant factors. This means that the size of the
   output image depends on the size of the input image.

.. code-block:: jlcon

   julia> Scale(0.9,0.5)
   Scale by 0.9×0.5

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``Scale(0.9,0.5)``                                                                           |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Scale.png  |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

In the case that only a single scale factor is specified, the
operation will assume that the intention is to scale all
dimensions uniformly by that factor.

.. code-block:: jlcon

   julia> Scale(1.2)
   Scale by 1.2×1.2

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``Scale(1.2)``                                                                               |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Scale2.png |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

It is also possible to pass some abstract vector(s) to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

.. code-block:: jlcon

   julia> Scale([1.1, 1.2], [0.8, 0.9])
   Scale by I ∈ {1.1×0.8, 1.2×0.9}

   julia> Scale([1.1, 1.2])
   Scale by I ∈ {1.1×1.1, 1.2×1.2}

   julia> Scale(0.9:0.05:1.2)
   Scale by I ∈ {0.9×0.9, 0.95×0.95, 1.0×1.0, 1.05×1.05, 1.1×1.1, 1.15×1.15, 1.2×1.2}

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Sampled outputs for ``Scale(0.9:0.05:1.3)``                                                             |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Scale.gif  |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

.. class:: Zoom

   Multiplies the image height and image width by individually
   specified constant factors. In contrast to :class:`Scale`, the
   size of the input image will be preserved. This is useful to
   implement a strategy known as "scale jitter".

.. code-block:: jlcon

   julia> Zoom(1.2)
   Zoom by 1.2×1.2

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``Zoom(1.2)``                                                                                |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Zoom.png   |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

It is also possible to pass some abstract vector to the
constructor, in which case Augmentor will randomly sample one of
its elements every time the operation is applied.

.. code-block:: jlcon

   julia> Zoom([1.1, 1.2], [0.8, 0.9])
   Zoom by I ∈ {1.1×0.8, 1.2×0.9}

   julia> Zoom([1.1, 1.2])
   Zoom by I ∈ {1.1×1.1, 1.2×1.2}

   julia> Zoom(0.9:0.05:1.2)
   Zoom by I ∈ {0.9×0.9, 0.95×0.95, 1.0×1.0, 1.05×1.05, 1.1×1.1, 1.15×1.15, 1.2×1.2}

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Sampled outputs for ``Zoom(0.9:0.05:1.3)``                                                              |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Zoom.gif   |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+


Resizing and Subsetting
-------------------------

The process of cropping is useful to discard parts of the input
image. To provide this functionality lazily, applying a crop
introduces a layer of representation called a "view" or
``SubArray``. This is different yet compatible with how affine
operations or other special purpose implementations work. This
means that chaining a crop with some affine operation is
perfectly fine if done sequentially. However, it is generally not
advised to combine affine operations with crop operations within
an :class:`Either` block. Doing that would force the
:func:`Either` to trigger the eager computation of its branches
in order to preserve type-stability.

Cropping
*********

.. class:: Crop

   Crops out the area of the specified pixel dimensions starting
   at a specified position, which in turn denotes the top-left corner
   of the crop. A position of ``x = 1``, and ``y = 1`` would mean that
   the crop is located in the top-left corner of the given image

.. code-block:: jlcon

   julia> Crop(1:10, 5:20)
   Crop region 1:10×5:20

   julia> Crop(5, 1, 20, 10)
   Crop region 1:10×5:24

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``Crop(70:140,25:155)``                                                                      |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Crop.png   |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+

.. class:: CropNative

   Crops out the area of the specified pixel dimensions starting
   at a specified position. In contrast to :class:`Crop`, the the
   position (1,1) is not located at the top left of the current
   image, but instead depends on the previous transformations.
   This is useful for combining transformations such as
   :class:`Rotation` or :class:`ShearX` with a crop around the
   center area.

.. code-block:: jlcon

   julia> CropNative(1:10, 5:20)
   Crop native region 1:10×5:20

+-------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------+
| Output for ``(Rotate(45), Crop(1:210,1:280))``                                                              | Output for ``(Rotate(45), CropNative(1:210,1:280))``                                                        |
+=============================================================================================================+=============================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Crop2.png      | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/CropNative.png |
+-------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------+

.. class:: CropSize

   Crops out the area of the specified pixel dimensions
   around the center of the given image.

.. code-block:: jlcon

   julia> CropSize(45,250)
   Crop a 45×250 window around the center

+-----------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------+
| Input                                                                                                     | Output for ``CropSize(45,225)``                                                                           |
+===========================================================================================================+===========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png   | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/CropSize.png |
+-----------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------+


Resizing
***********

.. class:: Resize

   Transforms the image into a fixed specified pixel size. This
   operation does not take any measures to preserve aspect ratio
   of the source image. Instead, the original image will simply be
   resized to the given dimensions. This is useful when one needs a
   set of images to all be of the exact same size.

.. code-block:: jlcon

   julia> Resize(30,40)
   Resize to 30×40

+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+
| Input                                                                                                   | Output for ``Resize(100,150)``                                                                          |
+=========================================================================================================+=========================================================================================================+
| .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/testpattern_small.png | .. image:: https://raw.githubusercontent.com/JuliaML/FileStorage/master/Augmentor/operations/Resize.png |
+---------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------+


Utility Operations
--------------------

Aside from "true" operations that specify some kind of
transformation, there are also a couple of special utility
operations used for functionality such as stochastic branching.

Identity Function
*******************

.. class:: NoOp

   Passes the image along unchanged. Usually used in combination
   with :class:`Either` to denote a "branch" that does not
   perform any computation.

.. code-block:: jlcon

   julia> NoOp()
   No operation

Stochastic Branches
*********************

.. class:: Either

   Allows for choosing between different ImageOperations at
   random. This is particularly useful if one for example wants
   to first either rotate the image 90 degree clockwise or
   anticlockwise (but never both) and then apply some other
   operation(s) afterwards.

   By default each specified image operation has the same
   probability of occurance. This default behaviour can be
   overwritten by specifying the "chance" manually.

.. code-block:: jlcon

   julia> Either(FlipX(), FlipY())
   Augmentor.Either (1 out of 2 operation(s)):
     - 50% chance to: Flip the X axis
     - 50% chance to: Flip the Y axis

   julia> Either(0.6=>FlipX(), 0.4=>FlipY())
   Augmentor.Either (1 out of 2 operation(s)):
     - 60% chance to: Flip the X axis
     - 40% chance to: Flip the Y axis

   julia> Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp())
   Augmentor.Either (1 out of 3 operation(s)):
     - 25% chance to: Flip the X axis
     - 25% chance to: Flip the Y axis
     - 50% chance to: No operation

   julia> Either((FlipX(), FlipY(), NoOp()), (1,1,2))
   Augmentor.Either (1 out of 3 operation(s)):
     - 25% chance to: Flip the X axis
     - 25% chance to: Flip the Y axis
     - 50% chance to: No operation
