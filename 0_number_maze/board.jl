using Random

struct Coord
    x::Int
    y::Int
end

function Coord()
    Coord(0, 0)
end

const MAZE_HEIGHT::Int = 30
const MAZE_WIDTH::Int = 30
const MAZE_EPISODE_LENGTH::Int = 100

mutable struct MazeState
    board::Array{Int, 2}
    turns::Int
    score::Int
    playerPos::Coord
end

function MazeState(seed::Int)
    rng = Random.MersenneTwister(seed)

    playerX = rand(rng, 1:MAZE_WIDTH)
    playerY = rand(rng, 1:MAZE_HEIGHT)
    playerPos = Coord(playerX, playerY)

    board = zeros(Int, MAZE_HEIGHT, MAZE_WIDTH)
    for i ∈ 1:MAZE_HEIGHT
        for j ∈ 1:MAZE_WIDTH
            if i == playerY && j == playerX
                continue
            end

            board[i, j] = rand(rng, 0:9)
        end
    end

    MazeState(
        board,
        0,
        0,
        playerPos
    ) 
end

function isGameOver(state::MazeState)
    state.turns >= MAZE_EPISODE_LENGTH
end

const DELTAS = [
    (1, 0),
    (-1, 0),
    (0, 1),
    (0, -1),
]

function applyDelta(coord::Coord, action::Int)
    delta = DELTAS[action]
    Coord(coord.x + delta[1], coord.y + delta[2])
end

function step!(state::MazeState, action::Int)
    npos = applyDelta(state.playerPos, action)
    point = state.board[npos.y, npos.x]
    state.board[npos.y, npos.x] = 0

    state.turns += 1
    state.score += point
    state.playerPos = npos
end

function legalActions(state::MazeState)
    actions = []
    for action ∈ 1:4
        npos = applyDelta(state.playerPos, action)

        if (npos.x >= 1 && npos.x <= MAZE_WIDTH) &&
           (npos.y >= 1 && npos.y <= MAZE_HEIGHT)
            push!(actions, action)
        end
    end

    actions
end

function showBoard(state::MazeState)
    println("Turns: ", state.turns)
    println("Score: ", state.score)
    for i ∈ 1:MAZE_HEIGHT
        for j ∈ 1:MAZE_WIDTH
            if state.playerPos.x == j && state.playerPos.y == i
                print("@")
            elseif state.board[i, j] == 0
                print(".")
            else
                print(state.board[i, j])
            end
            print(" ")
        end
        println()
    end
    println()
end

function evaluate(seed::Int, policy::Function; show::Bool=false)
    maze = MazeState(seed)

    while !isGameOver(maze)
        if show
            showBoard(maze)
        end

        action = policy(maze)
        step!(maze, action)
    end

    if show
        showBoard(maze)
    end

    maze.score
end

function evaluateMany(seed::Int, numTrials::Int, policy::Function)
    scores = []
    for i ∈ 1:numTrials
        push!(scores, evaluate(seed + i, policy))
    end

    mean = sum(scores) / numTrials
    std = sqrt(sum((scores .- mean) .^ 2) / numTrials)
    (mean, std)
end
