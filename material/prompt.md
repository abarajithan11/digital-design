    w0, b0 = np.clip(quant(p["fc0.weight"], FBITS), -128, 127), quant(p["fc0.bias"], 2 * FBITS)
    w1, b1 = np.clip(quant(p["fc1.weight"], FBITS), -128, 127), quant(p["fc1.bias"], 2 * FBITS)
    xq = np.clip(quant(x_img.flatten(), FBITS), 0, 127)

why do this? doesnt brevitas' .int() do this?
Why are u replicating forward pass in numpy? 
why not just take brevitas' output?

dont use longint/int in tb. set a localparam named W_ACC for accumulator width, do the clamping, banker's rounding...etc in SV to match brevitas.

make weights, input, bias bits W_X, W_Y, W_B in python & SV. dont use int, in svh as well. And when printing arrays into that, make it one element per line, and put four \n between the end of one array and start of other