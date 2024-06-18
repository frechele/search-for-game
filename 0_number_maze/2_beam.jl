using DataStructures

include("board.jl")

const BEAM_WIDTH::Int = 2
const BEAM_DEPTH::Int = 20

function beamSearchPolicy(maze::MazeState)
    pq = PriorityQueue(Base.Order.Reverse)
    enqueue!(pq, (deepcopy(maze), nothing), maze.score)

    bestStateAction = nothing
    for t ∈ 1:BEAM_DEPTH
        npq = PriorityQueue(Base.Order.Reverse)
        for i ∈ 1:BEAM_WIDTH
            if isempty(pq)
                break
            end

            state, action = dequeue!(pq)
            for a ∈ legalActions(state)
                nstate = deepcopy(state)
                step!(nstate, a)

                if t == 1
                    enqueue!(npq, (nstate, a), nstate.score)
                else
                    enqueue!(npq, (nstate, action), nstate.score)
                end
            end
        end

        pq = npq
        bestStateAction = peek(pq)[1]

        if isGameOver(bestStateAction[1])
            break
        end
    end

    bestStateAction[2]
end

println("Beam Search policy test")
println("Total Score: (mean, std) = ", evaluateMany(1234, 100, beamSearchPolicy))
