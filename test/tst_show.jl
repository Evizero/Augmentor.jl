function str_show(obj)
    io = IOBuffer()
    Base.show(io, obj)
    readstring(seek(io, 0))
end

function str_showcompact(obj)
    io = IOBuffer()
    Base.showcompact(io, obj)
    readstring(seek(io, 0))
end

SPACE = VERSION < v"0.6.0-dev.2505" ? "" : " " # julia PR #20288

@test str_show(NoOp()) == "Augmentor.NoOp()"
@test str_showcompact(NoOp()) == "No operation"

@test str_show(Rotate90())  == "Augmentor.Rotate90()"
@test str_showcompact(Rotate90())  == "Rotate 90 degree"

@test str_show(Rotate180()) == "Augmentor.Rotate180()"
@test str_showcompact(Rotate180())  == "Rotate 180 degree"

@test str_show(Rotate270()) == "Augmentor.Rotate270()"
@test str_showcompact(Rotate270())  == "Rotate 270 degree"

@test str_show(Crop(1:10)) == "Augmentor.Crop{1}((1:10,))"
@test str_show(Crop(1:10,5:15)) == "Augmentor.Crop{2}((1:10,$(SPACE)5:15))"
@test str_showcompact(Crop(1:10,5:15)) == "Crop region (1:10,$(SPACE)5:15)"

@test str_show(Either((Rotate90(),Rotate270(),NoOp()), (0.2,0.3,0.5))) == """
Augmentor.Either (1 out of 3 operation(s)):
  - 20.0% chance to: Rotate 90 degree
  - 30.0% chance to: Rotate 270 degree
  - 50.0% chance to: No operation"""
@test str_showcompact(Either((Rotate90(),Rotate270(),NoOp()), (0.2,0.3,0.5))) == "Either: (20%) Rotate 90 degree. (30%) Rotate 270 degree. (50%) No operation."

@test str_show(()) == "()"
@test str_show((Rotate90(),Rotate270(),NoOp())) == """
3-step Augmentor.Pipeline:
 1.) Rotate 90 degree
 2.) Rotate 270 degree
 3.) No operation"""
@test str_showcompact((Rotate90(),Rotate270(),NoOp())) == "(Rotate 90 degree, Rotate 270 degree, No operation)"
