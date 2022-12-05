import gym


def parse_input(x:str):
    if x == 's':
        return 0
    elif x == 'd':
        return 1
    elif x == 'w':
        return 2
    elif x == 'a':
        return 3
    else: 
        return -1
        
env = gym.make("LunarLander-v2", 
    render_mode="human",
    continuous = False,
    gravity = -11.0,
    enable_wind = False,
    wind_power = 0.0,
    turbulence_power = 1.5)
observation, info = env.reset(seed=42)
while True:
    try:
        t = input("Enter input [wasd]:")
        if parse_input(t)== -1:
            continue
        
        action = parse_input(t)  # User-defined policy function
        observation, reward, terminated, truncated, info = env.step(action)

        if terminated or truncated:
            observation, info = env.reset()
    except KeyboardInterrupt:
            env.close()
