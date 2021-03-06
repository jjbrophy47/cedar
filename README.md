<!--<p align="center">
  <img src=images/logo.png?raw=true" alt="logo"/>
</p>-->

DaRE
---

**DaRE** (**Da**ta **R**emoval-**E**nabled) trees are stochastic variants of decision trees / random forests that provide efficient _removal_ of training data without having to retrain from scratch.

Install
---
1. Install Python 3.7+.
1. Install dependencies and compile project. Run `make all`.

Simple Example
---
```
import dare
import numpy as np

# initialize some training data
X = np.array([[0, 1], [0, 1], [0, 1], [1, 0], [1, 0]])
y = np.array([1, 1, 1, 0, 1])

# create a test sample
X_test = np.array([[1, 0]])

# train a data deletion-enabled RF model
rf = dare.Forest(n_estimators=100,
                 max_depth=3,
                 criterion='gini',
                 random_state=1)
rf.fit(X, y)

# prediction before deletion => [0.5, 0.5]
rf.predict_proba(X_test)

# delete training sample at index 3 ([1, 0])
rf.delete(3)

# prediction after deletion => [0.0, 1.0]
rf.predict_proba(X_test)
```

Paper
---
For further details please refer to the paper: [Dart: Data Addition and Removal Trees](https://arxiv.org/abs/2009.05567).

```
@article{brophy2020dart,
  title={DART: Data Addition and Removal Trees},
  author={Brophy, Jonathan and Lowd, Daniel},
  journal={arXiv preprint arXiv:2009.05567},
  year={2020}
}
```