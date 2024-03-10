import numpy as np
import matplotlib.pyplot as plt
import time as t
"""
计算反应谱
（Nigam-Jennings精确解）
"""


def Spectrum(ag, dt, T, zeta=0.05):

    if T[0] == 0:
        T = T[1:]
        mark = 1
    else:
        mark = 0
    N = len(T)

    w = 2 * np.pi / T
    wd = w * np.sqrt(1 - zeta**2)
    n = len(ag)

    u = np.zeros((N, n))  # N x n
    v = np.zeros((N, n))  # N x n

    B1 = np.exp(-zeta * w * dt) * np.cos(wd * dt)  # N
    B2 = np.exp(-zeta * w * dt) * np.sin(wd * dt)  # N

    w_2 = 1.0 / w ** 2  # N
    w_3 = 1.0 / w ** 3  # N

    for i in range(n - 1):
        u_i = u[:, i]  # N
        v_i = v[:, i]  # N
        p_i = -ag[i]
        alpha_i = (-ag[i + 1] + ag[i]) / dt

        A0 = p_i * w_2 - 2.0 * zeta * alpha_i * w_3  # N
        A1 = alpha_i * w_2  # N
        A2 = u_i - A0  # N
        A3 = (v_i + zeta * w * A2 - A1) / wd  # N

        u[:, i+1] = A0 + A1 * dt + A2 * B1 + A3 * B2  # N
        v[:, i+1] = A1 + (wd * A3 - zeta * w * A2) * B1 - (wd * A2 + zeta * w * A3) * B2  # N  
    w_tile = np.tile(w, (n, 1)).T  # N x n
    a = -2 * zeta * w_tile * v - w_tile * w_tile * u  # N x n
    RSA = np.amax(abs(a), axis=1)
    RSV = np.amax(abs(v), axis=1)
    RSD = np.amax(abs(u), axis=1)
    if mark == 1:
        RSA = np.insert(RSA, 0, np.max(abs(ag)))
        RSV = np.insert(RSV, 0, 0)
        RSD = np.insert(RSD, 0, 0)
    return RSA, RSV, RSD

if __name__ == "__main__":

    ag = np.loadtxt(r'F:\MRF\GMs\th1.th')
    dt = 0.02
    T1 = 0
    T2 = 6
    dT = 0.01
    save = 0  # 1：保存结果，2：不保存

    T = np.arange(T1, T2, dT)
    RSA, RSV, RSD = Spectrum(ag, dt, T)
    plt.plot(T, RSA)
    plt.show()
    if save == 1:
        np.savetxt('T.out', T)
        np.savetxt('RSA.out', RSA)
