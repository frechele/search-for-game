using Random

include("board.jl")

rng = Random.MersenneTwister(5678)

function randomPolicy(maze::MazeState)
    candidates = legalActions(maze)
    rand(rng, candidates)
end

println("Random policy test")
println("Total Score: (mean, std) = ", evaluateMany(1234, 100, randomPolicy))
