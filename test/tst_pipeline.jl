@test str_show(()) == "()"
@test str_show((Rotate90(),Rotate270(),NoOp())) == """
3-step Augmentor.Pipeline:
 1.) Rotate 90 degree
 2.) Rotate 270 degree
 3.) No operation"""
@test str_showcompact((Rotate90(),Rotate270(),NoOp())) == "(Rotate 90 degree, Rotate 270 degree, No operation)"
