#!/usr/bin/env python3
"""线性注意力 vs 传统注意力 对比演示 (PyTorch 正确版本)"""
import torch
import torch.nn.functional as F

def phi(x):
    """核函数：elu(x) + 1"""
    return F.elu(x) + 1

def linear_attention_correct(Q, K, V):
    """
    正确的线性注意力实现（带归一化）
    维护两个状态：
      - S = Σ φ(k) ⊗ v  (d×d 矩阵，分子)
      - z = Σ φ(q) · φ(k) (标量，分母)
    """
    d = Q.shape[1]
    S = torch.zeros(d, d)
    z = torch.zeros(1)
    output = []
    
    for t in range(len(Q)):
        # 核变换
        k_phi = phi(K[t])
        q_phi = phi(Q[t])
        v = V[t]
        
        # 更新状态（分子）
        S += torch.outer(k_phi, v)
        
        # 更新归一化因子（分母）
        z += torch.dot(q_phi, k_phi)
        
        # 计算输出
        out = q_phi @ S
        out = out / (z + 1e-6)
        
        output.append(out)
    
    return torch.stack(output)

# 微型输入 (seq_len=6, d=3)
Q = K = V = torch.tensor([
    [1.0, 0.5, 0.2],   # "我"
    [0.8, 1.0, 0.3],   # "爱"
    [0.6, 0.7, 1.0],   # "机"
    [0.9, 0.4, 0.8],   # "械"
    [0.5, 0.9, 0.6],   # "狐"
    [0.7, 0.6, 0.9],   # "狸"
])

print("=" * 60)
print("传统注意力 (Softmax) vs 线性注意力 (Kernelized)")
print("=" * 60)

# 传统注意力
attn_matrix = F.softmax(Q @ K.T, dim=-1)
output_standard = attn_matrix @ V

# 线性注意力（正确版本）
output_linear = linear_attention_correct(Q, K, V)

# 打印对比
tokens = ["我", "爱", "机", "械", "狐", "狸"]
for i, name in enumerate(tokens):
    std = output_standard[i].tolist()
    lin = output_linear[i].tolist()
    err = [(abs(s-l)/abs(s))*100 if abs(s) > 1e-6 else 0 for s,l in zip(std, lin)]
    avg_err = sum(err)/3
    
    print(f"\nToken [{i}] = '{name}':")
    print(f"  传统：[{std[0]:.4f}, {std[1]:.4f}, {std[2]:.4f}]")
    print(f"  线性：[{lin[0]:.4f}, {lin[1]:.4f}, {lin[2]:.4f}]")
    print(f"  误差：[{err[0]:.2f}%, {err[1]:.2f}%, {err[2]:.2f}%]  平均：{avg_err:.2f}%")

print("\n" + "=" * 60)
total_err = (output_standard - output_linear).abs().mean().item() * 100
print(f"整体平均相对误差：{total_err:.2f}%")
print("=" * 60)

# 注意力权重可视化
print("\n📊 传统注意力权重矩阵（行=查询 token，列=键 token）:")
print("     " + "  ".join(f"{t:>6}" for t in tokens))
for i, name in enumerate(tokens):
    row = attn_matrix[i].tolist()
    print(f"{name:>4} " + " ".join(f"{w:6.2f}" for w in row))

print("\n🦊 观察：传统注意力能精确分配权重，线性注意力用累积状态近似")
print(f"   误差 {total_err:.1f}% 是核函数近似的代价，换取 O(n)→O(1) 内存")
