var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": "(Image: header)A fast library for increasing the number of training images by applying various transformations."
},

{
    "location": "#Augmentor.jl's-documentation-1",
    "page": "Home",
    "title": "Augmentor.jl's documentation",
    "category": "section",
    "text": "Augmentor is a real-time image augmentation library designed to render the process of artificial dataset enlargement more convenient, less error prone, and easier to reproduce. It offers the user the ability to build a stochastic image-processing pipeline (or simply augmentation pipeline) using image operations as building blocks. In other words, an augmentation pipeline is little more but a sequence of operations for which the parameters can (but need not) be random variables, as the following code snippet demonstrates.using Augmentor\npl = ElasticDistortion(6, scale=0.3, border=true) |>\n     Rotate([10, -5, -3, 0, 3, 5, 10]) |>\n     ShearX(-10:10) * ShearY(-10:10) |>\n     CropSize(28, 28) |>\n     Zoom(0.9:0.1:1.2)Such a pipeline can then be used for sampling. Here we use the first few examples of the MNIST database.# I can't use Reel.jl, because the way it stores the tmp pngs\n# causes the images to be upscaled too much.\nusing Augmentor, MLDatasets, Images, Colors\nusing PaddedViews, OffsetArrays\nsrand(1337)\n\npl = ElasticDistortion(6, scale=0.3, border=true) |>\n     Rotate([10, -5, -3, 0, 3, 5, 10]) |>\n     ShearX(-10:10) * ShearY(-10:10) |>\n     CropSize(28, 28) |>\n     Zoom(0.9:0.1:1.2)\n\nmd_imgs = String[]\nfor i in 1:24\n    input = MNIST.convert2image(MNIST.traintensor(i))\n    imgs = [augment(input, pl) for j in 1:20]\n    insert!(imgs, 1, first(imgs)) # otherwise loop isn't smooth\n    fnames = map(imgs) do img\n        tpath = tempname() * \".png\"\n        save(tpath, img)\n        tpath\n    end\n    args = reduce(vcat, [[fname, \"-delay\", \"1x4\", \"-alpha\", \"deactivate\"] for fname in fnames])\n    convert = strip(readstring(`which convert`))\n    outname = joinpath(\"assets\", \"idx_mnist_$i.gif\")\n    run(`$convert $args $outname`)\n    push!(md_imgs, \"[![mnist $i]($outname)](@ref mnist)\")\n    foreach(fname -> rm(fname), fnames)\nend\nMarkdown.parse(join(md_imgs, \" \"))The Julia version of Augmentor is engineered specifically for high performance applications. It makes use of multiple heuristics to generate efficient tailor-made code for the concrete user-specified augmentation pipeline. In particular Augmentor tries to avoid the need for any intermediate images, but instead aims to compute the output image directly from the input in one single pass."
},

{
    "location": "#Where-to-begin?-1",
    "page": "Home",
    "title": "Where to begin?",
    "category": "section",
    "text": "If this is the first time you consider using Augmentor.jl for your machine learning related experiments or packages, make sure to check out the \"Getting Started\" section. There we list the installation instructions and some simple hello world examples.Pages = [\"gettingstarted.md\"]\nDepth = 2Augmentor.jl is the Julia package for Augmentor. You can find the Python version here."
},

{
    "location": "#Introduction-and-Motivation-1",
    "page": "Home",
    "title": "Introduction and Motivation",
    "category": "section",
    "text": "If you are new to image augmentation in general, or are simply interested in some background information, feel free to take a look at the following sections. There we discuss the concepts involved and outline the most important terms and definitions.Pages = [\"background.md\"]\nDepth = 2In case you have not worked with image data in Julia before, feel free to browse the following documents for a crash course on how image data is represented in the Julia language, as well as how to visualize it. For more information on image processing in Julia, take a look at the documentation for the vast JuliaImages ecosystem.Pages = [\"images.md\"]\nDepth = 2"
},

{
    "location": "#User's-Guide-1",
    "page": "Home",
    "title": "User's Guide",
    "category": "section",
    "text": "As the name suggests, Augmentor was designed with image augmentation for machine learning in mind. That said, the way the library is implemented allows it to also be used for efficient image processing outside the machine learning domain.The following section describes the high-level user interface in more detail. In particular it focuses on how a (stochastic) image-processing pipeline can be defined and then be applied to an image (or a set of images).Pages = [\"interface.md\"]\nDepth = 2Augmentor ships with a number of predefined operations that should be sufficient to describe some of the most commonly used augmentation strategies. Each operation is a represented as its own unique type. The following section provides a complete list of all the exported operations and their documentation.Pages = [\"operations.md\"]\nDepth = 2"
},

{
    "location": "#Tutorials-1",
    "page": "Home",
    "title": "Tutorials",
    "category": "section",
    "text": "Just like an image can say more than a thousand words, a simple hands-on tutorial can say more than many pages of formal documentation.Pages = [joinpath(\"generated\", fname) for fname in readdir(\"generated\") if splitext(fname)[2] == \".md\"]\nDepth = 2"
},

{
    "location": "#Indices-1",
    "page": "Home",
    "title": "Indices",
    "category": "section",
    "text": "Pages = [\"indices.md\"]"
},

{
    "location": "gettingstarted/#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "gettingstarted/#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": "In this section we will provide a condensed overview of the package. In order to keep this overview concise, we will not discuss any background information or theory on the losses here in detail."
},

{
    "location": "gettingstarted/#Installation-1",
    "page": "Getting Started",
    "title": "Installation",
    "category": "section",
    "text": "To install Augmentor.jl, start up Julia and type the following code-snipped into the REPL. It makes use of the native Julia package manger.Pkg.add(\"Augmentor\")Additionally, for example if you encounter any sudden issues, or in the case you would like to contribute to the package, you can manually choose to be on the latest (untagged) version.Pkg.checkout(\"Augmentor\")"
},

{
    "location": "gettingstarted/#Example-1",
    "page": "Getting Started",
    "title": "Example",
    "category": "section",
    "text": "The following code snippet shows how a stochastic augmentation pipeline can be specified using simple building blocks that we call \"operations\". In order to give the example some meaning, we will use a real medical image from the publicly available ISIC archive as input. The concrete image can be downloaded here using their Web API.julia> using Augmentor, ISICArchive\n\njulia> img = get(ImageThumbnailRequest(id = \"5592ac599fc3c13155a57a85\"))\n169×256 Array{RGB{N0f8},2}:\n[...]\n\njulia> pl = Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp()) |>\n            Rotate(0:360) |>\n            ShearX(-5:5) * ShearY(-5:5) |>\n            CropSize(165, 165) |>\n            Zoom(1:0.05:1.2) |>\n            Resize(64, 64)\n6-step Augmentor.ImmutablePipeline:\n 1.) Either: (25%) Flip the X axis. (25%) Flip the Y axis. (50%) No operation.\n 2.) Rotate by θ ∈ 0:360 degree\n 3.) Either: (50%) ShearX by ϕ ∈ -5:5 degree. (50%) ShearY by ψ ∈ -5:5 degree.\n 4.) Crop a 165×165 window around the center\n 5.) Zoom by I ∈ {1.0×1.0, 1.05×1.05, 1.1×1.1, 1.15×1.15, 1.2×1.2}\n 6.) Resize to 64×64\n\njulia> img_new = augment(img, pl)\n64×64 Array{RGB{N0f8},2}:\n[...]using Augmentor, ISICArchive;\n\nimg = get(ImageThumbnailRequest(id = \"5592ac599fc3c13155a57a85\"))\n\npl = Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp()) |>\n     Rotate(0:360) |>\n     ShearX(-5:5) * ShearY(-5:5) |>\n     CropSize(165, 165) |>\n     Zoom(1:0.05:1.2) |>\n     Resize(64, 64)\n\nimg_new = augment(img, pl)\n\nusing Plots\npyplot(reuse = true)\ndefault(bg_outside=colorant\"#F3F6F6\")\nsrand(123)\n\n# Create image that shows the input\nplot(img, size=(256,169), xlim=(1,255), ylim=(1,168), grid=false, ticks=true)\nPlots.png(joinpath(\"assets\",\"isic_in.png\"))\n\n# create animate gif that shows 10 outputs\nanim = @animate for i=1:10\n    plot(augment(img, pl), size=(169,169), xlim=(1,63), ylim=(1,63), grid=false, ticks=true)\nend\nPlots.gif(anim, joinpath(\"assets\",\"isic_out.gif\"), fps = 2)\n\nnothingThe function augment will generate a single augmented image from the given input image and pipeline. To visualize the effect we compiled a few resulting output images into a GIF using the plotting library Plots.jl with the PyPlot.jl back-end. You can inspect the full code by clicking on \"Edit on Github\" in the top right corner of this page.Input (img)  Output (img_new)\n(Image: input) → (Image: output)"
},

{
    "location": "gettingstarted/#Getting-Help-1",
    "page": "Getting Started",
    "title": "Getting Help",
    "category": "section",
    "text": "To get help on specific functionality you can either look up the information here, or if you prefer you can make use of Julia's native doc-system. The following example shows how to get additional information on augment within Julia's REPL:?augmentIf you find yourself stuck or have other questions concerning the package you can find us at gitter or the Machine Learning domain on discourse.julialang.orgJulia ML on Gitter\nMachine Learning on JulialangIf you encounter a bug or would like to participate in the development of this package come find us on Github.Evizero/Augmentor.jl"
},

{
    "location": "background/#",
    "page": "Background and Motivation",
    "title": "Background and Motivation",
    "category": "page",
    "text": ""
},

{
    "location": "background/#Background-and-Motivation-1",
    "page": "Background and Motivation",
    "title": "Background and Motivation",
    "category": "section",
    "text": "In this section we will discuss the concept of image augmentation in general. In particular we will introduce some terminology and useful definitions."
},

{
    "location": "background/#What-is-Image-Augmentation?-1",
    "page": "Background and Motivation",
    "title": "What is Image Augmentation?",
    "category": "section",
    "text": "The term data augmentation is commonly used to describe the process of repeatedly applying various transformations to some dataset, with the hope that the output (i.e. the newly generated observations) bias the model towards learning better features. Depending on the structure and semantics of the data, coming up with such transformations can be a challenge by itself.Images are a special class of data that exhibit some interesting properties in respect to their structure. For example do the dimensions of an image (i.e. the pixel) exhibit a spatial relationship to each other. As such, a lot of commonly used augmentation strategies for image data revolve around affine transformations, such as translations or rotations. Because images are such a popular and special case of data, they deserve their own sub-category of data augmentation, which we will unsurprisingly refer to as image augmentation.The general idea is the following: if we want our model to generalize well, then we should design the learning process in such a way as to bias the model into learning such transformation-equivariant properties. One way to do this is via the design of the model itself, which for example was idea behind convolutional neural networks. An orthogonal approach to bias the model to learn about this equivariance - and the focus of this package - is by using label-preserving transformations."
},

{
    "location": "background/#Label-preserving-Transformations-1",
    "page": "Background and Motivation",
    "title": "Label-preserving Transformations",
    "category": "section",
    "text": "Before attempting to train a model using some augmentation pipeline, it's a good idea to invest some time in deciding on an appropriate set of transformations to choose from. Some of these transformations also have parameters to tune, and we should also make sure that we settle on a decent set of values for those.What constitutes as \"decent\" depends on the dataset. In general we want the augmented images to be fairly dissimilar to the originals. However, we need to be careful that the augmented images still visually represent the same concept (and thus label). If a pipeline only produces output images that have this property we call this pipeline label-preserving."
},

{
    "location": "background/#mnist-1",
    "page": "Background and Motivation",
    "title": "Example: MNIST Handwritten Digits",
    "category": "section",
    "text": "Consider the following example from the MNIST database of handwritten digits [MNIST1998]. Our input image clearly represents its associated label \"6\". If we were to use the transformation Rotate180 in our augmentation pipeline for this type of images, we could end up with the situation depicted by the image on the right side.using Augmentor, MLDatasets\ninput_img  = MNIST.convert2image(MNIST.traintensor(19))\noutput_img = augment(input_img, Rotate180())\nusing Images, FileIO; # hide\nupsize(A) = repeat(A, inner=(4,4)); # hide\nsave(joinpath(\"assets\",\"bg_mnist_in.png\"), upsize(input_img)); # hide\nsave(joinpath(\"assets\",\"bg_mnist_out.png\"), upsize(output_img)); # hide\nnothing # hideInput (input_img) Output (output_img)\n(Image: input) (Image: output)To a human, this newly transformed image clearly represents the label \"9\", and not \"6\" like the original image did. In image augmentation, however, the assumption is that the output of the pipeline has the same label as the input. That means that in this example we would tell our model that the correct answer for the image on the right side is \"6\", which is clearly undesirable for obvious reasons.Thus, for the MNIST dataset, the transformation Rotate180 is not label-preserving and should not be used for augmentation.[MNIST1998]: LeCun, Yan, Corinna Cortes, Christopher J.C. Burges. \"The MNIST database of handwritten digits\" Website. 1998."
},

{
    "location": "background/#Example:-ISIC-Skin-Lesions-1",
    "page": "Background and Motivation",
    "title": "Example: ISIC Skin Lesions",
    "category": "section",
    "text": "On the other hand, the exact same transformation could very well be label-preserving for other types of images. Let us take a look at a different set of image data; this time from the medical domain.The International Skin Imaging Collaboration [ISIC] hosts a large collection of publicly available and labeled skin lesion images. A subset of that data was used in 2016's ISBI challenge [ISBI2016] where a subtask was lesion classification.Let's consider the following input image on the left side. It shows a photo of a skin lesion that was taken from above. By applying the Rotate180 operation to the input image, we end up with a transformed version shown on the right side.using Augmentor, ISICArchive\ninput_img  = get(ImageThumbnailRequest(id = \"5592ac599fc3c13155a57a85\"))\noutput_img = augment(input_img, Rotate180())\nusing FileIO; # hide\nsave(joinpath(\"assets\",\"bg_isic_in.png\"), input_img); # hide\nsave(joinpath(\"assets\",\"bg_isic_out.png\"), output_img); # hide\nnothing # hideInput (input_img) Output (output_img)\n(Image: input) (Image: output)After looking at both images, one could argue that the orientation of the camera is somewhat arbitrary as long as it points to the lesion at an approximately orthogonal angle. Thus, for the ISIC dataset, the transformation Rotate180 could be considered as label-preserving and very well be tried for augmentation. Of course this does not guarantee that it will improve training time or model accuracy, but the point is that it is unlikely to hurt.[ISIC]: https://isic-archive.com/[ISBI2016]: Gutman, David; Codella, Noel C. F.; Celebi, Emre; Helba, Brian; Marchetti, Michael; Mishra, Nabin; Halpern, Allan. \"Skin Lesion Analysis toward Melanoma Detection: A Challenge at the International Symposium on Biomedical Imaging (ISBI) 2016, hosted by the International Skin Imaging Collaboration (ISIC)\". eprint arXiv:1605.01397. 2016."
},

{
    "location": "images/#",
    "page": "Working with Images in Julia",
    "title": "Working with Images in Julia",
    "category": "page",
    "text": ""
},

{
    "location": "images/#Working-with-Images-in-Julia-1",
    "page": "Working with Images in Julia",
    "title": "Working with Images in Julia",
    "category": "section",
    "text": "The Julia language provides a rich syntax as well as large set of highly-optimized functionality for working with (multi-dimensional) arrays of what is known as \"bit types\" or compositions of such. Because of this, the language lends itself particularly well to the fairly simple idea of treating images as just plain arrays. Even though this may sound as a rather tedious low-level approach, Julia makes it possible to still allow for powerful abstraction layers without the loss of generality that usually comes with that. This is accomplished with help of Julia's flexible type system and multiple dispatch (both of which are beyond the scope of this tutorial).While the images-are-arrays-approach makes working with images in Julia very performant, it has also been source of confusion to new community members. This beginner's guide is an attempt to provide a step-by-step overview of how pixel data is handled in Julia. To get a more detailed explanation on some particular concept involved, please take a look at the documentation of the JuliaImages ecosystem."
},

{
    "location": "images/#Multi-dimensional-Arrays-1",
    "page": "Working with Images in Julia",
    "title": "Multi-dimensional Arrays",
    "category": "section",
    "text": "To wrap our heads around Julia's array-based treatment of images, we first need to understand what Julia arrays are and how we can work with them.note: Note\nThis section is only intended provide a simplified and thus partial overview of Julia's arrays capabilities in order to gain some intuition about pixel data. For a more detailed treatment of the topic please have a look at the official documentationWhenever we work with an Array in which the elements are bit-types (e.g. Int64, Float32, UInt8, etc), we can think of the array as a continuous block of memory. This is useful for many different reasons, such as cache locality and interacting with external libraries.The same block of memory can be interpreted in a number of ways. Consider the following example in which we allocate a vector (i.e. a one dimensional array) of UInt8 (i.e. bytes) with some ordered example values ranging from 1 to 6. We will think of this as our physical memory block, since it is a pretty close representation.julia> memory = [0x1, 0x2, 0x3, 0x4, 0x5, 0x6]\n6-element Array{UInt8,1}:\n 0x01\n 0x02\n 0x03\n 0x04\n 0x05\n 0x06The same block of memory could also be interpreted differently. For example we could think of this as a matrix with 3 rows and 2 columns instead (or even the other way around). The function reinterpret allows us to do just thatjulia> A = reinterpret(UInt8, memory, (3,2))\n3×2 Array{UInt8,2}:\n 0x01  0x04\n 0x02  0x05\n 0x03  0x06Note how we specified the number of rows first. This is because the Julia language follows the column-major convention for multi dimensional arrays. What this means can be observed when we compare our new matrix A with the initial vector memory and look at the element layout. Both variables are using the same underlying memory (i.e the value 0x01 is physically stored right next to the value 0x02 in our example, while 0x01 and 0x04 are quite far apart even though the matrix interpretation makes it look like they are neighbors; which they are not).tip: Tip\nA quick and dirty way to check if two variables are representing the same block of memory is by comparing the output of pointer(myvariable). Note, however, that technically this only tells you where a variable starts in memory and thus has its limitations.This idea can also be generalized for higher dimensions. For example we can think of this as a 3D array as well.julia> reinterpret(UInt8, memory, (3,1,2))\n3×1×2 Array{UInt8,3}:\n[:, :, 1] =\n 0x01\n 0x02\n 0x03\n\n[:, :, 2] =\n 0x04\n 0x05\n 0x06If you take a closer look at the dimension sizes, you can see that all we did in that example was add a new dimension of size 1, while not changing the other numbers. In fact we can add any number of practically empty dimensions, otherwise known as singleton dimensions.julia> reinterpret(UInt8, memory, (3,1,1,1,2))\n3×1×1×1×2 Array{UInt8,5}:\n[:, :, 1, 1, 1] =\n 0x01\n 0x02\n 0x03\n\n[:, :, 1, 1, 2] =\n 0x04\n 0x05\n 0x06This is a useful property to have when we are confronted with greyscale datasets that do not have a color channel, yet we still want to work with a library that expects the images to have one."
},

{
    "location": "images/#Vertical-Major-vs-Horizontal-Major-1",
    "page": "Working with Images in Julia",
    "title": "Vertical-Major vs Horizontal-Major",
    "category": "section",
    "text": "There are a number of different conventions for how to store image data into a binary format. The first question one has to address is the order in which the image dimensions are transcribed.We have seen before that Julia follows the column-major convention for its arrays, which for images would lead to the corresponding convention of being vertical-major. In the image domain, however, it is fairly common to store the pixels in a horizontal-major layout. In other words, horizontal-major means that images are stored in memory (or file) one pixel row after the other.In most cases, when working within the JuliaImages ecosystem, the images should already be in the Julia-native column major layout. If for some reason that is not the case there are two possible ways to convert the image to that format.julia> At = reinterpret(UInt8, memory, (3,2))' # \"row-major\" layout\n2×3 Array{UInt8,2}:\n 0x01  0x02  0x03\n 0x04  0x05  0x06The first way to alter the pixel order is by using the function Base.permutedims. In contrast to what we have seen before, this function will allocate a new array and copy the values in the appropriate manner.\njulia> B = permutedims(At, (2,1))\n3×2 Array{UInt8,2}:\n 0x01  0x04\n 0x02  0x05\n 0x03  0x06\nThe second way is using the function ImageCore.permuteddimsview which results in a lazy view that does not allocate a new array but instead only computes the correct values when queried.\njulia> using ImageCore\n\njulia> C = permuteddimsview(At, (2,1))\n3×2 permuteddimsview(::Array{UInt8,2}, (2, 1)) with element type UInt8:\n 0x01  0x04\n 0x02  0x05\n 0x03  0x06Either way, it is in general a good idea to make sure that the array one is working with ends up in a column-major layout."
},

{
    "location": "images/#Reinterpreting-Elements-1",
    "page": "Working with Images in Julia",
    "title": "Reinterpreting Elements",
    "category": "section",
    "text": "Up to this point, all we talked about was how to reinterpreting or permuting the dimensional layout of some continuous memory block. If you look at the examples above you will see that all the arrays have elements of type UInt8, which just means that each element is represented by a single byte in memory.Knowing all this, we can now take the idea a step further and think about reinterpreting the element types of the array. Let us consider our original vector memory again.julia> memory = [0x1, 0x2, 0x3, 0x4, 0x5, 0x6]\n6-element Array{UInt8,1}:\n 0x01\n 0x02\n 0x03\n 0x04\n 0x05\n 0x06Note how each byte is thought of as an individual element. One thing we could do instead, is think of this memory block as a vector of 3 UInt16 elements.julia> reinterpret(UInt16, memory)\n3-element Array{UInt16,1}:\n 0x0201\n 0x0403\n 0x0605Pay attention to where our original bytes ended up. In contrast to just rearranging elements as we did before, we ended up with significantly different element values. One may ask why it would ever be practical to reinterpret a memory block like this. The one word answer to this is Colors! As we will see in the remainder of this tutorial, it turns out to be a very useful thing to do when your arrays represent pixel data."
},

{
    "location": "images/#Introduction-to-Color-Models-1",
    "page": "Working with Images in Julia",
    "title": "Introduction to Color Models",
    "category": "section",
    "text": "As we discussed before, there are a various number of conventions on how to store pixel data into a binary format. That is not only true for dimension priority, but also for color information.One way color information can differ is in the color model in which they are described in. Two famous examples for color models are RGB and HSV. They essentially define how colors are conceptually made up in terms of some components. Additionally, one can decide on how many bits to use to describe each color component. By doing so one defines the available color depth.Before we look into using the actual implementation of Julia's color models, let us prototype our own imperfect toy model in order to get a better understanding of what is happening under the hood.# define our toy color model\nstruct MyRGB\n    r::UInt8\n    b::UInt8\n    g::UInt8\nendNote how we defined our new toy color model as struct. Because of this and the fact that all its components are bit types (in this case UInt8), any instantiation of our new type will be represented as a continuous block of memory as well.We can now apply our color model to our memory vector from above, and interpret the underlying memory as a vector of to MyRGB values instead.julia> reinterpret(MyRGB, memory)\n2-element Array{MyRGB,1}:\n MyRGB(0x01,0x02,0x03)\n MyRGB(0x04,0x05,0x06)Similar to the UInt16 example, we now group neighboring bytes into larger units (namely MyRGB). In contrast to the UInt16 example we are still able to access the individual components underneath. This simple toy color model already allows us to do a lot of useful things. We could define functions that work on MyRGB values in a color-space appropriate fashion. We could also define other color models and implement function to convert between them.However, our little toy color model is not yet optimal. For example it hard-codes a predefined color depth of 24 bit. We may have use-cases where we need a richer color space. One thing we could do to achieve that would be to introduce a new type in similar fashion. Still, because they have a different range of available numbers per channel (because they have a different amount of bits per channel), we would have to write a lot of specialized code to be able to appropriately handle all color models and depth.Luckily, the creators of ColorTypes.jl went a with a more generic strategy: Using parameterized types and fixed point numbers.tip: Tip\nIf you are interested in how various color models are actually designed and/or implemented in Julia, you can take a look at the ColorTypes.jl package."
},

{
    "location": "images/#Fixed-Point-Numbers-1",
    "page": "Working with Images in Julia",
    "title": "Fixed Point Numbers",
    "category": "section",
    "text": "The idea behind using fixed point numbers for each color component is fairly simple. No matter how many bits a component is made up of, we always want the largest possible value of the component to be equal to 1.0 and the smallest possible value to be equal to 0. Of course, the amount of possible intermediate numbers still depends on the number of underlying bits in the memory, but that is not much of an issue.julia> using FixedPointNumbers;\n\njulia> reinterpret(N0f8, 0xFF)\n1.0N0f8\n\njulia> reinterpret(N0f16, 0xFFFF)\n1.0N0f16Not only does this allow for simple conversion between different color depths, it also allows us to implement generic algorithms, that are completely agnostic to the utilized color depth.It is worth pointing out again, that we get all these goodies without actually changing or copying the original memory block. Remember how during this whole tutorial we have only changed the interpretation of some underlying memory, and have not had the need to copy any data so far.tip: Tip\nFor pixel data we are mainly interested in unsigned fixed point numbers, but there are others too. Check out the package FixedPointNumbers.jl for more information on fixed point numbers in general.Let us now leave our toy model behind and use the actual implementation of RGB on our example vector memory. With the first command we will interpret our data as two pixels with 8 bit per color channel, and with the second command as a single pixel of 16 bit per color channeljulia> using Colors, FixedPointNumbers;\n\njulia> reinterpret(RGB{N0f8}, memory)\n2-element Array{RGB{N0f8},1}:\n RGB{N0f8}(0.004,0.008,0.012)\n RGB{N0f8}(0.016,0.02,0.024)\n\njulia> reinterpret(RGB{N0f16}, memory)\n1-element Array{RGB{N0f16},1}:\n RGB{N0f16}(0.00783,0.01567,0.02351)Note how the values are now interpreted as floating point numbers."
},

{
    "location": "interface/#",
    "page": "High-level Interface",
    "title": "High-level Interface",
    "category": "page",
    "text": ""
},

{
    "location": "interface/#High-level-Interface-1",
    "page": "High-level Interface",
    "title": "High-level Interface",
    "category": "section",
    "text": "Integrating Augmentor into an existing project essentially requires the three steps outlined below. We will spend the rest of this document on describing all the necessary components in more detail.Import Augmentor into the namespace of your program.\nusing Augmentor\nDefine a (stochastic) image processing pipeline by chaining the desired operations using |> and *.\njulia> pl = FlipX() * FlipY() |> Zoom(0.9:0.1:1.2) |> CropSize(64,64)\n3-step Augmentor.ImmutablePipeline:\n 1.) Either: (50%) Flip the X axis. (50%) Flip the Y axis.\n 2.) Zoom by I ∈ {0.9×0.9, 1.0×1.0, 1.1×1.1, 1.2×1.2}\n 3.) Crop a 64×64 window around the center\nApply the pipeline to the existing image or set of images.\nimg_processed = augment(img_original, pl)Depending on the complexity of your problem, you may want to iterate between 2. and 3. to identify an appropriate pipeline. Take a look at the Elastic Distortions Tutorial for an example of how such an iterative process could look like."
},

{
    "location": "interface/#pipeline-1",
    "page": "High-level Interface",
    "title": "Defining a Pipeline",
    "category": "section",
    "text": "In Augmentor, a (stochastic) image-processing pipeline can be understood as a sequence of operations, for which the parameters can (but need not) be random variables. What that essentially means is that the user explicitly specifies which image operation to perform in what order. A complete list of available operations can be found at Supported Operations.To start off with a simple example, let us assume that we want to first rotate our image(s) counter-clockwise by 14°, then crop them down to the biggest possible square, and lastly resize the image(s) to a fixed size of 64 by 64 pixel. Such a pipeline would be defined as follows:julia> pl = Rotate(14) |> CropRatio(1) |> Resize(64,64)\n3-step Augmentor.ImmutablePipeline:\n 1.) Rotate 14 degree\n 2.) Crop to 1:1 aspect ratio\n 3.) Resize to 64×64Notice that in the example above there is no room for randomness. In other words, the same input image would always result in the same output image given that pipeline. If we wish for more variation we can do so by using a vector as our parameters, instead of a single number.note: Note\nIn this subsection we will focus only on how to define a pipeline, without actually thinking too much on about how to apply it to an actual image. The later will be the main topic of the rest of this document.Say we wish to adapt our pipeline such that the rotation is a little more random. More specifically lets say we want our image to be rotated by either -10°, -5°, 5°, 10°, or not at all. Other than that change we will leave the rest of the pipeline as is.julia> pl = Rotate([-10,-5,0,5,10]) |> CropRatio(1) |> Resize(64,64)\n3-step Augmentor.ImmutablePipeline:\n 1.) Rotate by θ ∈ [-10, -5, 0, 5, 10] degree\n 2.) Crop to 1:1 aspect ratio\n 3.) Resize to 64×64Variation in the parameters is only one way to introduce randomness to our pipeline. Additionally one can specify to choose one of multiple operations at random, using a utility operation called Either, which has its own convenience syntax.As an example, let us assume we wish to first either mirror our image(s) horizontally, or vertically, or not at all, and then crop it down to a size of 100 by 100 pixel around the image's center. We can specify the \"either\" using the * operator.julia> pl = FlipX() * FlipY() * NoOp() |> CropSize(100,100)\n2-step Augmentor.ImmutablePipeline:\n 1.) Either: (33%) Flip the X axis. (33%) Flip the Y axis. (33%) No operation.\n 2.) Crop a 100×100 window around the centerIt's also possible to specify the odds of for such an \"either\". For example we may want the NoOp to be twice as likely as either of the mirroring options.julia> pl = (1=>FlipX()) * (1=>FlipY()) * (2=>NoOp()) |> CropSize(100,100)\n2-step Augmentor.ImmutablePipeline:\n 1.) Either: (25%) Flip the X axis. (25%) Flip the Y axis. (50%) No operation.\n 2.) Crop a 100×100 window around the centerNow that we know how to define a pipeline, let us think about how to apply it to an image or a set of images."
},

{
    "location": "interface/#Augmentor.testpattern",
    "page": "High-level Interface",
    "title": "Augmentor.testpattern",
    "category": "Function",
    "text": "testpattern() -> Matrix{RGBA{N0f8}}\n\nLoad and return the provided 300x400 test image.\n\nThe returned image was specifically designed to be informative about the effects of the applied augmentation operations. It is thus well suited to prototype an augmentation pipeline, because it makes it easy to see what kind of effects one can achieve with it.\n\n\n\n"
},

{
    "location": "interface/#Loading-the-Example-Image-1",
    "page": "High-level Interface",
    "title": "Loading the Example Image",
    "category": "section",
    "text": "Augmentor ships with a custom example image, which was specifically designed for visualizing augmentation effects. It can be accessed by calling the function testpattern(). However, doing so should rarely be necessary in practice, since most high-level functions will default to using testpattern() if no other image is specified.testpatternusing Augmentor\nimg = testpattern()\nusing Images; # hide\nsave(joinpath(\"assets\",\"big_pattern.png\"), img); # hide\nnothing # hide(Image: testpattern)"
},

{
    "location": "interface/#Augmentor.augment",
    "page": "High-level Interface",
    "title": "Augmentor.augment",
    "category": "Function",
    "text": "augment([img], pipeline) -> imga\n\nApply the operations of the given pipeline to the image img and return the resulting image imga.\n\nThe parameter pipeline can be a subtype of Augmentor.Pipeline, a tuple of Augmentor.Operation, or a single Augmentor.Operation\n\nimg = testpattern()\naugment(img, FlipX() |> FlipY())\naugment(img, (FlipX(), FlipY()))\naugment(img, FlipX())\n\nIf img is omitted, augmentor will use the pre-provided augmentation test image returned by the function testpattern as the input image.\n\naugment(FlipX())\n\n\n\n"
},

{
    "location": "interface/#Augmentor.augment!",
    "page": "High-level Interface",
    "title": "Augmentor.augment!",
    "category": "Function",
    "text": "augment!(out, img, pipeline) -> out\n\nApply the operations of the given pipeline to the image img and write the resulting image into out.\n\nThe parameter pipeline can be a subtype of Augmentor.Pipeline, a tuple of Augmentor.Operation, or a single Augmentor.Operation\n\nimg = testpattern()\nout = similar(img)\naugment!(out, img, FlipX() |> FlipY())\naugment!(out, img, (FlipX(), FlipY()))\naugment!(out, img, FlipX())\n\n\n\n"
},

{
    "location": "interface/#Augmenting-an-Image-1",
    "page": "High-level Interface",
    "title": "Augmenting an Image",
    "category": "section",
    "text": "Once a pipeline is constructed it can be applied to an image (i.e. AbstractArray{<:ColorTypes.Colorant}), or even just to an array of numbers (i.e. AbstractArray{<:Number}), using the function augment.augmentaugment!"
},

{
    "location": "interface/#Augmentor.augmentbatch!",
    "page": "High-level Interface",
    "title": "Augmentor.augmentbatch!",
    "category": "Function",
    "text": "augmentbatch!([resource], outs, imgs, pipeline) -> outs\n\nApply the operations of the given pipeline to the images in imgs and write the resulting images into outs.\n\nBoth outs and imgs have to contain the same number of images. Each of the two variables can either be in the form of a higher dimensional array for which the last dimension enumerates the individual images, or alternatively in the form of a vector of arrays, for which each vector element denotes an image.\n\nThe parameter pipeline can be a subtype of Augmentor.Pipeline, a tuple of Augmentor.Operation, or a single Augmentor.Operation.\n\nThe optional first parameter resource can either be CPU1() (default) or CPUThreads(). In the case of the later the images will be augmented in parallel. For this to make sense make sure that the environment variable JULIA_NUM_THREADS is set to a reasonable number so that Threads.nthreads() is greater than 1.\n\n\n\n"
},

{
    "location": "interface/#Augmenting-Image-Batches-1",
    "page": "High-level Interface",
    "title": "Augmenting Image Batches",
    "category": "section",
    "text": "augmentbatch!"
},

{
    "location": "operations/#",
    "page": "Supported Operations",
    "title": "Supported Operations",
    "category": "page",
    "text": "using Augmentor, Images, Colors\nsrand(1337)\npattern = imresize(restrict(restrict(testpattern())), (60, 80))\nsave(\"assets/tiny_pattern.png\", pattern)\n# Affine Transformations\nsave(\"assets/tiny_FlipX.png\", augment(pattern, FlipX()))\nsave(\"assets/tiny_FlipY.png\", augment(pattern, FlipY()))\nsave(\"assets/tiny_Rotate90.png\", augment(pattern, Rotate90()))\nsave(\"assets/tiny_Rotate270.png\", augment(pattern, Rotate270()))\nsave(\"assets/tiny_Rotate180.png\", augment(pattern, Rotate180()))\nsave(\"assets/tiny_Rotate.png\", augment(pattern, Rotate(15)))\nsave(\"assets/tiny_ShearX.png\", augment(pattern, ShearX(10)))\nsave(\"assets/tiny_ShearY.png\", augment(pattern, ShearY(10)))\nsave(\"assets/tiny_Scale.png\", augment(pattern, Scale(0.9,1.2)))\nsave(\"assets/tiny_Zoom.png\", augment(pattern, Zoom(0.9,1.2)))\n# Distortions\nsrand(1337)\nsave(\"assets/tiny_ED1.png\", augment(pattern, ElasticDistortion(15,15,0.1)))\nsave(\"assets/tiny_ED2.png\", augment(pattern, ElasticDistortion(10,10,0.2,4,3,true)))\n# Resizing and Subsetting\nsave(\"assets/tiny_Resize.png\", augment(pattern, Resize(60,60)))\nsave(\"assets/tiny_Crop.png\", augment(pattern, Rotate(45) |> Crop(1:50,1:80)))\nsave(\"assets/tiny_CropNative.png\", augment(pattern, Rotate(45) |> CropNative(1:50,1:80)))\nsave(\"assets/tiny_CropSize.png\", augment(pattern, CropSize(20,65)))\nsave(\"assets/tiny_CropRatio.png\", augment(pattern, CropRatio(1)))\nsrand(1337)\nsave(\"assets/tiny_RCropRatio.png\", augment(pattern, RCropRatio(1)))\n# Conversion\nsave(\"assets/tiny_ConvertEltype.png\", augment(pattern, ConvertEltype(GrayA)))\nnothing;"
},

{
    "location": "operations/#operations-1",
    "page": "Supported Operations",
    "title": "Supported Operations",
    "category": "section",
    "text": "Augmentor provides a wide varitey of build-in image operations. This page provides an overview of all exported operations organized by their main category. These categories are chosen because they serve some practical purpose. For example Affine Operations allow for a special optimization under the hood when chained together.tip: Tip\nClick on an image operation for more details."
},

{
    "location": "operations/#Affine-Transformations-1",
    "page": "Supported Operations",
    "title": "Affine Transformations",
    "category": "section",
    "text": "A sizeable amount of the provided operations fall under the category of affine transformations. As such, they can be described using what is known as an affine map, which are inherently compose-able if chained together. However, utilizing such a affine formulation requires (costly) interpolation, which may not always be needed to achieve the desired effect. For that reason do some of the operations below also provide a special purpose implementation to produce their specified result. Those are usually preferred over the affine formulation if sensible considering the complete pipeline.Input  FlipX FlipY Rotate90 Rotate270 Rotate180\n(Image: ) → (Image: ) (Image: ) (Image: ) (Image: ) (Image: )\nInput  Rotate ShearX ShearY Scale Zoom\n(Image: ) → (Image: ) (Image: ) (Image: ) (Image: ) (Image: )"
},

{
    "location": "operations/#Distortions-1",
    "page": "Supported Operations",
    "title": "Distortions",
    "category": "section",
    "text": "Aside from affine transformations, Augmentor also provides functionality for performing a variety of distortions. These types of operations usually provide a much larger distribution of possible output images.Input  ElasticDistortion\n(Image: ) → (Image: )"
},

{
    "location": "operations/#Resizing-and-Subsetting-1",
    "page": "Supported Operations",
    "title": "Resizing and Subsetting",
    "category": "section",
    "text": "The input images from a given dataset can be of various shapes and sizes. Yet, it is often required by the algorithm that the data must be of uniform structure. To that end Augmentor provides a number of ways to alter or subset given images.Input  Resize\n(Image: ) → (Image: )The process of cropping is useful to discard parts of the input image. To provide this functionality lazily, applying a crop introduces a layer of representation called a \"view\" or SubArray. This is different yet compatible with how affine operations or other special purpose implementations work. This means that chaining a crop with some affine operation is perfectly fine if done sequentially. However, it is generally not advised to combine affine operations with crop operations within an Either block. Doing that would force the Either to trigger the eager computation of its branches in order to preserve type-stability.Input  Crop CropNative CropSize CropRatio RCropRatio\n(Image: ) → (Image: ) (Image: ) (Image: ) (Image: ) (Image: )"
},

{
    "location": "operations/#Conversion-and-Layout-1",
    "page": "Supported Operations",
    "title": "Conversion and Layout",
    "category": "section",
    "text": "It is not uncommon that machine learning frameworks require the data in a specific form and layout. For example many deep learning frameworks expect the colorchannel of the images to be encoded in the third dimension of a 4-dimensional array. Augmentor allows to convert from (and to) these different layouts using special operations that are mainly useful in the beginning or end of a augmentation pipeline.Category Available Operations\nConversion ConvertEltype (e.g. convert to grayscale)\nInformation Layout SplitChannels, CombineChannels, PermuteDims, Reshape"
},

{
    "location": "operations/#Utility-Operations-1",
    "page": "Supported Operations",
    "title": "Utility Operations",
    "category": "section",
    "text": "Aside from \"true\" operations that specify some kind of transformation, there are also a couple of special utility operations used for functionality such as stochastic branching.Category Available Operations\nUtility Operations NoOp, CacheImage, Either"
},

{
    "location": "operations/flipx/#",
    "page": "FlipX: Mirror horizontally",
    "title": "FlipX: Mirror horizontally",
    "category": "page",
    "text": ""
},

{
    "location": "operations/flipx/#Augmentor.FlipX",
    "page": "FlipX: Mirror horizontally",
    "title": "Augmentor.FlipX",
    "category": "Type",
    "text": "FlipX <: Augmentor.AffineOperation\n\nDescription\n\nReverses the x-order of each pixel row. Another way of describing it would be to mirror the image on the y-axis, or to mirror the image horizontally.\n\nIf created using the parameter p, the operation will be lifted into Either(p=>FlipX(), 1-p=>NoOp()), where p denotes the probability of applying FlipX and 1-p the probability for applying NoOp. See the documentation of Either for more information.\n\nUsage\n\nFlipX()\n\nFlipX(p)\n\nArguments\n\np::Number : Optional. Probability of applying the   operation. Must be in the interval [0,1].\n\nSee also\n\nFlipY, Either, augment\n\nExamples\n\njulia> using Augmentor\n\njulia> img = [200 150; 50 1]\n2×2 Array{Int64,2}:\n 200  150\n  50    1\n\njulia> img_new = augment(img, FlipX())\n2×2 Array{Int64,2}:\n 150  200\n   1   50\n\n\n\n"
},

{
    "location": "operations/flipx/#FlipX-1",
    "page": "FlipX: Mirror horizontally",
    "title": "FlipX: Mirror horizontally",
    "category": "section",
    "text": "FlipXinclude(\"optable.jl\")\n@optable FlipX()"
},

{
    "location": "operations/flipy/#",
    "page": "FlipY: Mirror vertically",
    "title": "FlipY: Mirror vertically",
    "category": "page",
    "text": ""
},

{
    "location": "operations/flipy/#Augmentor.FlipY",
    "page": "FlipY: Mirror vertically",
    "title": "Augmentor.FlipY",
    "category": "Type",
    "text": "FlipY <: Augmentor.AffineOperation\n\nDescription\n\nReverses the y-order of each pixel column. Another way of describing it would be to mirror the image on the x-axis, or to mirror the image vertically.\n\nIf created using the parameter p, the operation will be lifted into Either(p=>FlipY(), 1-p=>NoOp()), where p denotes the probability of applying FlipY and 1-p the probability for applying NoOp. See the documentation of Either for more information.\n\nUsage\n\nFlipY()\n\nFlipY(p)\n\nArguments\n\np::Number : Optional. Probability of applying the   operation. Must be in the interval [0,1].\n\nSee also\n\nFlipX, Either, augment\n\nExamples\n\njulia> using Augmentor\n\njulia> img = [200 150; 50 1]\n2×2 Array{Int64,2}:\n 200  150\n  50    1\n\njulia> img_new = augment(img, FlipY())\n2×2 Array{Int64,2}:\n  50    1\n 200  150\n\n\n\n"
},

{
    "location": "operations/flipy/#FlipY-1",
    "page": "FlipY: Mirror vertically",
    "title": "FlipY: Mirror vertically",
    "category": "section",
    "text": "FlipYinclude(\"optable.jl\")\n@optable FlipY()"
},

{
    "location": "operations/rotate90/#",
    "page": "Rotate90: Rotate upwards 90 degree",
    "title": "Rotate90: Rotate upwards 90 degree",
    "category": "page",
    "text": ""
},

{
    "location": "operations/rotate90/#Augmentor.Rotate90",
    "page": "Rotate90: Rotate upwards 90 degree",
    "title": "Augmentor.Rotate90",
    "category": "Type",
    "text": "Rotate90 <: Augmentor.AffineOperation\n\nDescription\n\nRotates the image upwards 90 degrees. This is a special case rotation because it can be performed very efficiently by simply rearranging the existing pixels. However, it is generally not the case that the output image will have the same size as the input image, which is something to be aware of.\n\nIf created using the parameter p, the operation will be lifted into Either(p=>Rotate90(), 1-p=>NoOp()), where p denotes the probability of applying Rotate90 and 1-p the probability for applying NoOp. See the documentation of Either for more information.\n\nUsage\n\nRotate90()\n\nRotate90(p)\n\nArguments\n\np::Number : Optional. Probability of applying the   operation. Must be in the interval [0,1].\n\nSee also\n\nRotate180, Rotate270, Rotate, Either, augment\n\nExamples\n\njulia> using Augmentor\n\njulia> img = [200 150; 50 1]\n2×2 Array{Int64,2}:\n 200  150\n  50    1\n\njulia> img_new = augment(img, Rotate90())\n2×2 Array{Int64,2}:\n 150   1\n 200  50\n\n\n\n"
},

{
    "location": "operations/rotate90/#Rotate90-1",
    "page": "Rotate90: Rotate upwards 90 degree",
    "title": "Rotate90: Rotate upwards 90 degree",
    "category": "section",
    "text": "Rotate90include(\"optable.jl\")\n@optable Rotate90()"
},

{
    "location": "operations/rotate270/#",
    "page": "Rotate270: Rotate downwards 90 degree",
    "title": "Rotate270: Rotate downwards 90 degree",
    "category": "page",
    "text": ""
},

{
    "location": "operations/rotate270/#Augmentor.Rotate270",
    "page": "Rotate270: Rotate downwards 90 degree",
    "title": "Augmentor.Rotate270",
    "category": "Type",
    "text": "Rotate270 <: Augmentor.AffineOperation\n\nDescription\n\nRotates the image upwards 270 degrees, which can also be described as rotating the image downwards 90 degrees. This is a special case rotation, because it can be performed very efficiently by simply rearranging the existing pixels. However, it is generally not the case that the output image will have the same size as the input image, which is something to be aware of.\n\nIf created using the parameter p, the operation will be lifted into Either(p=>Rotate270(), 1-p=>NoOp()), where p denotes the probability of applying Rotate270 and 1-p the probability for applying NoOp. See the documentation of Either for more information.\n\nUsage\n\nRotate270()\n\nRotate270(p)\n\nArguments\n\np::Number : Optional. Probability of applying the   operation. Must be in the interval [0,1].\n\nSee also\n\nRotate90, Rotate180, Rotate, Either, augment\n\nExamples\n\njulia> using Augmentor\n\njulia> img = [200 150; 50 1]\n2×2 Array{Int64,2}:\n 200  150\n  50    1\n\njulia> img_new = augment(img, Rotate270())\n2×2 Array{Int64,2}:\n 50  200\n  1  150\n\n\n\n"
},

{
    "location": "operations/rotate270/#Rotate270-1",
    "page": "Rotate270: Rotate downwards 90 degree",
    "title": "Rotate270: Rotate downwards 90 degree",
    "category": "section",
    "text": "Rotate270include(\"optable.jl\")\n@optable Rotate270()"
},

{
    "location": "operations/rotate180/#",
    "page": "Rotate180: Rotate by 180 degree",
    "title": "Rotate180: Rotate by 180 degree",
    "category": "page",
    "text": ""
},

{
    "location": "operations/rotate180/#Augmentor.Rotate180",
    "page": "Rotate180: Rotate by 180 degree",
    "title": "Augmentor.Rotate180",
    "category": "Type",
    "text": "Rotate180 <: Augmentor.AffineOperation\n\nDescription\n\nRotates the image 180 degrees. This is a special case rotation because it can be performed very efficiently by simply rearranging the existing pixels. Furthermore, the output image will have the same dimensions as the input image.\n\nIf created using the parameter p, the operation will be lifted into Either(p=>Rotate180(), 1-p=>NoOp()), where p denotes the probability of applying Rotate180 and 1-p the probability for applying NoOp. See the documentation of Either for more information.\n\nUsage\n\nRotate180()\n\nRotate180(p)\n\nArguments\n\np::Number : Optional. Probability of applying the   operation. Must be in the interval [0,1].\n\nSee also\n\nRotate90, Rotate270, Rotate, Either, augment\n\nExamples\n\njulia> using Augmentor\n\njulia> img = [200 150; 50 1]\n2×2 Array{Int64,2}:\n 200  150\n  50    1\n\njulia> img_new = augment(img, Rotate180())\n2×2 Array{Int64,2}:\n   1   50\n 150  200\n\n\n\n"
},

{
    "location": "operations/rotate180/#Rotate180-1",
    "page": "Rotate180: Rotate by 180 degree",
    "title": "Rotate180: Rotate by 180 degree",
    "category": "section",
    "text": "Rotate180include(\"optable.jl\")\n@optable Rotate180()"
},

{
    "location": "operations/rotate/#",
    "page": "Rotate: Arbitrary rotations",
    "title": "Rotate: Arbitrary rotations",
    "category": "page",
    "text": ""
},

{
    "location": "operations/rotate/#Augmentor.Rotate",
    "page": "Rotate: Arbitrary rotations",
    "title": "Augmentor.Rotate",
    "category": "Type",
    "text": "Rotate <: Augmentor.AffineOperation\n\nDescription\n\nRotate the image upwards for the given degree. This operation can only be described as an affine transformation and will in general cause other operations of the pipeline to use their affine formulation as well (if they have one).\n\nIn contrast to the special case rotations outlined above, the type Rotate can describe any arbitrary number of degrees. It will always perform the rotation around the center of the image. This can be particularly useful when combining the operation with CropNative.\n\nUsage\n\nRotate(degree)\n\nArguments\n\ndegree : Real or AbstractVector of Real that denote   the rotation angle(s) in degree. If a vector is provided,   then a random element will be sampled each time the operation   is applied.\n\nSee also\n\nRotate90, Rotate180, Rotate270, CropNative, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# rotate exactly 45 degree\naugment(img, Rotate(45))\n\n# rotate between 10 and 20 degree upwards\naugment(img, Rotate(10:20))\n\n# rotate one of the five specified degrees\naugment(img, Rotate([-10, -5, 0, 5, 10]))\n\n\n\n"
},

{
    "location": "operations/rotate/#Rotate-1",
    "page": "Rotate: Arbitrary rotations",
    "title": "Rotate: Arbitrary rotations",
    "category": "section",
    "text": "RotateIn contrast to the special case rotations outlined above, the type Rotate can describe any arbitrary number of degrees. It will always perform the rotation around the center of the image. This can be particularly useful when combining the operation with CropNative.include(\"optable.jl\")\n@optable Rotate(15)It is also possible to pass some abstract vector to the constructor, in which case Augmentor will randomly sample one of its elements every time the operation is applied.include(\"optable.jl\")\n@optable 10 => Rotate(-10:10)"
},

{
    "location": "operations/shearx/#",
    "page": "ShearX: Shear horizontally",
    "title": "ShearX: Shear horizontally",
    "category": "page",
    "text": ""
},

{
    "location": "operations/shearx/#Augmentor.ShearX",
    "page": "ShearX: Shear horizontally",
    "title": "Augmentor.ShearX",
    "category": "Type",
    "text": "ShearX <: Augmentor.AffineOperation\n\nDescription\n\nShear the image horizontally for the given degree. This operation can only be described as an affine transformation and will in general cause other operations of the pipeline to use their affine formulation as well (if they have one).\n\nIt will always perform the transformation around the center of the image. This can be particularly useful when combining the operation with CropNative.\n\nUsage\n\nShearX(degree)\n\nArguments\n\ndegree : Real or AbstractVector of Real that denote   the shearing angle(s) in degree. If a vector is provided,   then a random element will be sampled each time the operation   is applied.\n\nSee also\n\nShearY, CropNative, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# shear horizontally exactly 5 degree\naugment(img, ShearX(5))\n\n# shear horizontally between 10 and 20 degree to the right\naugment(img, ShearX(10:20))\n\n# shear horizontally one of the five specified degrees\naugment(img, ShearX([-10, -5, 0, 5, 10]))\n\n\n\n"
},

{
    "location": "operations/shearx/#ShearX-1",
    "page": "ShearX: Shear horizontally",
    "title": "ShearX: Shear horizontally",
    "category": "section",
    "text": "ShearXIt will always perform the transformation around the center of the image. This can be particularly useful when combining the operation with CropNative.include(\"optable.jl\")\n@optable ShearX(10)It is also possible to pass some abstract vector to the constructor, in which case Augmentor will randomly sample one of its elements every time the operation is applied.include(\"optable.jl\")\n@optable 10 => ShearX(-10:10)"
},

{
    "location": "operations/sheary/#",
    "page": "ShearY: Shear vertically",
    "title": "ShearY: Shear vertically",
    "category": "page",
    "text": ""
},

{
    "location": "operations/sheary/#Augmentor.ShearY",
    "page": "ShearY: Shear vertically",
    "title": "Augmentor.ShearY",
    "category": "Type",
    "text": "ShearY <: Augmentor.AffineOperation\n\nDescription\n\nShear the image vertically for the given degree. This operation can only be described as an affine transformation and will in general cause other operations of the pipeline to use their affine formulation as well (if they have one).\n\nIt will always perform the transformation around the center of the image. This can be particularly useful when combining the operation with CropNative.\n\nUsage\n\nShearY(degree)\n\nArguments\n\ndegree : Real or AbstractVector of Real that denote   the shearing angle(s) in degree. If a vector is provided,   then a random element will be sampled each time the operation   is applied.\n\nSee also\n\nShearX, CropNative, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# shear vertically exactly 5 degree\naugment(img, ShearY(5))\n\n# shear vertically between 10 and 20 degree upwards\naugment(img, ShearY(10:20))\n\n# shear vertically one of the five specified degrees\naugment(img, ShearY([-10, -5, 0, 5, 10]))\n\n\n\n"
},

{
    "location": "operations/sheary/#ShearY-1",
    "page": "ShearY: Shear vertically",
    "title": "ShearY: Shear vertically",
    "category": "section",
    "text": "ShearYIt will always perform the transformation around the center of the image. This can be particularly useful when combining the operation with CropNative.include(\"optable.jl\")\n@optable ShearY(10)It is also possible to pass some abstract vector to the constructor, in which case Augmentor will randomly sample one of its elements every time the operation is applied.include(\"optable.jl\")\n@optable 10 => ShearY(-10:10)"
},

{
    "location": "operations/scale/#",
    "page": "Scale: Relative resizing",
    "title": "Scale: Relative resizing",
    "category": "page",
    "text": ""
},

{
    "location": "operations/scale/#Augmentor.Scale",
    "page": "Scale: Relative resizing",
    "title": "Augmentor.Scale",
    "category": "Type",
    "text": "Scale <: Augmentor.AffineOperation\n\nDescription\n\nMultiplies the image height and image width by the specified factors. This means that the size of the output image depends on the size of the input image.\n\nThe provided factors can either be numbers or vectors of numbers.\n\nIf numbers are provided, then the operation is deterministic and will always scale the input image with the same factors.\nIn the case vectors are provided, then each time the operation is applied a valid index is sampled and the elements corresponding to that index are used as scaling factors.\n\nThe scaling is performed relative to the image center, which can be useful when following the operation with CropNative.\n\nUsage\n\nScale(factors)\n\nScale(factors...)\n\nArguments\n\nfactors : NTuple or Vararg of Real or   AbstractVector that denote the scale factor(s) for each   array dimension. If only one variable is specified it is   assumed that height and width should be scaled by the same   factor(s).\n\nSee also\n\nZoom, Resize, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# half the image size\naugment(img, Scale(0.5))\n\n# uniformly scale by a random factor from 1.2, 1.3, or 1.4\naugment(img, Scale([1.2, 1.3, 1.4]))\n\n# scale by either 0.5x0.7 or by 0.6x0.8\naugment(img, Scale([0.5, 0.6], [0.7, 0.8]))\n\n\n\n"
},

{
    "location": "operations/scale/#Scale-1",
    "page": "Scale: Relative resizing",
    "title": "Scale: Relative resizing",
    "category": "section",
    "text": "Scaleinclude(\"optable.jl\")\n@optable Scale(0.9,0.5)In the case that only a single scale factor is specified, the operation will assume that the intention is to scale all dimensions uniformly by that factor.include(\"optable.jl\")\n@optable Scale(1.2)It is also possible to pass some abstract vector(s) to the constructor, in which case Augmentor will randomly sample one of its elements every time the operation is applied.include(\"optable.jl\")\n@optable 10 => Scale(0.9:0.05:1.2)"
},

{
    "location": "operations/zoom/#",
    "page": "Zoom: Scale without resize",
    "title": "Zoom: Scale without resize",
    "category": "page",
    "text": ""
},

{
    "location": "operations/zoom/#Augmentor.Zoom",
    "page": "Zoom: Scale without resize",
    "title": "Augmentor.Zoom",
    "category": "Type",
    "text": "Zoom <: Augmentor.ImageOperation\n\nDescription\n\nScales the image height and image width by the specified factors, but crops the image such that the original size is preserved.\n\nThe provided factors can either be numbers or vectors of numbers.\n\nIf numbers are provided, then the operation is deterministic and will always scale the input image with the same factors.\nIn the case vectors are provided, then each time the operation is applied a valid index is sampled and the elements corresponding to that index are used as scaling factors.\n\nIn contrast to Scale the size of the output image is the same as the size of the input image, while the content is scaled the same way. The same effect could be achieved by following a Scale with a CropSize, with the caveat that one would need to know the exact size of the input image before-hand.\n\nUsage\n\nZoom(factors)\n\nZoom(factors...)\n\nArguments\n\nfactors : NTuple or Vararg of Real or   AbstractVector that denote the scale factor(s) for each   array dimension. If only one variable is specified it is   assumed that height and width should be scaled by the same   factor(s).\n\nSee also\n\nScale, Resize, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# half the image size\naugment(img, Zoom(0.5))\n\n# uniformly scale by a random factor from 1.2, 1.3, or 1.4\naugment(img, Zoom([1.2, 1.3, 1.4]))\n\n# scale by either 0.5x0.7 or by 0.6x0.8\naugment(img, Zoom([0.5, 0.6], [0.7, 0.8]))\n\n\n\n"
},

{
    "location": "operations/zoom/#Zoom-1",
    "page": "Zoom: Scale without resize",
    "title": "Zoom: Scale without resize",
    "category": "section",
    "text": "Zoominclude(\"optable.jl\")\n@optable Zoom(1.2)It is also possible to pass some abstract vector to the constructor, in which case Augmentor will randomly sample one of its elements every time the operation is applied.include(\"optable.jl\")\n@optable 10 => Zoom(0.9:0.05:1.3)"
},

{
    "location": "operations/elasticdistortion/#",
    "page": "ElasticDistortion: Smoothed random distortions",
    "title": "ElasticDistortion: Smoothed random distortions",
    "category": "page",
    "text": ""
},

{
    "location": "operations/elasticdistortion/#Augmentor.ElasticDistortion",
    "page": "ElasticDistortion: Smoothed random distortions",
    "title": "Augmentor.ElasticDistortion",
    "category": "Type",
    "text": "ElasticDistortion <: Augmentor.ImageOperation\n\nDescription\n\nDistorts the given image using a randomly (uniform) generated vector field of the given grid size. This field will be stretched over the given image when applied, which in turn will morph the original image into a new image using a linear interpolation of both the image and the vector field.\n\nIn contrast to [RandomDistortion], the resulting vector field is also smoothed using a Gaussian filter with of parameter sigma. This will result in a less chaotic vector field and thus resemble a more natural distortion.\n\nUsage\n\nElasticDistortion(gridheight, gridwidth, scale, sigma, [iter=1], [border=false], [norm=true])\n\nElasticDistortion(gridheight, gridwidth, scale; [sigma=2], [iter=1], [border=false], [norm=true])\n\nElasticDistortion(gridheight, [gridwidth]; [scale=0.2], [sigma=2], [iter=1], [border=false], [norm=true])\n\nArguments\n\ngridheight : The grid height of the displacement vector   field. This effectively specifies the number of vertices   along the Y dimension used as landmarks, where all the   positions between the grid points are interpolated.\ngridwidth : The grid width of the displacement vector   field. This effectively specifies the number of vertices   along the Y dimension used as landmarks, where all the   positions between the grid points are interpolated.\nscale : Optional. The scaling factor applied to all   displacement vectors in the field. This effectively defines   the \"strength\" of the deformation. There is no theoretical   upper limit to this factor, but a value somewhere between   0.01 and 1.0 seem to be the most reasonable choices.   Default to 0.2.\nsigma : Optional. Sigma parameter of the Gaussian filter.   This parameter effectively controls the strength of the   smoothing. Defaults to 2.\niter : Optional. The number of times the smoothing   operation is applied to the displacement vector field. This   is especially useful if border = false because the border   will be reset to zero after each pass. Thus the displacement   is a little less aggressive towards the borders of the image   than it is towards its center. Defaults to   1.\nborder : Optional. Specifies if the borders should be   distorted as well. If false, the borders of the image will   be preserved. This effectively pins the outermost vertices on   their original position and the operation thus only distorts   the inner content of the image. Defaults to   false.\nnorm : Optional. If true, the displacement vectors of   the field will be normalized by the norm of the field. This   will have the effect that the scale factor should be more   or less independent of the grid size. Defaults to   true.\n\nSee also\n\naugment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# distort with pinned borders\naugment(img, ElasticDistortion(15, 15; scale = 0.1))\n\n# distort everything more smoothly.\naugment(img, ElasticDistortion(10, 10; sigma = 4, iter=3, border=true))\n\n\n\n"
},

{
    "location": "operations/elasticdistortion/#ElasticDistortion-1",
    "page": "ElasticDistortion: Smoothed random distortions",
    "title": "ElasticDistortion: Smoothed random distortions",
    "category": "section",
    "text": "ElasticDistortioninclude(\"optable.jl\")\n@optable 10 => ElasticDistortion(15,15,0.1)include(\"optable.jl\")\n@optable 10 => ElasticDistortion(10,10,0.2,4,3,true)"
},

{
    "location": "operations/crop/#",
    "page": "Crop: Subset image",
    "title": "Crop: Subset image",
    "category": "page",
    "text": ""
},

{
    "location": "operations/crop/#Augmentor.Crop",
    "page": "Crop: Subset image",
    "title": "Augmentor.Crop",
    "category": "Type",
    "text": "Crop <: Augmentor.ImageOperation\n\nDescription\n\nCrops out the area denoted by the specified pixel ranges.\n\nFor example the operation Crop(5:100, 2:10) would denote a crop for the rectangle that starts at x=2 and y=5 in the top left corner and ends at x=10 and y=100 in the bottom right corner. As we can see the y-axis is specified first, because that is how the image is stored in an array. Thus the order of the provided indices ranges needs to reflect the order of the array dimensions.\n\nUsage\n\nCrop(indices)\n\nCrop(indices...)\n\nArguments\n\nindices : NTuple or Vararg of UnitRange that denote   the cropping range for each array dimension. This is very   similar to how the indices for view are specified.\n\nSee also\n\nCropNative, CropSize, CropRatio, augment\n\nExamples\n\njulia> using Augmentor\n\njulia> img = testpattern()\n300×400 Array{RGBA{N0f8},2}:\n[...]\n\njulia> augment(img, Crop(1:30, 361:400)) # crop upper right corner\n30×40 Array{RGBA{N0f8},2}:\n[...]\n\n\n\n"
},

{
    "location": "operations/crop/#Crop-1",
    "page": "Crop: Subset image",
    "title": "Crop: Subset image",
    "category": "section",
    "text": "Cropinclude(\"optable.jl\")\n@optable Crop(70:140,25:155)"
},

{
    "location": "operations/cropnative/#",
    "page": "CropNative: Subset image",
    "title": "CropNative: Subset image",
    "category": "page",
    "text": ""
},

{
    "location": "operations/cropnative/#Augmentor.CropNative",
    "page": "CropNative: Subset image",
    "title": "Augmentor.CropNative",
    "category": "Type",
    "text": "CropNative <: Augmentor.ImageOperation\n\nDescription\n\nCrops out the area denoted by the specified pixel ranges.\n\nFor example the operation CropNative(5:100, 2:10) would denote a crop for the rectangle that starts at x=2 and y=5 in the top left corner of native space and ends at x=10 and y=100 in the bottom right corner of native space.\n\nIn contrast to Crop, the position x=1 y=1 is not necessarily located at the top left of the current image, but instead depends on the cumulative effect of the previous transformations. The reason for this is because affine transformations are usually performed around the center of the image, which is reflected in \"native space\". This is useful for combining transformations such as Rotate or ShearX with a crop around the center area.\n\nUsage\n\nCropNative(indices)\n\nCropNative(indices...)\n\nArguments\n\nindices : NTuple or Vararg of UnitRange that denote   the cropping range for each array dimension. This is very   similar to how the indices for view are specified.\n\nSee also\n\nCrop, CropSize, CropRatio, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# cropped at top left corner\naugment(img, Rotate(45) |> Crop(1:300, 1:400))\n\n# cropped around center of rotated image\naugment(img, Rotate(45) |> CropNative(1:300, 1:400))\n\n\n\n"
},

{
    "location": "operations/cropnative/#CropNative-1",
    "page": "CropNative: Subset image",
    "title": "CropNative: Subset image",
    "category": "section",
    "text": "CropNativeinclude(\"optable.jl\")\n@optable \"cropn1\" => (Rotate(45),Crop(1:210,1:280))\n@optable \"cropn2\" => (Rotate(45),CropNative(1:210,1:280))\ntbl = string(\n    \"`(Rotate(45), Crop(1:210,1:280))` | `(Rotate(45), CropNative(1:210,1:280))`\\n\",\n    \"-----|-----\\n\",\n    \"![input](../assets/cropn1.png) | ![output](../assets/cropn2.png)\\n\"\n)\nMarkdown.parse(tbl)"
},

{
    "location": "operations/cropsize/#",
    "page": "CropSize: Crop centered window",
    "title": "CropSize: Crop centered window",
    "category": "page",
    "text": ""
},

{
    "location": "operations/cropsize/#Augmentor.CropSize",
    "page": "CropSize: Crop centered window",
    "title": "Augmentor.CropSize",
    "category": "Type",
    "text": "CropSize <: Augmentor.ImageOperation\n\nDescription\n\nCrops out the area of the specified pixel size around the center of the input image.\n\nFor example the operation CropSize(10, 50) would denote a crop for a rectangle of height 10 and width 50 around the center of the input image.\n\nUsage\n\nCropSize(size)\n\nCropSize(size...)\n\nArguments\n\nsize : NTuple or Vararg of Int that denote the   output size in pixel for each dimension.\n\nSee also\n\nCropRatio, Crop, CropNative, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# cropped around center of rotated image\naugment(img, Rotate(45) |> CropSize(300, 400))\n\n\n\n"
},

{
    "location": "operations/cropsize/#CropSize-1",
    "page": "CropSize: Crop centered window",
    "title": "CropSize: Crop centered window",
    "category": "section",
    "text": "CropSizeinclude(\"optable.jl\")\n@optable CropSize(45,225)"
},

{
    "location": "operations/cropratio/#",
    "page": "CropRatio: Crop centered window",
    "title": "CropRatio: Crop centered window",
    "category": "page",
    "text": ""
},

{
    "location": "operations/cropratio/#Augmentor.CropRatio",
    "page": "CropRatio: Crop centered window",
    "title": "Augmentor.CropRatio",
    "category": "Type",
    "text": "CropRatio <: Augmentor.ImageOperation\n\nDescription\n\nCrops out the biggest area around the center of the given image such that the output image satisfies the specified aspect ratio (i.e. width divided by height).\n\nFor example the operation CropRatio(1) would denote a crop for the biggest square around the center of the image.\n\nFor randomly placed crops take a look at RCropRatio.\n\nUsage\n\nCropRatio(ratio)\n\nCropRatio(; ratio = 1)\n\nArguments\n\nratio::Number : Optional. A number denoting the aspect   ratio. For example specifying ratio=16/9 would denote a 16:9   aspect ratio. Defaults to 1, which describes a square crop.\n\nSee also\n\nRCropRatio, CropSize, Crop, CropNative, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# crop biggest square around the image center\naugment(img, CropRatio(1))\n\n\n\n"
},

{
    "location": "operations/cropratio/#CropRatio-1",
    "page": "CropRatio: Crop centered window",
    "title": "CropRatio: Crop centered window",
    "category": "section",
    "text": "CropRatioinclude(\"optable.jl\")\n@optable CropRatio(1)"
},

{
    "location": "operations/rcropratio/#",
    "page": "RCropRatio: Crop random window",
    "title": "RCropRatio: Crop random window",
    "category": "page",
    "text": ""
},

{
    "location": "operations/rcropratio/#Augmentor.RCropRatio",
    "page": "RCropRatio: Crop random window",
    "title": "Augmentor.RCropRatio",
    "category": "Type",
    "text": "RCropRatio <: Augmentor.ImageOperation\n\nDescription\n\nCrops out the biggest possible area at some random position of the given image, such that the output image satisfies the specified aspect ratio (i.e. width divided by height).\n\nFor example the operation RCropRatio(1) would denote a crop for the biggest possible square. If there is more than one such square, then one will be selected at random.\n\nUsage\n\nRCropRatio(ratio)\n\nRCropRatio(; ratio = 1)\n\nArguments\n\nratio::Number : Optional. A number denoting the aspect   ratio. For example specifying ratio=16/9 would denote a 16:9   aspect ratio. Defaults to 1, which describes a square crop.\n\nSee also\n\nCropRatio, CropSize, Crop, CropNative, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# crop a randomly placed square of maxmimum size\naugment(img, RCropRatio(1))\n\n\n\n"
},

{
    "location": "operations/rcropratio/#RCropRatio-1",
    "page": "RCropRatio: Crop random window",
    "title": "RCropRatio: Crop random window",
    "category": "section",
    "text": "RCropRatioinclude(\"optable.jl\")\n@optable 10 => RCropRatio(1)"
},

{
    "location": "operations/resize/#",
    "page": "Resize: Set static image size",
    "title": "Resize: Set static image size",
    "category": "page",
    "text": ""
},

{
    "location": "operations/resize/#Augmentor.Resize",
    "page": "Resize: Set static image size",
    "title": "Augmentor.Resize",
    "category": "Type",
    "text": "Resize <: Augmentor.ImageOperation\n\nDescription\n\nTransforms the image into a fixed specified pixel size.\n\nThis operation does not take any measures to preserve aspect ratio of the source image. Instead, the original image will simply be resized to the given dimensions. This is useful when one needs a set of images to all be of the exact same size.\n\nUsage\n\nResize(; height=64, width=64)\n\nResize(size)\n\nResize(size...)\n\nArguments\n\nsize : NTuple or Vararg of Int that denote the   output size in pixel for each dimension.\n\nSee also\n\nCropSize, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\naugment(img, Resize(30, 40))\n\n\n\n"
},

{
    "location": "operations/resize/#Resize-1",
    "page": "Resize: Set static image size",
    "title": "Resize: Set static image size",
    "category": "section",
    "text": "Resizeinclude(\"optable.jl\")\n@optable Resize(100,150)"
},

{
    "location": "operations/converteltype/#",
    "page": "ConvertEltype: Color conversion",
    "title": "ConvertEltype: Color conversion",
    "category": "page",
    "text": ""
},

{
    "location": "operations/converteltype/#Augmentor.ConvertEltype",
    "page": "ConvertEltype: Color conversion",
    "title": "Augmentor.ConvertEltype",
    "category": "Type",
    "text": "ConvertEltype <: Augmentor.Operation\n\nDescription\n\nConvert the element type of the given array/image into the given eltype. This operation is especially useful for converting color images to grayscale (or the other way around). That said the operation is not specific to color types and can also be used for numeric arrays (e.g. with separated channels).\n\nNote that this is an element-wise convert function. Thus it can not be used to combine or separate color channels. Use SplitChannels or CombineChannels for those purposes.\n\nUsage\n\nConvertEltype(eltype)\n\nArguments\n\neltype : The eltype of the resulting array/image.\n\nSee also\n\nCombineChannels, SplitChannels, augment\n\nExamples\n\njulia> using Augmentor, Colors\n\njulia> A = rand(RGB, 10, 10) # three color channels\n10×10 Array{RGB{Float64},2}:\n[...]\n\njulia> augment(A, ConvertEltype(Gray)) # convert to grayscale\n10×10 Array{Gray{Float64},2}:\n[...]\n\njulia> augment(A, ConvertEltype(Gray{Float32})) # more specific\n10×10 Array{Gray{Float32},2}:\n[...]\n\n\n\n"
},

{
    "location": "operations/converteltype/#ConvertEltype-1",
    "page": "ConvertEltype: Color conversion",
    "title": "ConvertEltype: Color conversion",
    "category": "section",
    "text": "ConvertEltypeinclude(\"optable.jl\")\n@optable ConvertEltype(GrayA)"
},

{
    "location": "operations/splitchannels/#",
    "page": "SplitChannels: Separate color channels",
    "title": "SplitChannels: Separate color channels",
    "category": "page",
    "text": ""
},

{
    "location": "operations/splitchannels/#Augmentor.SplitChannels",
    "page": "SplitChannels: Separate color channels",
    "title": "Augmentor.SplitChannels",
    "category": "Type",
    "text": "SplitChannels <: Augmentor.Operation\n\nDescription\n\nSplits out the color channels of the given image using the function ImageCore.channelview. This will effectively create a new array dimension for the colors in the front. In contrast to ImageCore.channelview it will also result in a new dimension for Gray images.\n\nThis operation is mainly useful at the end of a pipeline in combination with PermuteDims in order to prepare the image for the training algorithm, which often requires the color channels to be separate.\n\nUsage\n\nSplitChannels()\n\nSee also\n\nPermuteDims, CombineChannels, augment\n\nExamples\n\njulia> using Augmentor\n\njulia> img = testpattern()\n300×400 Array{RGBA{N0f8},2}:\n[...]\n\njulia> augment(img, SplitChannels())\n4×300×400 Array{N0f8,3}:\n[...]\n\njulia> augment(img, SplitChannels() |> PermuteDims(3,2,1))\n400×300×4 Array{N0f8,3}:\n[...]\n\n\n\n"
},

{
    "location": "operations/splitchannels/#SplitChannels-1",
    "page": "SplitChannels: Separate color channels",
    "title": "SplitChannels: Separate color channels",
    "category": "section",
    "text": "SplitChannels"
},

{
    "location": "operations/combinechannels/#",
    "page": "ComineChannels: Combine color channels",
    "title": "ComineChannels: Combine color channels",
    "category": "page",
    "text": ""
},

{
    "location": "operations/combinechannels/#Augmentor.CombineChannels",
    "page": "ComineChannels: Combine color channels",
    "title": "Augmentor.CombineChannels",
    "category": "Type",
    "text": "CombineChannels <: Augmentor.Operation\n\nDescription\n\nCombines the first dimension of a given array into a colorant of type colortype using the function ImageCore.colorview. The main difference is that a separate color channel is also expected for Gray images.\n\nThe shape of the input image has to be appropriate for the given colortype, which also means that the separated color channel has to be the first dimension of the array. See PermuteDims if that is not the case.\n\nUsage\n\nCombineChannels(colortype)\n\nArguments\n\ncolortype : The color type of the resulting image. Must   be a subtype of ColorTypes.Colorant and match the color   channel of the given image.\n\nSee also\n\nSplitChannels, PermuteDims, augment\n\nExamples\n\njulia> using Augmentor, Colors\n\njulia> A = rand(3, 10, 10) # three color channels\n3×10×10 Array{Float64,3}:\n[...]\n\njulia> augment(A, CombineChannels(RGB))\n10×10 Array{RGB{Float64},2}:\n[...]\n\njulia> B = rand(1, 10, 10) # singleton color channel\n1×10×10 Array{Float64,3}:\n[...]\n\njulia> augment(B, CombineChannels(Gray))\n10×10 Array{Gray{Float64},2}:\n[...]\n\n\n\n"
},

{
    "location": "operations/combinechannels/#CombineChannels-1",
    "page": "ComineChannels: Combine color channels",
    "title": "ComineChannels: Combine color channels",
    "category": "section",
    "text": "CombineChannels"
},

{
    "location": "operations/permutedims/#",
    "page": "PermuteDims: Change dimension order",
    "title": "PermuteDims: Change dimension order",
    "category": "page",
    "text": ""
},

{
    "location": "operations/permutedims/#Augmentor.PermuteDims",
    "page": "PermuteDims: Change dimension order",
    "title": "Augmentor.PermuteDims",
    "category": "Type",
    "text": "PermuteDims <: Augmentor.Operation\n\nDescription\n\nPermute the dimensions of the given array with the predefined permutation perm. This operation is particularly useful if the order of the dimensions needs to be different than the default julian layout.\n\nAugmentor expects the given images to be in vertical-major layout for which the colors are encoded in the element type itself. Many deep learning frameworks however require their input in a different order. For example it is not untypical that the color channels are expected to be encoded in the third dimension.\n\nUsage\n\nPermuteDims(perm)\n\nPermuteDims(perm...)\n\nArguments\n\nperm : The concrete dimension permutation that should be   used. Has to be specified as a Vararg{Int} or as a NTuple   of Int. The length of perm has to match the number of   dimensions of the expected input image to that operation.\n\nSee also\n\nSplitChannels, CombineChannels, augment\n\nExamples\n\njulia> using Augmentor, Colors\n\njulia> A = rand(10, 5, 3) # width=10, height=5, and 3 color channels\n10×5×3 Array{Float64,3}:\n[...]\n\njulia> img = augment(A, PermuteDims(3,2,1) |> CombineChannels(RGB))\n5×10 Array{RGB{Float64},2}:\n[...]\n\njulia> img2 = testpattern()\n300×400 Array{RGBA{N0f8},2}:\n[...]\n\njulia> B = augment(img2, SplitChannels() |> PermuteDims(3,2,1))\n400×300×4 Array{N0f8,3}:\n[...]\n\n\n\n"
},

{
    "location": "operations/permutedims/#PermuteDims-1",
    "page": "PermuteDims: Change dimension order",
    "title": "PermuteDims: Change dimension order",
    "category": "section",
    "text": "PermuteDims"
},

{
    "location": "operations/reshape/#",
    "page": "Reshape: Reinterpret shape",
    "title": "Reshape: Reinterpret shape",
    "category": "page",
    "text": ""
},

{
    "location": "operations/reshape/#Augmentor.Reshape",
    "page": "Reshape: Reinterpret shape",
    "title": "Augmentor.Reshape",
    "category": "Type",
    "text": "Reshape <: Augmentor.Operation\n\nDescription\n\nReinterpret the shape of the given array of numbers or colorants. This is useful for example to create singleton dimensions that deep learning frameworks may need for colorless images, or for converting an image to a feature vector and vice versa.\n\nUsage\n\nReshape(dims)\n\nReshape(dims...)\n\nArguments\n\ndims : The new sizes for each dimension of the output   image. Has to be specified as a Vararg{Int} or as a   NTuple of Int.\n\nSee also\n\nCombineChannels, augment\n\nExamples\n\njulia> using Augmentor, Colors\n\njulia> A = rand(10,10)\n10×10 Array{Float64,2}:\n[...]\n\njulia> augment(A, Reshape(10,10,1)) # add trailing singleton dimension\n10×10×1 Array{Float64,3}:\n[...]\n\n\n\n"
},

{
    "location": "operations/reshape/#Reshape-1",
    "page": "Reshape: Reinterpret shape",
    "title": "Reshape: Reinterpret shape",
    "category": "section",
    "text": "Reshape"
},

{
    "location": "operations/noop/#",
    "page": "NoOp: Identity function",
    "title": "NoOp: Identity function",
    "category": "page",
    "text": ""
},

{
    "location": "operations/noop/#Augmentor.NoOp",
    "page": "NoOp: Identity function",
    "title": "Augmentor.NoOp",
    "category": "Type",
    "text": "NoOp <: Augmentor.AffineOperation\n\nIdentity transformation that does not do anything with the given image but instead passes it along unchanged (without copying).\n\nUsually used in combination with Either to denote a \"branch\" that does not perform any computation.\n\n\n\n"
},

{
    "location": "operations/noop/#NoOp-1",
    "page": "NoOp: Identity function",
    "title": "NoOp: Identity function",
    "category": "section",
    "text": "NoOp"
},

{
    "location": "operations/cacheimage/#",
    "page": "CacheImage: Buffer current state",
    "title": "CacheImage: Buffer current state",
    "category": "page",
    "text": ""
},

{
    "location": "operations/cacheimage/#Augmentor.CacheImage",
    "page": "CacheImage: Buffer current state",
    "title": "Augmentor.CacheImage",
    "category": "Type",
    "text": "CacheImage <: Augmentor.ImageOperation\n\nDescription\n\nWrite the current state of the image into the working memory. Optionally a user has the option to specify a preallocated buffer to write the image into. Note that if a buffer is provided, then it has to be of the correct size and eltype.\n\nEven without a preallocated buffer it can be beneficial in some situations to cache the image. An example for such a scenario is when chaining a number of affine transformations after an elastic distortion, because performing that lazily requires nested interpolation.\n\nUsage\n\nCacheImage()\n\nCacheImage(buffer)\n\nArguments\n\nbuffer : Optional. A preallocated AbstractArray of the   appropriate size and eltype.\n\nSee also\n\naugment\n\nExamples\n\nusing Augmentor\n\n# make pipeline that forces caching after elastic distortion\npl = ElasticDistortion(3,3) |> CacheImage() |> Rotate(-10:10) |> ShearX(-5:5)\n\n# cache output of elastic distortion into the allocated\n# 20x20 Matrix{Float64}. Note that for this case this assumes that\n# the input image is also a 20x20 Matrix{Float64}\npl = ElasticDistortion(3,3) |> CacheImage(zeros(20,20)) |> Rotate(-10:10)\n\n# convenience syntax with the same effect as above.\npl = ElasticDistortion(3,3) |> zeros(20,20) |> Rotate(-10:10)\n\n\n\n"
},

{
    "location": "operations/cacheimage/#CacheImage-1",
    "page": "CacheImage: Buffer current state",
    "title": "CacheImage: Buffer current state",
    "category": "section",
    "text": "CacheImage"
},

{
    "location": "operations/either/#",
    "page": "Either: Stochastic branches",
    "title": "Either: Stochastic branches",
    "category": "page",
    "text": ""
},

{
    "location": "operations/either/#Augmentor.Either",
    "page": "Either: Stochastic branches",
    "title": "Augmentor.Either",
    "category": "Type",
    "text": "Either <: Augmentor.ImageOperation\n\nDescription\n\nAllows for choosing between different Augmentor.Operations at random when applied. This is particularly useful if one for example wants to first either rotate the image 90 degree clockwise or anticlockwise (but never both) and then apply some other operation(s) afterwards.\n\nWhen compiling a pipeline, Either will analyze the provided operations in order to identify the most preferred way to apply the individual operation when sampled, that is supported by all given operations. This way the output of applying Either will be inferable and the whole pipeline will remain type-stable, even though randomness is involved.\n\nBy default each specified image operation has the same probability of occurrence. This default behaviour can be overwritten by specifying the chance manually.\n\nUsage\n\nEither(operations, [chances])\n\nEither(operations...; [chances])\n\nEither(pairs...)\n\n*(operations...)\n\n*(pairs...)\n\nArguments\n\noperations : NTuple or Vararg of Augmentor.ImageOperation   that denote the possible choices to sample from when applied.\nchances : Optional. Denotes the relative chances for an   operation to be sampled. Has to contain the same number of   elements as operations. Either an NTuple of numbers if   specified as positional argument, or alternatively a   AbstractVector of numbers if specified as a keyword   argument. If omitted every operation will have equal   probability of occurring.\npairs : Vararg of Pair{<:Real,<:Augmentor.ImageOperation}.   A compact way to specify an operation and its chance of   occurring together.\n\nSee also\n\nNoOp, augment\n\nExamples\n\nusing Augmentor\nimg = testpattern()\n\n# all three operations have equal chance of occuring\naugment(img, Either(FlipX(), FlipY(), NoOp()))\naugment(img, FlipX() * FlipY() * NoOp())\n\n# NoOp is twice as likely as either FlipX or FlipY\naugment(img, Either(1=>FlipX(), 1=>FlipY(), 2=>NoOp()))\naugment(img, Either(FlipX(), FlipY(), NoOp(), chances=[1,1,2]))\naugment(img, Either((FlipX(), FlipY(), NoOp()), (1,1,2)))\naugment(img, (1=>FlipX()) * (1=>FlipY()) * (2=>NoOp()))\n\n\n\n"
},

{
    "location": "operations/either/#Either-1",
    "page": "Either: Stochastic branches",
    "title": "Either: Stochastic branches",
    "category": "section",
    "text": "Either"
},

{
    "location": "generated/mnist_elastic/#",
    "page": "MNIST: Elastic Distortions",
    "title": "MNIST: Elastic Distortions",
    "category": "page",
    "text": ""
},

{
    "location": "generated/mnist_elastic/#elastic-1",
    "page": "MNIST: Elastic Distortions",
    "title": "MNIST: Elastic Distortions",
    "category": "section",
    "text": "In this example we are going to use Augmentor.jl on the famous MNIST database of handwritten digits [MNIST1998] to reproduce the elastic distortions discussed in [SIMARD2003].Note that the way Augmentor implements deformations is a little different than how it is described by the authors in the paper. This is for a couple of reasons, most notably that we want the parameters for our deformations to be intepended of the size of image it is applied on. As a consequence the parameter numbers specified in the paper are not 1-to-1 transferable to Augmentor.Download as Juypter notebook"
},

{
    "location": "generated/mnist_elastic/#Loading-the-MNIST-Trainingset-1",
    "page": "MNIST: Elastic Distortions",
    "title": "Loading the MNIST Trainingset",
    "category": "section",
    "text": "In order to access and visualize the MNIST images we employ the help of two additional Julia packages.Images.jl will provide us with the tool for working with image data in Julia.\nMLDatasets.jl has an MNIST submodule that offers a convenience interface to read the MNIST database.The function MNIST.traintensor returns the MNIST training images corresponding to the given indices as a multi-dimensional array. These images are stored in the native horizontal-major memory layout as a single floating point array, where all values are scaled to be between 0.0 and 1.0.using Images, MLDatasets\ntrain_tensor = MNIST.traintensor()\n@show summary(train_tensor);\nnothing # hideThis horizontal-major format is the standard way of utilizing this dataset for training machine learning models. In this tutorial, however, we are more interested in working with the MNIST images as actual Julia images in vertical-major layout, and as black digits on white background.We can convert the \"tensor\" to a Colorant array using the provided function MNIST.convert2image. This way, Julia knows we are dealing with image data and can tell programming environments such as Juypter how to visualize it. If you are working in the terminal you may want to also use the package ImageInTerminal.jltrain_images = MNIST.convert2image(train_tensor)\nimg_1 = train_images[:,:,1] # show first image\nsave(\"mnist_1.png\",repeat(img_1,inner=(4,4))) # hide\nnothing # hide(Image: first image)"
},

{
    "location": "generated/mnist_elastic/#Visualizing-the-Augmentation-Pipeline-1",
    "page": "MNIST: Elastic Distortions",
    "title": "Visualizing the Augmentation Pipeline",
    "category": "section",
    "text": "Before we apply a smoothed displacement field to our dataset and train a network, we should invest some time to come up with a decent set of hyper parameters for the operation. A useful tool for tasks like this is the package Interact.jl.Note that while the code below only focuses on configuring the parameters of a single operation, it could also be adapted to tweak a whole pipelined. Take a look at the corresponding section in High-level Interface for more information on how to define and use a pipeline.# These two package will provide us with the capabilities\n# to perform interactive visualisations in a jupyter notebook\nusing Augmentor, Interact, Reactive\n\n# The manipulate macro will turn the parameters of the\n# loop into interactive widgets.\n@manipulate for\n        unpaused = true,\n        ticks = fpswhen(signal(unpaused), 5.),\n        image_index = 1:100,\n        grid_size = 3:20,\n        scale = .1:.1:.5,\n        sigma = 1:5,\n        iterations = 1:6,\n        free_border = true\n    op = ElasticDistortion(grid_size, grid_size, # equal width & height\n                           sigma = sigma,\n                           scale = scale,\n                           iter = iterations,\n                           border = free_border)\n    augment(train_images[:, :, image_index], op)\nend\nnothing # hideExecuting the code above in a Juypter notebook will result in the following interactive visualisation. You can now use the sliders to investigate the effects that different parameters have on the MNIST training set.tip: Tip\nYou should always use your training set to do this kind of visualisation (not the test test!). Otherwise you are likely to achieve overly optimistic (i.e. biased) results during training.(Image: interact)Congratulations! With just a few simple lines of code, you created a simple interactive tool to visualize your image augmentation pipeline. Once you found a set of parameters that you think are appropriate for your dataset you can go ahead and train your model."
},

{
    "location": "generated/mnist_elastic/#References-1",
    "page": "MNIST: Elastic Distortions",
    "title": "References",
    "category": "section",
    "text": "[MNIST1998]: LeCun, Yan, Corinna Cortes, Christopher J.C. Burges. \"The MNIST database of handwritten digits\" Website. 1998.[SIMARD2003]: Simard, Patrice Y., David Steinkraus, and John C. Platt. \"Best practices for convolutional neural networks applied to visual document analysis.\" ICDAR. Vol. 3. 2003."
},

{
    "location": "indices/#",
    "page": "Indices",
    "title": "Indices",
    "category": "page",
    "text": ""
},

{
    "location": "indices/#Functions-1",
    "page": "Indices",
    "title": "Functions",
    "category": "section",
    "text": "Order   = [:function]"
},

{
    "location": "indices/#Types-1",
    "page": "Indices",
    "title": "Types",
    "category": "section",
    "text": "Order   = [:type]"
},

{
    "location": "LICENSE/#",
    "page": "LICENSE",
    "title": "LICENSE",
    "category": "page",
    "text": ""
},

{
    "location": "LICENSE/#LICENSE-1",
    "page": "LICENSE",
    "title": "LICENSE",
    "category": "section",
    "text": "Markdown.parse_file(joinpath(@__DIR__, \"../LICENSE.md\"))"
},

]}
