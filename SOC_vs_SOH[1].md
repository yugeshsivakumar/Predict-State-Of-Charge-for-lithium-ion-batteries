# 📊 Battery Health Metrics

## 🔋 State of Charge (SoC)

The **State of Charge (SoC)** indicates how much energy or charge is left in a battery, similar to a fuel gauge in a car showing how much gas is in the tank.

- **100% SoC** → The battery is fully charged.
- **0% SoC** → The battery is completely empty.

The formula for SoC:

$$
\text{SoC} = \left( \frac{\text{Remaining Capacity}}{\text{Total Capacity}} \right) \times 100\%
$$

## ⚡ State of Health (SoH)

**State of Health (SoH)** describes the overall condition of a battery, representing how much of its original capacity it still retains.

**Formula:**

$$
\text{SoH} = \left( \frac{\text{Current Capacity}}{\text{Original Capacity}} \right) \times 100\%
$$

- **Current Capacity** → The amount of charge the battery can hold right now.
- **Original Capacity** → The amount of charge the battery could hold when it was new.

## 📉 Battery Degradation

Battery degradation is the loss of capacity over time. It can be calculated as:

$$
\text{Degradation} = 100\% - \text{SoH}
$$

### Example:

If a battery's SoH is **80%**, then:

$$
\text{Degradation} = 100\% - 80\% = 20\%
$$

This means the battery has lost **20%** of its original capacity.

---

🔧 **Understanding these metrics helps in monitoring battery performance and lifespan!** 🚀
