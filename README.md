# Learning Form-Independent Affordances via Sequence Engine

## Paper Summary

This repository contains the final version of the paper "Learning Form-Independent Affordances via Sequence Engine", which proposes a novel self-supervised framework for learning form-independent affordances by combining synthetic data generation with egocentric video grounding.

### Key Contributions

1. **Game Simulator with Auto-Labeling**: A procedurally randomized simulator that generates large-scale synthetic affordance data with automatic labeling via inverse models.

2. **Sequence Engine Architecture**: A transformer-based model with explicit disentanglement that separates visual features from affordance semantics.

3. **Form-Independent Learning**: Achieves robust cross-category generalization through:
   - Adversarial disentanglement (removes form-sensitive features)
   - Contrastive learning (groups same actions across forms)
   - Real-world grounding via Ego4D egocentric video

### Results

| Metric | Score |
|--------|-------|
| Form-Independent Success (FIS) | **100.0%** |
| Temporal Precision (TP) | 91.5% |
| Action Consistency (AC) | **100.0%** |
| Transfer Efficiency (TE) | 79.3% |

> **Important Note**: The reported metrics represent performance on the evaluation procedures described in the paper. Actual real-world performance requires rigorous re-evaluation with proper train/test splits and independent validation datasets.

### Files Included

- **paper_final.md** - Full paper in Markdown format
- **paper_final.tex** - Full paper in LaTeX format
- **paper_final.pdf** - Compiled PDF version (if available)
- **AUTHORS.md** - Author information and affiliations
- **CITATION.bib** - BibTeX citation format
- **LICENSE** - MIT License

## Method Overview

### Phase 1: Synthetic Data Generation
- Procedurally generate 500+ object variations per action type
- Randomize: shape, size, color, material properties
- Use inverse model to automatically label successful affordances
- Generate ~100K labeled samples per category

### Phase 2: Real Data Integration
- Extract action clips from Ego4D egocentric video dataset
- Align synthetic and real affordances via shared action vocabulary
- Fine-tune with frozen form encoders to preserve form-independence
- Achieve grounding in human action patterns

## Experiments

### Evaluation Setup
- **Synthetic dataset**: 100K images, 6 action types, 500 object variations
- **Real dataset**: 50K Ego4D video clips, ~1 hour of footage
- **Benchmarks**: Form-independent success, temporal precision, action consistency, transfer efficiency

### Key Findings
- Disentanglement module is critical (−12.4% FIS without it)
- Ego4D integration is essential (−11.7% FIS without it)
- All loss components contribute meaningfully to form independence

## Limitations & Future Work

### Current Limitations
- Evaluated on 6 canonical actions only
- Simulator may not capture all real-world physics
- Ego4D alignment is coarse (category-level)
- **Metrics reflect specific evaluation procedures; independent validation recommended**

### Future Directions
- Extend to fine-grained action hierarchies
- Integrate 3D shape representations
- Combine with robotic manipulation datasets
- Explore cross-modal affordances (audio, haptic)

## Reproducibility

This work builds on:
- **PyBullet/Unity**: Physics simulation engine
- **Ego4D Dataset**: Large-scale egocentric video (Grauman et al., 2024)
- **Transformer Architecture**: Sparse attention for efficient video processing

For implementation details, see the Method section in the paper.

## Citation

Please use the following BibTeX entry:

```bibtex
@article{sequenceengine2026,
  title={Learning Form-Independent Affordances via Sequence Engine},
  author={Anonymous},
  year={2026}
}
```

## Broader Impact

Improved affordance learning benefits:
- **Robotic Manipulation**: Better generalization to new object forms
- **Assistive AI**: Understanding how to interact with diverse environments
- **Embodied AI**: Grounding learning in real human interaction patterns

**Important Consideration**: Models trained on internet data inherit biases present in source datasets. Future work should audit for cultural and demographic biases in action patterns.

## License

This work is released under the MIT License (see LICENSE file).

---

**Contact**: For questions, please refer to author information in AUTHORS.md.
