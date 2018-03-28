# lambda-meter 0.0.0
## What is this?
Closure profiler.

### Current lisp world
SBCL has strong profiler.

### Issues
Sb-profile:profile can not profile closure.
More precisely, it can profile global facrotory function,
but closure instance which returned by factory function.

### Proposal
LAMBDA-METER provides such feature.

Let's say here is a factory function `adder`.

```lisp
(defun adder(x)
  (lambda(y)
    (+ x y)))
```

When profile closure instance, modify source like below.

```lisp
(named-readtables:in-readtable lambda-meter:syntax)

(defun adder(x)
  #M adder
  (lambda(y)
    (+ x y)))
```

Then, SB-PROFILE:REPORT works well.

## Usage

## From developer

### Product's goal
Already?

### License
MIT

### Developed with
SBCL

### Tested with
SBCL

## Installation

