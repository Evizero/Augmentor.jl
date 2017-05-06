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
