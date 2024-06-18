include("board.jl")

function greedyPolicy(maze::MazeState)
    candidates = legalActions(maze)

    bestScore = -Inf
    bestAction = nothing
    for action in candidates
        npos = applyDelta(maze.playerPos, action)
        if maze.board[npos.y, npos.x] > bestScore
            bestScore = maze.board[npos.y, npos.x]
            bestAction = action
        end
    end

    bestAction
end

println("Greedy policy test")
println("Total Score: (mean, std) = ", evaluateMany(1234, 100, greedyPolicy))
