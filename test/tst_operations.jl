# test not exported
@test_throws UndefVarError Operation
@test_throws UndefVarError AffineOperation

@test Augmentor.AffineOperation <: Augmentor.Operation

