"""Create an RC concentrated plastic hinge from physical section inputs.

The yield moment uses the Panagiotakos--Fardis approximation.  The deformation
and deterioration relations use Haselton et al. (2016), including the
non-symmetric reinforcement correction.  Generated models use N, mm, and MPa.
"""

from __future__ import annotations

import math
from typing import Literal

import openseespy.opensees as ops


def _aci_beta_1(fc: float, unit_factor: float) -> float:
    """Return the ACI rectangular-block factor after converting ``fc`` to MPa."""
    fc_mpa = fc * unit_factor
    if fc_mpa <= 27.6:
        return 0.85
    if fc_mpa >= 55.16:
        return 0.65
    return 1.05 - 0.05 * fc_mpa / 6.9


def _asymmetric_rotation_factor(
    rho_compression: float,
    rho_tension: float,
    fy: float,
    fc: float,
) -> float:
    """Return the Fardis--Biskinis correction in Haselton et al. Eq. (7)."""
    normalized_compression = max(0.01, rho_compression * fy / fc)
    normalized_tension = max(0.01, rho_tension * fy / fc)
    return (normalized_compression / normalized_tension) ** 0.225


def _yield_moment(
    b: float,
    h: float,
    compression_cover: float,
    tension_cover: float,
    area_tension: float,
    area_compression: float,
    area_intermediate: float,
    axial_force: float,
    fc: float,
    ec: float,
    fy: float,
    es: float,
    unit_factor: float,
) -> float:
    """Return the Panagiotakos--Fardis yield-moment approximation."""
    d = h - tension_cover
    delta_1 = compression_cover / d
    rho_t = area_tension / (b * d)
    rho_c = area_compression / (b * d)
    rho_i = area_intermediate / (b * d)
    axial_ratio = axial_force / (b * d * fc)
    modular_ratio = es / ec
    yield_strain = fy / es
    ultimate_concrete_strain = 0.003
    beta_1 = _aci_beta_1(fc, unit_factor)
    compression_depth = (area_tension * fy - area_compression * fy + axial_force) / (
        0.85 * fc * beta_1 * b
    )
    balanced_depth = ultimate_concrete_strain * d / (ultimate_concrete_strain + yield_strain)
    if compression_depth < balanced_depth:
        value_a = rho_t + rho_c + rho_i + axial_force / b / d / fy
        value_b = rho_t + rho_c * delta_1 + 0.5 * rho_i * (1 + delta_1) + axial_force / b / d / fy
        neutral_axis = (
            math.sqrt(modular_ratio**2 * value_a**2 + 2 * modular_ratio * value_b)
            - modular_ratio * value_a
        )
        yield_curvature = fy / es / (1 - neutral_axis) / d
    else:
        value_a = rho_t + rho_c + rho_i - axial_force / 1.8 / modular_ratio / b / d / fc
        value_b = rho_t + rho_c * delta_1 + 0.5 * rho_i * (1 + delta_1)
        neutral_axis = (
            math.sqrt(modular_ratio**2 * value_a**2 + 2 * modular_ratio * value_b)
            - modular_ratio * value_a
        )
        yield_curvature = 1.8 * fc / (ec * d * neutral_axis)
    term_1 = ec * neutral_axis**2 / 2 * (0.5 * (1 + delta_1) - neutral_axis / 3)
    term_2 = (
        es
        / 2
        * (
            (1 - neutral_axis) * rho_t
            + (neutral_axis - delta_1) * rho_c
            + rho_i / 6 * (1 - delta_1)
        )
        * (1 - delta_1)
    )
    moment = b * d**3 * yield_curvature * (term_1 + term_2)
    return moment


def RCHinge(
    SpringID: int,
    NodeI: int,
    NodeJ: int,
    fc: float,
    Ec: float,
    fy: float,
    Es: float,
    b: float,
    h: float,
    dTop: float,
    dBottom: float,
    s: float,
    rhoTop: float,
    rhoBottom: float,
    rhoI: float,
    rhoSH: float,
    a_sl: float,
    PPc: float,
    Units: Literal[1, 2],
    L: float,
    EIyEIg: float,
    n: float,
    Reverse: bool | int,
) -> None:
    """Create one asymmetric ``IMKPeakOriented`` zero-length hinge.

    Args:
        SpringID: Zero-length element and rotational-material tag.
        NodeI: Element i-node tag.
        NodeJ: Element j-node tag.
        fc: Expected concrete cylinder compressive strength.
        Ec: Concrete elastic modulus.
        fy: Expected longitudinal-reinforcement yield strength.
        Es: Reinforcement elastic modulus.
        b: Section width.
        h: Section depth in the bending direction.
        dTop: Centroid depth of top longitudinal bars from the top face.
        dBottom: Centroid depth of bottom longitudinal bars from the bottom face.
        s: Transverse-reinforcement spacing; retained for the reference-model interface.
        rhoTop: Top longitudinal reinforcement ratio based on gross area ``b*h``.
        rhoBottom: Bottom longitudinal reinforcement ratio based on gross area ``b*h``.
        rhoI: Intermediate side-reinforcement ratio based on gross area ``b*h``.
        rhoSH: Effective transverse-reinforcement ratio.
        a_sl: Bond-slip indicator, normally 0 or 1.
        PPc: Axial-load ratio based on gross area, ``P/(b*h*fc)``.
        Units: 1 for mm/MPa or 2 for inch/ksi.
        L: Clear member length between joint faces.
        EIyEIg: Effective-to-gross flexural-stiffness ratio.
        n: Series-stiffness multiplier used by the elastic member and hinge.
        Reverse: Swap positive and negative yield moments for the opposite member end.

    Returns:
        None. The function adds one material and one zero-length element to OpenSees.
    """
    unit_factor = 1.0 if Units == 1 else 6.895
    area_top = rhoTop * b * h
    area_bottom = rhoBottom * b * h
    area_intermediate = rhoI * b * h
    axial_force = PPc * b * h * fc
    moment_positive = _yield_moment(
        b,
        h,
        dTop,
        dBottom,
        area_bottom,
        area_top,
        area_intermediate,
        axial_force,
        fc,
        Ec,
        fy,
        Es,
        unit_factor,
    )
    moment_negative = _yield_moment(
        b,
        h,
        dBottom,
        dTop,
        area_top,
        area_bottom,
        area_intermediate,
        axial_force,
        fc,
        Ec,
        fy,
        Es,
        unit_factor,
    )
    axial_ratio = PPc
    theta_p_symmetric = (
        0.1
        * (1 + 0.55 * a_sl)
        * 0.16**axial_ratio
        * (0.02 + 40 * rhoSH) ** 0.43
        * 0.54 ** (0.01 * unit_factor * fc)
    )
    positive_depth = h - dBottom
    negative_depth = h - dTop
    theta_p_positive = theta_p_symmetric * _asymmetric_rotation_factor(
        area_top / (b * positive_depth),
        area_bottom / (b * positive_depth),
        fy,
        fc,
    )
    theta_p_negative = theta_p_symmetric * _asymmetric_rotation_factor(
        area_bottom / (b * negative_depth),
        area_top / (b * negative_depth),
        fy,
        fc,
    )
    if Reverse:
        moment_positive, moment_negative = moment_negative, moment_positive
        theta_p_positive, theta_p_negative = theta_p_negative, theta_p_positive
    theta_pc = min(
        0.76 * 0.031**axial_ratio * (0.02 + 40 * rhoSH) ** 1.02,
        0.10,
    )
    lambda_prime = 30.0 * 0.3**axial_ratio
    lambda_imk = lambda_prime * min(theta_p_positive, theta_p_negative)
    inertia = b * h**3 / 12 * EIyEIg
    initial_stiffness = (n + 1.0) * 6 * Ec * inertia / L
    material_arguments = (
        initial_stiffness,
        theta_p_positive,
        theta_pc,
        0.2,
        moment_positive,
        1.13,
        0.01,
        theta_p_negative,
        theta_pc,
        0.2,
        moment_negative,
        1.13,
        0.01,
        lambda_imk,
        lambda_imk,
        lambda_imk,
        lambda_imk,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
    )
    ops.uniaxialMaterial("IMKPeakOriented", SpringID, *material_arguments)
    ops.element(
        "zeroLength",
        SpringID,
        NodeI,
        NodeJ,
        "-mat",
        99,
        99,
        SpringID,
        "-dir",
        1,
        2,
        6,
        "-doRayleigh",
        1,
    )
