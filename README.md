# Solidity Security Patterns

> Smart contracts are not programs — they are state machines executing in an adversarial environment.

This repository models real-world failure modes in Solidity systems and demonstrates how they are exploited, mitigated, and measured.

Each module follows the same discipline:
- break the system
- prove the exploit
- apply the fix
- verify the invariant

The focus is not patterns — it is decision-making under EVM constraints: correctness, security, and cost.

---

## Why This Matters

These vulnerabilities are not theoretical:
- reentrancy has drained protocols
- access control bugs have led to full fund loss
- MEV exploits reorder execution in production
- gas inefficiencies directly impact protocol viability

Understanding these tradeoffs is required to ship secure systems on-chain.

---

## System Overview

The repository contains paired implementations:
- vulnerable contracts (real attack surfaces)
- secure versions (mitigations applied)
- test suites proving both exploitability and correctness

Focus areas:
- reentrancy
- arithmetic safety
- access control
- transaction ordering (MEV)
- gas optimization

---

## Security Case Studies

### Reentrancy

**Vulnerability**  
State is updated after an external call.

**Exploit**  
Attacker re-enters `withdraw()` via `receive()` before balance is cleared, draining funds.

**Root Cause**  
Control flow is transferred before state transition is finalized.

**Invariant Violation**  
User balance must be reduced before any external interaction.

---

### Reentrancy Mitigation

**Fix Strategy**

- **Checks-Effects-Interactions (CEI)**  
  Eliminates the root cause.

- **ReentrancyGuard**  
  Blocks nested execution at runtime.

**Validation**

- Exploit succeeds on vulnerable contract  
- Exploit fails on protected implementations  

**Insight**

Reentrancy is not a race condition — it is a control flow problem.

Security requires:
- correct state ordering  
- runtime enforcement  

---

### Integer Arithmetic

**Models Compared**

- Legacy (wraparound)  
- Checked (Solidity 0.8+)  
- Unchecked (manual responsibility)  

**Root Cause**

The EVM uses modular arithmetic (`mod 2²⁵⁶`).  
Safety is introduced by the compiler, not the execution layer.

**Failure Mode**

Unchecked arithmetic without bounds leads to silent state corruption.

**Invariant**

Arithmetic must remain within defined system bounds.

**Insight**

Overflow is not removed — it is abstracted behind compiler checks.

---

### Access Control

**Vulnerability**

Missing authorization enables:
- ownership takeover  
- unrestricted withdrawals  

**Root Cause**

Authorization boundary is not enforced.

**Failure Mode**

Unauthorized actors can mutate state and extract funds.

**Fix**

- `onlyOwner` modifier  
- custom errors  

**Invariant**

Only authorized entities may perform privileged actions.

---

### tx.origin Anti-Pattern

**Vulnerability**

Authorization based on `tx.origin`.

**Exploit**

Malicious contract forwards a call:
- `tx.origin` = victim  
- `msg.sender` = attacker  

Check passes → attacker gains access.

**Fix**

Use `msg.sender`.

**Insight**

Authorization must follow execution context, not transaction origin.

---

### MEV / Front-Running

**Vulnerability**

User input is visible in the mempool before execution.

Attackers can reorder transactions by bidding higher gas.

**Root Cause**

Execution ordering is adversarial.

**Failure Mode**

State transitions depend on publicly observable input.

---

### Commit-Reveal Mitigation

**Approach**

- commit (hidden intent)  
- reveal (verified execution)  
```solidity
keccak256(abi.encodePacked(msg.sender, value, salt))
```

**Security Properties**

- hides intent
- binds commitment to sender
- prevents copying attacks

**Limitations**

Does not guarantee fairness — only removes reactive advantage.

**Invariant**

Outcome must not depend on observable input before execution.

**Insight**

Security sometimes requires hiding information, not validating it.

---

## Gas Analysis

Optimization is not about cleaner code — it is about reducing expensive EVM operations.

### Results

| Function | Inefficient | Optimized | Δ Gas | Δ % |
|---|---|---|---|---|
| Deployment | 564860 | 462483 | -102377 | -18.1% |
| sumBalanceTimes | 6963 | 3906 | -3057 | -43.9% |
| sumNumbers | 17858 | 15190 | -2668 | -14.9% |
| setNumbers | 158984 | 157450 | -1534 | -1.0% |
| setBalance | 44437 | 44437 | 0 | 0% |

### Interpretation

**sumBalanceTimes (-44%)**  
Eliminates repeated SLOAD via caching.

**sumNumbers (-15%)**  
Reduces loop and memory overhead.

**setNumbers (-1%)**  
Dominated by SSTORE. Writes outweigh optimizations.

**Deployment (-18%)**  
Reduced via `immutable` and custom errors.

### Key Insight

Gas cost follows EVM primitives:
- optimize SLOAD → high impact
- optimize SSTORE → limited impact
- optimize syntax → marginal gains

### Limitations

Optimization does not solve:
- expensive storage writes
- poor state modeling
- write-heavy designs

If the model is inefficient, optimization will not fix it.

> *Measure first. Optimize what matters.*

---

## Engineering Principles

- State is the primary attack surface
- Execution order defines security boundaries
- External calls transfer control
- Authorization must be explicit
- Compiler safety is not a guarantee
- Storage dominates cost
- Measure before optimizing

---

## Project Structure
```
solidity-security-patterns/
├── src/
│   ├── gas/
│   │   ├── GasInefficient.sol
│   │   └── GasOptimized.sol
│   ├── mev/
│   │   ├── VulnerableGame.sol
│   │   └── CommitRevealGame.sol
│   ├── AccessControlVulnerable.sol
│   ├── AccessControlFixed.sol
│   ├── AccessControlBrokenTxOrigin.sol
│   ├── Attacker.sol
│   ├── TxOriginAttacker.sol
│   ├── OverflowLegacy.sol
│   ├── OverflowUnchecked.sol
│   ├── OverflowChecked.sol
│   ├── VulnerableBank.sol
│   ├── GuardedBank.sol
│   └── SafeBank.sol
├── test/
│   ├── gas/
│   │   └── GasOptimization.t.sol
│   ├── mev/
│   │   ├── VulnerableGame.t.sol
│   │   └── CommitRevealGame.t.sol
│   ├── AccessControl.t.sol
│   ├── AccessControlTxOrigin.t.sol
│   ├── Overflow.t.sol
│   └── Reentrancy.t.sol
├── foundry.toml
└── README.md
```

---

## Running Tests
```bash
forge test

forge test --match-path test/Reentrancy.t.sol
forge test --match-path test/AccessControl.t.sol
forge test --match-path test/mev/VulnerableGame.t.sol

forge test --match-path test/gas/GasOptimization.t.sol --gas-report
```

---

## Tech Stack

- [Foundry](https://book.getfoundry.sh/)
- Solidity `^0.8.20`
- WSL2 / Ubuntu