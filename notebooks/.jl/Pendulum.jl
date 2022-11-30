# using Markdown
using ReinforcementLearning #Environments and API
using Lux #Neural networks with explicit parameterization (Flux would also work) To install: ] add https://github.com/avik-pal/Lux.jl
using Random #RNG generation
using Flatten #Flatten structs of parameters in vector of arrays - simplifies equations
using Plots #Basic plots
using NNlib #More neural network functionality



struct PGAgent{A, B, C, D, E, F}<:AbstractPolicy #A B C D E F sets static types so they are known at compile time - performance boost
    f::A #::A same as above
    θ::B
    st::C
    params::D
    trace::E
    baseline::F #Baseline
end

mutable struct EWMA{A, B} #Allows averaging without storing all rewards. See https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
    mean::A
    α::B #Controlls decay rate of average
end
function update!(s::EWMA, x)
    s.mean = (1.0 - s.α) *  s.mean + s.α * x
end
function (s::EWMA)()
    return s.mean
end

mutable struct PGParams{A, B, C} #Learning parameters
    γ::A #Discount rate
    α::B #Step size
    σ::C #Std
end

function (me::PGAgent)(env)
    #Action and learning loop (merged)
    #Get list of parameters
    flatθ = Flatten.flatten(me.θ, Array)
    #Get reward
    r = reward(env)

    #Update parameters with reward and trace
    for i = 1:length(flatθ)
        flatθ[i] .= flatθ[i] .+ me.params.α * (r - me.baseline()) .*  me.trace[i] ./ me.params.σ^2 #The flattened vector is a list of pointers to the arrays in θ. Changing the contect of flatθ with .= also changes θ.
    end
    #Update baseline
    update!(me.baseline, r)
    #Generate parameters for this iteration
    noisyθ = deepcopy(me.θ)
    flatnosiyθ = Flatten.flatten(noisyθ, Array)
    #Generate noise
    n = [me.params.σ * randn(size(x)) for x in flatnosiyθ]
    #Add noise to parameters parameters
    for i in 1:length(flatnosiyθ)
        flatnosiyθ[i] .=  flatnosiyθ[i] .+ n[i]
    end
    #Update trace with noise
    for i in 1:length(me.trace)
        me.trace[i] .= me.params.γ * me.trace[i] + (1-me.params.γ) * n[i]
    end
    return 2.0*me.f(state(env), noisyθ, me.st)[1][1] #Return action from noisy policy
end


#Init environment
env = PendulumEnv(continuous = true)
action_space(env)

#Create ANN and save parameter struct and state (of the ANN in case of RNN, LSTM etc - otherwise empty struct) struct
rng = Random.default_rng()
nhidden = 4
model = Chain(Dense(length(state(env)) => nhidden,tanh), Dense(nhidden => 1,tanh)) #Creates an ANN
ps, st = Lux.setup(rng, model)

#Init trace vector
tr = deepcopy(ps)
fltr = Flatten.flatten(tr, Array) #Flatten so that we can iterate easily over all parameters in a vector of arrays instead of through the struct
[x .= 0.0 .* x for x in fltr] #Set initial traces to 0

# params = PGParams(0.95, 0.00001, 0.1) #Set learning parameters
## resulted TotalRewardPerEpisode = ([-1459.8485250348526, -1520.4889067237827, -1501.5157316182567, -1511.603565641842, -1512.9922405983064, -1414.6018622270428, -1501.6212689238146, -1476.6428638954897, -1472.8941659970733, -1508.5743510471932  …  -885.1615314893519, -9.529818544713574, -646.5859876283188, -535.413153608545, -396.45109469156984, -404.72325191669756, -9.792634414999181, -754.3183415063024, -139.81000559188286, -1206.6985960488344], 0.0, true)

# IF learning parameters were different
params = PGParams(0.8, 0.01, 0.1) #Set learning parameters
## resulted TotalRewardPerEpisode([-1277.1390033932169, -1427.329064266151, -1652.4770190913018, -1401.7377382024233, -1503.3131388222503, -1542.7829319293237, -1443.2363858624444, -1514.8500784543046, -1658.1327060443086, -1601.3129666646573  …  -1196.7516922751695, -1517.2550441814667, -979.6371078710482, -1548.4847347267703, -1599.3996243158922, -1568.9194036490833, -1503.4107901317818, -1527.6080747503395, -1511.9098108260805, -1551.0292583541518], 0.0, true)


agent = PGAgent(model,ps,st,params,fltr, EWMA(-0.0, 0.001)) #Create agent

#Test model and full agent
model([1; 0;1], ps, st)
agent(env)

agent.θ
#Training loop
run(
           agent,
           env,
        #    StopAfterEpisode(100000),
           StopAfterEpisode(1000),# much less reward than higher episode numbers
           TotalRewardPerEpisode()
       )

agent.θ
#This should plot something visually - did not work for me
demo = Experiment(agent,
    env,
    StopWhenDone(),
    RolloutHook(plot, closeall),
   "PG <-> Demo")
run(demo)