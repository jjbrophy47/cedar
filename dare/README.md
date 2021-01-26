DaRE
---
Source code for the implementation of DaRE trees, a random forest (RF) that supports efficient data deletion. This implementation follows standard RF learning procedures (e.g. sampling a random subset of features at each split in each tree) with two significant differences controlled by the following hyperparameters.

* `k`: Controls the number of thresholds sampled for each feature at each node. If predictive performance is too low, try setting `k` to a larger value.


* `topd`: Any node at depth < `topd` will be a random node, meaning a feature is sampled unifomly at random, and a threshold is generated by sampling a value uniformly at random in the range [`min`, `max`] where `min` and `max` are the minimum and maximum values for the sampled feature.