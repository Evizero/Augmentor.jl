# To run it locally, BenchmarkCI should be added to root project
using BenchmarkCI
on_CI = haskey(ENV, "GITHUB_ACTIONS")

BenchmarkCI.judge()
on_CI ? BenchmarkCI.postjudge() : BenchmarkCI.displayjudgement()
