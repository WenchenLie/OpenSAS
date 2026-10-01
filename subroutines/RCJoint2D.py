"""Create RC Joint2D elements from generation-time material parameters."""

from __future__ import annotations

import openseespy.opensees as ops


def RCJoint2D(
    JointID: int,
    NodeB: int,
    NodeR: int,
    NodeT: int,
    NodeL: int,
    XCenter: float,
    YCenter: float,
    ColumnDepth: float,
    BeamDepth: float,
    PanelModel: str,
    *panel_arguments: float | str,
) -> None:
    """Create one complete RC Joint2D assembly.

    Args:
        JointID: Joint2D element, internal center-node, and center-material tag.
        NodeB: Bottom external-node tag.
        NodeR: Right external-node tag.
        NodeT: Top external-node tag.
        NodeL: Left external-node tag.
        XCenter: Global x coordinate of the joint center in mm.
        YCenter: Global y coordinate of the joint center in mm.
        ColumnDepth: Horizontal joint-core dimension in mm.
        BeamDepth: Vertical joint-core dimension in mm.
        PanelModel: ``Elastic``, ``Rigid``, or ``Pinching4``.
        panel_arguments: Mode-specific parameters. Elastic receives
            ``JointWidth, Ec, Nu``; Rigid adds ``StiffnessFactor``. Pinching4
            receives its 16 positive/negative envelope values followed by
            ``ReloadDisp, ReloadForce, UnloadForce, Degradation,
            EnergyCapacity, DamageType``. The MCFT envelope values are
            calculated by MRFHelper before this function is written to the
            generated model.

    Returns:
        None. Four external nodes, the selected center material, and one
        Joint2D element are added to the active OpenSees model.
    """
    ops.node(NodeB, XCenter, YCenter - BeamDepth / 2.0)
    ops.node(NodeR, XCenter + ColumnDepth / 2.0, YCenter)
    ops.node(NodeT, XCenter, YCenter + BeamDepth / 2.0)
    ops.node(NodeL, XCenter - ColumnDepth / 2.0, YCenter)

    normalized = PanelModel.strip().lower()
    if normalized in {"elastic", "rigid"}:
        expected = 3 if normalized == "elastic" else 4
        if len(panel_arguments) != expected:
            raise ValueError(f"{PanelModel} RCJoint2D expects {expected} material arguments")
        joint_width, ec, poisson_ratio = (float(value) for value in panel_arguments[:3])
        stiffness_factor = float(panel_arguments[3]) if normalized == "rigid" else 1.0
        if min(joint_width, ec, stiffness_factor) <= 0 or not -1.0 < poisson_ratio < 0.5:
            raise ValueError("Invalid elastic RC joint-panel properties")
        shear_modulus = ec / (2.0 * (1.0 + poisson_ratio))
        rotational_stiffness = (
            shear_modulus * joint_width * ColumnDepth * BeamDepth * stiffness_factor
        )
        ops.uniaxialMaterial("Elastic", JointID, rotational_stiffness)
    elif normalized == "pinching4":
        if len(panel_arguments) != 22:
            raise ValueError("Pinching4 RCJoint2D expects 22 material arguments")
        envelope = tuple(float(value) for value in panel_arguments[:16])
        reload_disp, reload_force, unload_force, degradation, energy_capacity = (
            float(value) for value in panel_arguments[16:21]
        )
        damage_type = str(panel_arguments[21])
        ops.uniaxialMaterial(
            "Pinching4",
            JointID,
            *envelope,
            reload_disp,
            reload_force,
            unload_force,
            reload_disp,
            reload_force,
            unload_force,
            *([degradation] * 15),
            energy_capacity,
            damage_type,
        )
    else:
        raise ValueError("PanelModel must be one of: Elastic, Rigid, Pinching4")

    ops.element("Joint2D", JointID, NodeB, NodeR, NodeT, NodeL, JointID, JointID, 0)
