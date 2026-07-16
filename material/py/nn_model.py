#!/usr/bin/env python3
"""Train a tiny quantized MNIST MLP with Brevitas and export it as an SV header."""
import math
import os
from pathlib import Path

import numpy as np
import torch
from torch import nn
from torch.nn import functional as F
from torch.utils.data import DataLoader

# The course image only uses torchvision datasets/transforms, but its CPU-only
# torchvision build expects these optional detection operators to be declared.
_torchvision_ops = torch.library.Library("torchvision", "DEF")
_torchvision_ops.define("nms(Tensor boxes, Tensor scores, float iou_threshold) -> Tensor")
_torchvision_ops.define("qnms(Tensor boxes, Tensor scores, float iou_threshold) -> Tensor")
from torchvision import datasets, transforms
from brevitas.nn import QuantIdentity, QuantLinear, QuantReLU
from brevitas.quant import (Int8ActPerTensorFixedPoint,
                            Int8WeightPerTensorFixedPoint, Int16Bias)

# The weights are shared material, so they are exported next to the rest of it
# rather than into an assignment: students fetch this package from this repo (see
# the A4 README). Anchored to this file, not the cwd, because the assignment
# runs it from assignments/a4 (where CKPT/data/ resolve).
PKG_SV = str(Path(__file__).resolve().parent.parent / "rtl" / "reference" / "nn_weights.sv")

CKPT = "data/nn_model_9x9_h48.pt"
TRAIN = not os.path.exists(CKPT)      # Train once, then reuse the checkpoint for deterministic exports
IMAGE_SIZE, DOWNSAMPLE = 28, 3
DOWNSAMPLED_SIZE = (IMAGE_SIZE - DOWNSAMPLE) // DOWNSAMPLE + 1
HID, IN, OUT, EPOCHS = 48, DOWNSAMPLED_SIZE**2, 10, 40
W_X, W_K, W_B, W_ACC = 4, 4, 8, 16    # activation, weight, bias, accumulator bit-widths
DENSITY = 0.20

def input_transform():
    return transforms.ToTensor()

def camera_like(x):
    """
    Augument the MNIST dataset to represent the camera domain.
    """
    n = x.shape[0]
    jitter = lambda scale: (torch.rand(n) * 2 - 1) * scale
    angle, zoom = jitter(15.0) * math.pi / 180, 1.0 + jitter(0.18)
    cos, sin = torch.cos(angle) / zoom, torch.sin(angle) / zoom
    theta = torch.zeros(n, 2, 3)
    theta[:, 0, 0], theta[:, 0, 1], theta[:, 0, 2] = cos, -sin, jitter(0.14)
    theta[:, 1, 0], theta[:, 1, 1], theta[:, 1, 2] = sin, cos, jitter(0.14)
    grid = F.affine_grid(theta, x.shape, align_corners=False)
    x = F.grid_sample(x, grid, align_corners=False)
    local_mean = F.avg_pool2d(F.pad(x, (7, 7, 7, 7), mode="reflect"), 15, stride=1)
    return F.avg_pool2d((x > local_mean + 0.03).float(), DOWNSAMPLE)

def prep(x, cam):
    """One 28x28 batch -> the 9x9 the FPGA sees, from either domain."""
    return camera_like(x) if cam else F.avg_pool2d(x, DOWNSAMPLE)

def prune(model, density):
    """
    Zero weights remove their entire adder tree branch in yosys
    """
    if density >= 1.0:
        return
    with torch.no_grad():
        for linear in (model.fc0, model.fc1):
            w = linear.weight
            keep = max(1, int(round(density * w.numel())))
            threshold = torch.topk(w.abs().flatten(), keep).values.min()
            w.mul_((w.abs() >= threshold).float())

class Net(nn.Module):
    def __init__(self):
        super().__init__()
        self.inp = QuantIdentity(
                        bit_width=W_X,
                        act_quant=Int8ActPerTensorFixedPoint,
                        return_quant_tensor=True)
        self.fc0 = QuantLinear(
                        IN, HID,
                        bias=True,
                        weight_bit_width=W_K,
                        return_quant_tensor=True,
                        weight_quant=Int8WeightPerTensorFixedPoint,
                        bias_quant=Int16Bias)
        self.act = QuantReLU(
                        bit_width=W_X,
                        act_quant=Int8ActPerTensorFixedPoint,
                        return_quant_tensor=True)
        self.fc1 = QuantLinear(
                        HID, OUT,
                        bias=True,
                        weight_bit_width=W_K,
                        return_quant_tensor=True,
                        weight_quant=Int8WeightPerTensorFixedPoint,
                        bias_quant=Int16Bias)
        self.out = QuantIdentity(
                        bit_width=W_X,
                        act_quant=Int8ActPerTensorFixedPoint,
                        return_quant_tensor=True)

    def forward(self, x):
        return self.out(self.fc1(self.act(self.fc0(self.inp(x.flatten(1))))))

def run_epoch(model, data, opt=None, cam=None, density=1.0):
    """cam=True/False forces one domain; cam=None alternates them while training."""
    loss_sum = correct = total = 0
    for batch, (x, y) in enumerate(data):
        logits = model(prep(x, batch % 2 == 0 if cam is None else cam)).value
        loss = nn.functional.cross_entropy(logits, y)
        if opt:
            opt.zero_grad(); loss.backward(); opt.step()
            prune(model, density)   # re-prune every step so survivors train sparse
        loss_sum += loss.item() * len(y)
        correct += (logits.argmax(1) == y).sum().item()
        total += len(y)
    return loss_sum / total, correct / total

def main():

    '''
    Load Data
    '''
    torch.manual_seed(0)
    tf = input_transform()
    te = DataLoader(datasets.MNIST("data", train=False, download=True, transform=tf), batch_size=128)

    '''
    Train Model (or reuse the saved checkpoint)
    '''
    model = Net()
    if TRAIN:
        tr = DataLoader(datasets.MNIST("data", train=True, download=True, transform=tf), batch_size=128, shuffle=True)
        opt = torch.optim.Adam(model.parameters(), lr=1e-3)
        sched = torch.optim.lr_scheduler.CosineAnnealingLR(opt, EPOCHS)
        for e in range(EPOCHS):
            # Ease the density down over the first 60% of training, then fine-tune
            # at the target sparsity so the survivors can recover.
            ramp = min(1.0, e / max(1, int(0.6 * EPOCHS)))
            model.train()
            tr_loss, _ = run_epoch(model, tr, opt, density=1.0 - (1.0 - DENSITY) * ramp)
            model.eval()
            with torch.no_grad():
                te_loss, te_acc = run_epoch(model, te, cam=False)
                _, cam_acc = run_epoch(model, te, cam=True)
            sched.step()
            print(f"epoch {e}: train_loss={tr_loss:.4f} test_loss={te_loss:.4f} "
                  f"test_acc={te_acc:.4f} camera_acc={cam_acc:.4f}")
        torch.save(model.state_dict(), CKPT)
    else:
        model.load_state_dict(torch.load(CKPT))
    model.eval()

    '''
    Export Weights and Activations to SV Header
    '''
    log2 = lambda qt: round(math.log2(float(qt.scale)))
    to_int = lambda qt: qt.int().numpy().astype(np.int64)
    with torch.no_grad():
        sample = prep(next(iter(te))[0][:1], cam=False)   # one 9x9 image for the tb vectors
        acts, denses = [model.inp(sample.flatten()[None])], []
        for lin, act in [(model.fc0, model.act), (model.fc1, model.out)]:
            denses.append(lin(acts[-1]))          # dense = matmul + bias (accumulator)
            acts.append(act(denses[-1]))          # activation = requantize + relu
    layers = [model.fc0, model.fc1]

    shifts = []
    arrays = [("quantized_input", "W_X", W_X, to_int(acts[0]).flatten())]
    for i, lin in enumerate(layers):
        w = lin.quant_weight()
        b = lin.bias_quant(lin.bias, acts[i], w)
        shifts.append(log2(acts[i + 1]) - log2(acts[i]) - log2(w))          # requant right-shift
        out_name = "quantized_output" if i == len(layers) - 1 else f"act_{i}"
        arrays += [(f"weights_{i}", "W_K", W_K, to_int(w)), (f"bias_{i}", "W_B", W_B, to_int(b).flatten()),
                   (f"dense_{i}", "W_ACC", W_ACC, to_int(denses[i]).flatten()),
                   (out_name, "W_X", W_X, to_int(acts[i + 1]).flatten())]

    with open(PKG_SV, "w") as f:
        f.write("`ifndef NN_WEIGHTS_SV\n`define NN_WEIGHTS_SV\n")
        f.write("/* verilator lint_off ASCRANGE */\npackage nn_weights_pkg;\n")
        params = [("N_IN", IN), ("N_HIDDEN", HID), ("N_OUT", OUT),
                  ("W_X", W_X), ("W_K", W_K), ("W_B", W_B), ("W_ACC", W_ACC),
                  ("INPUT_SCALE_LOG2", -log2(acts[0]))]
        params += [(f"SHIFT_{i}", s) for i, s in enumerate(shifts)]
        for pname, pval in params:
            f.write(f"  localparam int {pname} = {pval};\n")
        for name, tname, bits, a in arrays:
            cell = lambda v: f"-{bits}'d{-int(v)}" if v < 0 else f"{bits}'d{int(v)}"
            row = lambda r: "{" + ",\n".join(cell(v) for v in r[::-1]) + "}"
            body = row(a) if a.ndim == 1 else "{" + ",\n".join(row(r) for r in a[::-1]) + "}"
            # Package constants and module parameters are flat packed vectors
            # for stock Yosys. Assigning them to packed RTL views preserves the
            # exact bit ordering without an explicit unpacking loop.
            shape = f"[{a.size * bits - 1}:0]"
            f.write(f"  localparam logic signed {shape} {name} = {body};\n")
        f.write("endpackage\n/* verilator lint_on ASCRANGE */\n`endif\n")
    print(f"Wrote {PKG_SV}")

if __name__ == "__main__":
    main()
